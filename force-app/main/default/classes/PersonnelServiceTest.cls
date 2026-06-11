@IsTest
private class PersonnelServiceTest {
    @IsTest
    static void upsertPersonnel_insertsAndUpdatesByEmployeeId() {
        Personnel__c firstVersion = PersonnelTestDataFactory.buildPerson('UPS-0001', 'Operations');
        firstVersion.Email__c = 'UPPERCASE@EXAMPLE.COM';

        Test.startTest();
        List<Database.UpsertResult> insertResults =
            PersonnelService.upsertPersonnel(new List<Personnel__c>{ firstVersion });
        Test.stopTest();

        System.assertEquals(1, insertResults.size(), 'One record should be processed.');
        System.assert(insertResults[0].isSuccess(), 'Initial upsert should insert the record.');

        Personnel__c saved = [
            SELECT Id, Employee_Id__c, Email__c, Department__c
            FROM Personnel__c
            WHERE Employee_Id__c = 'UPS-0001'
            LIMIT 1
        ];
        System.assertEquals('uppercase@example.com', saved.Email__c);

        Personnel__c secondVersion = PersonnelTestDataFactory.buildPerson('UPS-0001', 'Engineering');
        secondVersion.Role__c = 'Platform Engineer';

        Test.startTest();
        List<Database.UpsertResult> updateResults =
            PersonnelService.upsertPersonnel(new List<Personnel__c>{ secondVersion });
        Test.stopTest();

        System.assert(updateResults[0].isSuccess(), 'Second upsert should update by external id.');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Personnel__c WHERE Employee_Id__c = 'UPS-0001'],
            'Upsert should not create a duplicate employee record.'
        );
        Personnel__c updated = [
            SELECT Department__c, Role__c
            FROM Personnel__c
            WHERE Employee_Id__c = 'UPS-0001'
            LIMIT 1
        ];
        System.assertEquals('Engineering', updated.Department__c);
        System.assertEquals('Platform Engineer', updated.Role__c);
    }

    @IsTest
    static void upsertPersonnel_handlesTwoHundredRecords() {
        List<Personnel__c> people =
            PersonnelTestDataFactory.buildPeople(200, 'Support', 'BULK');

        Test.startTest();
        List<Database.UpsertResult> results = PersonnelService.upsertPersonnel(people);
        Test.stopTest();

        System.assertEquals(200, results.size(), 'Every bulk record should return a result.');
        for (Database.UpsertResult result : results) {
            System.assert(result.isSuccess(), 'Every bulk upsert result should succeed.');
        }
        System.assertEquals(
            200,
            [SELECT COUNT() FROM Personnel__c WHERE Employee_Id__c LIKE 'BULK-%'],
            'The service should work with the trigger bulk context.'
        );
    }

    @IsTest
    static void findActiveByDepartment_ignoresInactiveRecords() {
        Personnel__c activePerson = PersonnelTestDataFactory.buildPerson('FIND-0001', 'Finance');
        Personnel__c inactivePerson = PersonnelTestDataFactory.buildPerson('FIND-0002', 'Finance');
        inactivePerson.Status__c = 'Inactive';
        insert new List<Personnel__c>{ activePerson, inactivePerson };

        List<Personnel__c> results =
            PersonnelService.findActiveByDepartment(new Set<String>{ 'Finance' });

        System.assertEquals(1, results.size());
        System.assertEquals('FIND-0001', results[0].Employee_Id__c);
    }

    @IsTest
    static void summarizeActiveHeadcount_groupsByDepartment() {
        insert new List<Personnel__c>{
            PersonnelTestDataFactory.buildPerson('SUM-0001', 'Security'),
            PersonnelTestDataFactory.buildPerson('SUM-0002', 'Security'),
            PersonnelTestDataFactory.buildPerson('SUM-0003', 'Sales')
        };

        Map<String, Integer> countsByDepartment = new Map<String, Integer>();
        for (PersonnelService.HeadcountSummary summary : PersonnelService.summarizeActiveHeadcount()) {
            countsByDepartment.put(summary.department, summary.activePersonnel);
        }

        System.assertEquals(2, countsByDepartment.get('Security'));
        System.assertEquals(1, countsByDepartment.get('Sales'));
    }
}
