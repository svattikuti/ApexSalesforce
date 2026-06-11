// Cleanup script for sample data created by the walkthrough.
// It intentionally targets only SAMPLE-* and BULK-* Employee IDs.
List<Personnel__c> samplePeople = [
    SELECT Id
    FROM Personnel__c
    WHERE Employee_Id__c LIKE 'SAMPLE-%'
        OR Employee_Id__c LIKE 'BULK-%'
];

Set<Id> samplePersonnelIds = new Map<Id, Personnel__c>(samplePeople).keySet();

if (!samplePersonnelIds.isEmpty()) {
    // Delete children before parents because Personnel_Assignment__c uses a
    // restrictive lookup to Personnel__c.
    delete [
        SELECT Id
        FROM Personnel_Assignment__c
        WHERE Personnel__c IN :samplePersonnelIds
    ];
    delete samplePeople;
}

System.debug('Deleted sample personnel records: ' + samplePeople.size());
