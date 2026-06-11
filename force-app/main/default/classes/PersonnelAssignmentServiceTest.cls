@IsTest
private class PersonnelAssignmentServiceTest {
    @IsTest
    static void createAssignment_createsRecordForActivePerson() {
        Personnel__c person = PersonnelTestDataFactory.buildPerson('ASN-0001', 'Engineering');
        insert person;

        Test.startTest();
        Personnel_Assignment__c assignment = PersonnelAssignmentService.createAssignment(
            person.Id,
            'API Migration',
            'Project',
            Date.today(),
            30
        );
        Test.stopTest();

        System.assertNotEquals(null, assignment.Id);
        System.assertEquals(person.Id, assignment.Personnel__c);
        System.assertEquals('Active', assignment.Status__c);
    }

    @IsTest
    static void createAssignment_rejectsInactivePerson() {
        Personnel__c person = PersonnelTestDataFactory.buildPerson('ASN-0002', 'Engineering');
        person.Status__c = 'Inactive';
        insert person;

        Boolean exceptionThrown = false;
        try {
            PersonnelAssignmentService.createAssignment(
                person.Id,
                'Restricted Assignment',
                'Project',
                Date.today(),
                10
            );
        } catch (PersonnelAssignmentService.AssignmentException ex) {
            exceptionThrown = true;
            System.assert(ex.getMessage().contains('active personnel'));
        }

        System.assert(exceptionThrown, 'Expected inactive personnel to be rejected.');
    }

    @IsTest
    static void createAssignmentForDepartment_insertsOnePerActivePerson() {
        Personnel__c activeOne = PersonnelTestDataFactory.buildPerson('ASN-0003', 'Support');
        Personnel__c activeTwo = PersonnelTestDataFactory.buildPerson('ASN-0004', 'Support');
        Personnel__c inactive = PersonnelTestDataFactory.buildPerson('ASN-0005', 'Support');
        inactive.Status__c = 'Inactive';
        insert new List<Personnel__c>{ activeOne, activeTwo, inactive };

        List<Personnel_Assignment__c> assignments =
            PersonnelAssignmentService.createAssignmentForDepartment(
                'Support',
                'Knowledge Base Cleanup',
                'Operations',
                Date.today(),
                5
            );

        System.assertEquals(2, assignments.size());
        System.assertEquals(
            2,
            [SELECT COUNT() FROM Personnel_Assignment__c WHERE Assignment_Name__c = 'Knowledge Base Cleanup']
        );
    }

    @IsTest
    static void closeOpenAssignments_completesCurrentAndCancelsFutureWork() {
        Personnel__c person = PersonnelTestDataFactory.buildPerson('ASN-0006', 'Operations');
        insert person;

        Personnel_Assignment__c currentAssignment =
            PersonnelTestDataFactory.buildAssignment(person.Id, 'Current Work', Date.today().addDays(-10));
        Personnel_Assignment__c futureAssignment =
            PersonnelTestDataFactory.buildAssignment(person.Id, 'Future Work', Date.today().addDays(30));
        insert new List<Personnel_Assignment__c>{ currentAssignment, futureAssignment };

        PersonnelAssignmentService.closeOpenAssignments(new Set<Id>{ person.Id }, Date.today());

        Map<String, Personnel_Assignment__c> assignmentsByName = new Map<String, Personnel_Assignment__c>();
        for (Personnel_Assignment__c assignment : [
            SELECT Assignment_Name__c, Status__c, End_Date__c
            FROM Personnel_Assignment__c
            WHERE Personnel__c = :person.Id
        ]) {
            assignmentsByName.put(assignment.Assignment_Name__c, assignment);
        }

        System.assertEquals('Completed', assignmentsByName.get('Current Work').Status__c);
        System.assertEquals(Date.today(), assignmentsByName.get('Current Work').End_Date__c);
        System.assertEquals('Cancelled', assignmentsByName.get('Future Work').Status__c);
        System.assertEquals(null, assignmentsByName.get('Future Work').End_Date__c);
    }
}
