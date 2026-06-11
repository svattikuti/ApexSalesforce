@IsTest
private class PersonnelDashboardControllerTest {
    @IsTest
    static void getDashboardData_returnsRowsForAllDepartments() {
        Personnel__c engineer = PersonnelTestDataFactory.buildPerson('UI-0001', 'Engineering');
        engineer.Review_Status__c = 'Overdue';
        Personnel__c operator = PersonnelTestDataFactory.buildPerson('UI-0002', 'Operations');
        insert new List<Personnel__c>{ engineer, operator };

        insert PersonnelTestDataFactory.buildAssignment(engineer.Id, 'UI Buildout', Date.today());

        Test.startTest();
        PersonnelDashboardController.DashboardData data =
            PersonnelDashboardController.getDashboardData('All');
        Test.stopTest();

        System.assertEquals('All', data.selectedDepartment);
        System.assertEquals(2, data.activePersonnelCount);
        System.assertEquals(1, data.overdueReviewCount);
        System.assertEquals(2, data.personnel.size());
        System.assertEquals(1, data.activeAssignments.size());
        System.assertEquals('UI Buildout', data.activeAssignments[0].assignmentName);
    }

    @IsTest
    static void getDashboardData_filtersByDepartment() {
        insert new List<Personnel__c>{
            PersonnelTestDataFactory.buildPerson('UI-0003', 'Engineering'),
            PersonnelTestDataFactory.buildPerson('UI-0004', 'Operations')
        };

        PersonnelDashboardController.DashboardData data =
            PersonnelDashboardController.getDashboardData('Engineering');

        System.assertEquals('Engineering', data.selectedDepartment);
        System.assertEquals(1, data.activePersonnelCount);
        System.assertEquals('Engineering', data.personnel[0].department);
    }

    @IsTest
    static void createAssignment_returnsUiResult() {
        Personnel__c person = PersonnelTestDataFactory.buildPerson('UI-0005', 'Support');
        insert person;

        PersonnelDashboardController.AssignmentRequest request =
            new PersonnelDashboardController.AssignmentRequest();
        request.personnelId = person.Id;
        request.assignmentName = 'Lightning Learning';
        request.assignmentType = 'Training';
        request.startDate = Date.today();
        request.hoursPerWeek = 4;

        Test.startTest();
        PersonnelDashboardController.AssignmentResult result =
            PersonnelDashboardController.createAssignment(request);
        Test.stopTest();

        System.assertNotEquals(null, result.assignmentId);
        System.assertEquals('Lightning Learning', result.assignmentName);
        System.assertEquals('Active', result.status);
        System.assertEquals('Assignment created', result.message);
    }

    @IsTest
    static void createAssignment_rejectsMissingRequest() {
        Boolean exceptionThrown = false;

        try {
            PersonnelDashboardController.createAssignment(null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown, 'Expected a handled UI exception.');
    }
}
