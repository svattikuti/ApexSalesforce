import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getDashboardData from '@salesforce/apex/PersonnelDashboardController.getDashboardData';
import createAssignment from '@salesforce/apex/PersonnelDashboardController.createAssignment';

const PERSONNEL_COLUMNS = [
    { label: 'Employee ID', fieldName: 'employeeId' },
    { label: 'Name', fieldName: 'displayName' },
    { label: 'Department', fieldName: 'department' },
    { label: 'Role', fieldName: 'role' },
    { label: 'Review Status', fieldName: 'reviewStatus' },
    { label: 'Last Review', fieldName: 'lastReviewDate', type: 'date' }
];

const ASSIGNMENT_COLUMNS = [
    { label: 'Assignment', fieldName: 'assignmentName' },
    { label: 'Personnel', fieldName: 'personnelName' },
    { label: 'Type', fieldName: 'assignmentType' },
    { label: 'Start Date', fieldName: 'startDate', type: 'date' },
    { label: 'Hours / Week', fieldName: 'hoursPerWeek', type: 'number' }
];

export default class PersonnelDashboard extends LightningElement {
    // Builder property. Admins can set this in Lightning App Builder.
    @api defaultDepartment = 'All';

    selectedDepartment = 'All';
    dashboard;
    errorMessage;
    wiredDashboardResult;
    isSaving = false;

    selectedPersonnelId;
    selectedPersonnelLabel = 'Select a row above';
    assignmentName = '';
    assignmentType = 'Project';
    assignmentStartDate = new Date().toISOString().slice(0, 10);
    hoursPerWeek = 8;

    personnelColumns = PERSONNEL_COLUMNS;
    assignmentColumns = ASSIGNMENT_COLUMNS;

    departmentOptions = [
        { label: 'All Departments', value: 'All' },
        { label: 'Operations', value: 'Operations' },
        { label: 'Engineering', value: 'Engineering' },
        { label: 'Sales', value: 'Sales' },
        { label: 'Human Resources', value: 'Human Resources' },
        { label: 'Finance', value: 'Finance' },
        { label: 'Security', value: 'Security' },
        { label: 'Support', value: 'Support' }
    ];

    assignmentTypeOptions = [
        { label: 'Project', value: 'Project' },
        { label: 'Training', value: 'Training' },
        { label: 'Operations', value: 'Operations' },
        { label: 'Leave Coverage', value: 'Leave Coverage' },
        { label: 'Other', value: 'Other' }
    ];

    connectedCallback() {
        this.selectedDepartment = this.defaultDepartment || 'All';
    }

    // @wire is best for cacheable reads. The framework provisions data whenever
    // selectedDepartment changes, and refreshApex can reload it after a write.
    @wire(getDashboardData, { departmentFilter: '$selectedDepartment' })
    wiredDashboard(value) {
        this.wiredDashboardResult = value;
        const { data, error } = value;

        if (data) {
            this.dashboard = data;
            this.errorMessage = undefined;
            this.syncSelectedPersonnelAfterRefresh();
        } else if (error) {
            this.dashboard = undefined;
            this.errorMessage = this.reduceError(error);
        }
    }

    get isLoading() {
        return !this.dashboard && !this.errorMessage;
    }

    get personnelRows() {
        return this.dashboard?.personnel || [];
    }

    get assignmentRows() {
        return this.dashboard?.activeAssignments || [];
    }

    get headcountRows() {
        return this.dashboard?.headcount || [];
    }

    get activePersonnelCount() {
        return this.dashboard?.activePersonnelCount || 0;
    }

    get overdueReviewCount() {
        return this.dashboard?.overdueReviewCount || 0;
    }

    get activeAssignmentCount() {
        return this.assignmentRows.length;
    }

    get createAssignmentDisabled() {
        return (
            this.isSaving ||
            !this.selectedPersonnelId ||
            !this.assignmentName ||
            !this.assignmentStartDate ||
            !this.hoursPerWeek ||
            this.hoursPerWeek <= 0
        );
    }

    handleDepartmentChange(event) {
        this.selectedDepartment = event.detail.value;
        this.selectedPersonnelId = undefined;
        this.selectedPersonnelLabel = 'Select a row above';
    }

    handlePersonnelSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (!selectedRows.length) {
            this.selectedPersonnelId = undefined;
            this.selectedPersonnelLabel = 'Select a row above';
            return;
        }

        const selected = selectedRows[0];
        this.selectedPersonnelId = selected.id;
        this.selectedPersonnelLabel = `${selected.displayName} (${selected.employeeId})`;
    }

    handleAssignmentNameChange(event) {
        this.assignmentName = event.detail.value.trim();
    }

    handleAssignmentTypeChange(event) {
        this.assignmentType = event.detail.value;
    }

    handleStartDateChange(event) {
        this.assignmentStartDate = event.detail.value;
    }

    handleHoursChange(event) {
        this.hoursPerWeek = Number(event.detail.value);
    }

    async handleRefresh() {
        await this.refreshDashboard();
    }

    async handleCreateAssignment() {
        this.isSaving = true;

        try {
            // Imperative Apex is the right fit for writes because it runs only
            // when the user clicks the button and returns one Promise result.
            const result = await createAssignment({
                request: {
                    personnelId: this.selectedPersonnelId,
                    assignmentName: this.assignmentName,
                    assignmentType: this.assignmentType,
                    startDate: this.assignmentStartDate,
                    hoursPerWeek: this.hoursPerWeek
                }
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Assignment created',
                    message: result.assignmentName,
                    variant: 'success'
                })
            );
            this.assignmentName = '';
            await this.refreshDashboard();
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Unable to create assignment',
                    message: this.reduceError(error),
                    variant: 'error'
                })
            );
        } finally {
            this.isSaving = false;
        }
    }

    async refreshDashboard() {
        if (this.wiredDashboardResult) {
            await refreshApex(this.wiredDashboardResult);
        }
    }

    syncSelectedPersonnelAfterRefresh() {
        if (!this.selectedPersonnelId) {
            return;
        }

        const selected = this.personnelRows.find((row) => row.id === this.selectedPersonnelId);
        if (!selected) {
            this.selectedPersonnelId = undefined;
            this.selectedPersonnelLabel = 'Select a row above';
        }
    }

    reduceError(error) {
        if (Array.isArray(error?.body)) {
            return error.body.map((entry) => entry.message).join(', ');
        }
        return error?.body?.message || error?.message || 'Unknown error';
    }
}
