public with sharing class PersonnelTriggerHandler {
    // Trigger handlers keep trigger files small. Each public method maps to one
    // trigger context, which makes behavior easier to test.
    public static void beforeInsert(List<Personnel__c> newRecords) {
        normalize(newRecords);
        enforceTerminationDates(newRecords);
    }

    public static void beforeUpdate(List<Personnel__c> newRecords, Map<Id, Personnel__c> oldMap) {
        normalize(newRecords);
        enforceTerminationDates(newRecords);
        preventSelfManagement(newRecords);
    }

    private static void normalize(List<Personnel__c> records) {
        for (Personnel__c person : records) {
            PersonnelService.normalizeForSave(person);
        }
    }

    private static void enforceTerminationDates(List<Personnel__c> records) {
        for (Personnel__c person : records) {
            if (person.Status__c == 'Terminated' && person.Termination_Date__c == null) {
                // addError blocks the save in the current transaction.
                person.addError('Termination Date is required when Status is Terminated.');
            }
        }
    }

    private static void preventSelfManagement(List<Personnel__c> records) {
        for (Personnel__c person : records) {
            if (person.Id != null && person.Manager__c == person.Id) {
                person.addError('A personnel record cannot be its own manager.');
            }
        }
    }
}
