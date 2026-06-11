public with sharing class PersonnelDashboardController {
    public class DashboardData {
        @AuraEnabled public String selectedDepartment { get; set; }
        @AuraEnabled public Date generatedOn { get; set; }
        @AuraEnabled public Integer activePersonnelCount { get; set; }
        @AuraEnabled public Integer overdueReviewCount { get; set; }
        @AuraEnabled public List<HeadcountRow> headcount { get; set; }
        @AuraEnabled public List<PersonnelRow> personnel { get; set; }
        @AuraEnabled public List<AssignmentRow> activeAssignments { get; set; }

        public DashboardData() {
            generatedOn = Date.today();
            activePersonnelCount = 0;
            overdueReviewCount = 0;
            headcount = new List<HeadcountRow>();
            personnel = new List<PersonnelRow>();
            activeAssignments = new List<AssignmentRow>();
        }
    }

    public class HeadcountRow {
        @AuraEnabled public String department { get; set; }
        @AuraEnabled public Integer activePersonnel { get; set; }

        public HeadcountRow(String department, Integer activePersonnel) {
            this.department = department;
            this.activePersonnel = activePersonnel;
        }
    }

    public class PersonnelRow {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String employeeId { get; set; }
        @AuraEnabled public String displayName { get; set; }
        @AuraEnabled public String department { get; set; }
        @AuraEnabled public String role { get; set; }
        @AuraEnabled public String reviewStatus { get; set; }
        @AuraEnabled public Date lastReviewDate { get; set; }

        public PersonnelRow(Personnel__c person) {
            id = person.Id;
            employeeId = person.Employee_Id__c;
            displayName = person.Display_Name__c;
            department = person.Department__c;
            role = person.Role__c;
            reviewStatus = person.Review_Status__c;
            lastReviewDate = person.Last_Review_Date__c;
        }
    }

    public class AssignmentRow {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public Id personnelId { get; set; }
        @AuraEnabled public String personnelName { get; set; }
        @AuraEnabled public String assignmentName { get; set; }
        @AuraEnabled public String assignmentType { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Date startDate { get; set; }
        @AuraEnabled public Decimal hoursPerWeek { get; set; }

        public AssignmentRow(Personnel_Assignment__c assignment) {
            id = assignment.Id;
            personnelId = assignment.Personnel__c;
            personnelName = assignment.Personnel__r == null ? null : assignment.Personnel__r.Display_Name__c;
            assignmentName = assignment.Assignment_Name__c;
            assignmentType = assignment.Assignment_Type__c;
            status = assignment.Status__c;
            startDate = assignment.Start_Date__c;
            hoursPerWeek = assignment.Hours_Per_Week__c;
        }
    }

    public class AssignmentRequest {
        @AuraEnabled public Id personnelId { get; set; }
        @AuraEnabled public String assignmentName { get; set; }
        @AuraEnabled public String assignmentType { get; set; }
        @AuraEnabled public Date startDate { get; set; }
        @AuraEnabled public Decimal hoursPerWeek { get; set; }
    }

    public class AssignmentResult {
        @AuraEnabled public Id assignmentId { get; set; }
        @AuraEnabled public String assignmentName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String message { get; set; }

        public AssignmentResult(Personnel_Assignment__c assignment) {
            assignmentId = assignment.Id;
            assignmentName = assignment.Assignment_Name__c;
            status = assignment.Status__c;
            message = 'Assignment created';
        }
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData(String departmentFilter) {
        DashboardData data = new DashboardData();
        data.selectedDepartment = normalizeDepartmentFilter(departmentFilter);

        List<Personnel__c> activePeople = loadActivePeople(data.selectedDepartment);
        data.activePersonnelCount = activePeople.size();

        Set<Id> personnelIds = new Set<Id>();
        for (Personnel__c person : activePeople) {
            data.personnel.add(new PersonnelRow(person));
            personnelIds.add(person.Id);
            if (person.Review_Status__c == 'Overdue') {
                data.overdueReviewCount++;
            }
        }

        for (PersonnelService.HeadcountSummary summary : PersonnelService.summarizeActiveHeadcount()) {
            data.headcount.add(new HeadcountRow(summary.department, summary.activePersonnel));
        }

        if (!personnelIds.isEmpty()) {
            for (Personnel_Assignment__c assignment : [
                SELECT Id, Personnel__c, Personnel__r.Display_Name__c, Assignment_Name__c,
                    Assignment_Type__c, Status__c, Start_Date__c, Hours_Per_Week__c
                FROM Personnel_Assignment__c
                WHERE Personnel__c IN :personnelIds
                    AND Status__c = 'Active'
                ORDER BY Start_Date__c DESC, Assignment_Name__c
                LIMIT 200
            ]) {
                data.activeAssignments.add(new AssignmentRow(assignment));
            }
        }

        return data;
    }

    @AuraEnabled
    public static AssignmentResult createAssignment(AssignmentRequest request) {
        if (request == null) {
            throw new AuraHandledException('Assignment details are required.');
        }

        Personnel_Assignment__c assignment = PersonnelAssignmentService.createAssignment(
            request.personnelId,
            request.assignmentName,
            request.assignmentType,
            request.startDate,
            request.hoursPerWeek
        );

        return new AssignmentResult(assignment);
    }

    private static String normalizeDepartmentFilter(String departmentFilter) {
        if (String.isBlank(departmentFilter) || departmentFilter == 'All') {
            return 'All';
        }
        return departmentFilter.trim();
    }

    private static List<Personnel__c> loadActivePeople(String selectedDepartment) {
        if (selectedDepartment != 'All') {
            return PersonnelService.findActiveByDepartment(new Set<String>{ selectedDepartment });
        }

        return [
            SELECT Id, Employee_Id__c, Display_Name__c, Department__c, Role__c,
                Review_Status__c, Last_Review_Date__c
            FROM Personnel__c
            WHERE Status__c = 'Active'
            ORDER BY Department__c, Last_Name__c, First_Name__c
            LIMIT 200
        ];
    }
}
