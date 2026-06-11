List<Personnel__c> samplePeople = [
    SELECT Id
    FROM Personnel__c
    WHERE Employee_Id__c LIKE 'SAMPLE-%'
        OR Employee_Id__c LIKE 'BULK-%'
];

Set<Id> samplePersonnelIds = new Map<Id, Personnel__c>(samplePeople).keySet();

if (!samplePersonnelIds.isEmpty()) {
    delete [
        SELECT Id
        FROM Personnel_Assignment__c
        WHERE Personnel__c IN :samplePersonnelIds
    ];
    delete samplePeople;
}

System.debug('Deleted sample personnel records: ' + samplePeople.size());
