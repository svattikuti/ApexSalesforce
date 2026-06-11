// Walkthrough 4 extension: Terminate one person and close related assignments.
// Run 01_insert_sample_personnel.apex first. Run 03_create_assignments.apex if
// you want to observe assignment closeout too.
Personnel__c person = [
    SELECT Id, Employee_Id__c, Display_Name__c, Status__c
    FROM Personnel__c
    WHERE Employee_Id__c = 'SAMPLE-003'
    LIMIT 1
];

// The service updates the personnel record and closes any open assignments in
// the same transaction.
PersonnelService.terminatePersonnel(new Set<Id>{ person.Id }, Date.today());

Personnel__c terminated = [
    SELECT Employee_Id__c, Display_Name__c, Status__c, Termination_Date__c
    FROM Personnel__c
    WHERE Id = :person.Id
    LIMIT 1
];

System.debug(
    terminated.Employee_Id__c + ' '
    + terminated.Display_Name__c + ' status='
    + terminated.Status__c + ' terminationDate='
    + terminated.Termination_Date__c
);
