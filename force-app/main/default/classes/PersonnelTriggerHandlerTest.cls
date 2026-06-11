@IsTest
private class PersonnelTriggerHandlerTest {
    @IsTest
    static void beforeInsert_normalizesEmailAndDefaults() {
        Personnel__c person = PersonnelTestDataFactory.buildPerson('TRG-0001', 'Operations');
        person.Email__c = ' MixedCase@Example.COM ';
        person.Status__c = null;
        person.Employment_Type__c = null;
        person.Clearance_Level__c = null;
        person.Review_Status__c = null;

        insert person;

        Personnel__c saved = [
            SELECT Email__c, Status__c, Employment_Type__c, Clearance_Level__c, Review_Status__c
            FROM Personnel__c
            WHERE Id = :person.Id
            LIMIT 1
        ];
        System.assertEquals('mixedcase@example.com', saved.Email__c);
        System.assertEquals('Active', saved.Status__c);
        System.assertEquals('Full Time', saved.Employment_Type__c);
        System.assertEquals('None', saved.Clearance_Level__c);
        System.assertEquals('Not Started', saved.Review_Status__c);
    }

    @IsTest
    static void beforeInsert_rejectsTerminatedWithoutDate() {
        Personnel__c person = PersonnelTestDataFactory.buildPerson('TRG-0002', 'Operations');
        person.Status__c = 'Terminated';
        person.Termination_Date__c = null;

        Database.SaveResult result = Database.insert(person, false);

        System.assertEquals(false, result.isSuccess(), 'Terminated records need a date.');
        assertErrorContains(result, 'Termination Date is required');
    }

    @IsTest
    static void beforeUpdate_rejectsSelfManager() {
        Personnel__c person = PersonnelTestDataFactory.buildPerson('TRG-0003', 'Operations');
        insert person;

        person.Manager__c = person.Id;
        Database.SaveResult result = Database.update(person, false);

        System.assertEquals(false, result.isSuccess(), 'A person cannot manage themself.');
        assertErrorContains(result, 'own manager');
    }

    private static void assertErrorContains(Database.SaveResult result, String expectedText) {
        String allMessages = '';
        for (Database.Error error : result.getErrors()) {
            allMessages += error.getMessage() + '\n';
        }
        System.assert(
            allMessages.contains(expectedText),
            'Expected an error containing "' + expectedText + '", but got: ' + allMessages
        );
    }
}
