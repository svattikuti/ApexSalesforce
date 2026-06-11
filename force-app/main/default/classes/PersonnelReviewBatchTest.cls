@IsTest
private class PersonnelReviewBatchTest {
    @IsTest
    static void calculateReviewStatus_returnsExpectedValues() {
        Date today = Date.newInstance(2026, 6, 11);

        System.assertEquals('Overdue', PersonnelReviewBatch.calculateReviewStatus(null, today));
        System.assertEquals('Overdue', PersonnelReviewBatch.calculateReviewStatus(today.addDays(-365), today));
        System.assertEquals('Due Soon', PersonnelReviewBatch.calculateReviewStatus(today.addDays(-300), today));
        System.assertEquals('Current', PersonnelReviewBatch.calculateReviewStatus(today.addDays(-20), today));
    }

    @IsTest
    static void runNow_updatesReviewStatusInAsyncBatch() {
        Personnel__c overdue = PersonnelTestDataFactory.buildPerson('BAT-0001', 'Security');
        overdue.Last_Review_Date__c = Date.today().addDays(-400);
        overdue.Review_Status__c = 'Current';

        Personnel__c dueSoon = PersonnelTestDataFactory.buildPerson('BAT-0002', 'Security');
        dueSoon.Last_Review_Date__c = Date.today().addDays(-320);
        dueSoon.Review_Status__c = 'Current';

        Personnel__c current = PersonnelTestDataFactory.buildPerson('BAT-0003', 'Security');
        current.Last_Review_Date__c = Date.today().addDays(-30);
        current.Review_Status__c = 'Overdue';

        insert new List<Personnel__c>{ overdue, dueSoon, current };

        Test.startTest();
        Id jobId = PersonnelReviewBatch.runNow(50);
        Test.stopTest();

        System.assertNotEquals(null, jobId);

        Map<String, Personnel__c> peopleByEmployeeId = new Map<String, Personnel__c>();
        for (Personnel__c person : [
            SELECT Employee_Id__c, Review_Status__c
            FROM Personnel__c
            WHERE Employee_Id__c IN ('BAT-0001', 'BAT-0002', 'BAT-0003')
        ]) {
            peopleByEmployeeId.put(person.Employee_Id__c, person);
        }

        System.assertEquals('Overdue', peopleByEmployeeId.get('BAT-0001').Review_Status__c);
        System.assertEquals('Due Soon', peopleByEmployeeId.get('BAT-0002').Review_Status__c);
        System.assertEquals('Current', peopleByEmployeeId.get('BAT-0003').Review_Status__c);
    }
}
