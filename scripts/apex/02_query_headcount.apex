// Walkthrough 3: Query through service and selector methods.
// This is intentionally read-only so you can run it repeatedly.
System.debug('Active personnel in Engineering');
for (Personnel__c person : PersonnelService.findActiveByDepartment(new Set<String>{ 'Engineering' })) {
    System.debug(person.Employee_Id__c + ' ' + person.Display_Name__c + ' ' + person.Role__c);
}

// This calls a service method that wraps a SOQL GROUP BY query.
System.debug('Active headcount by department');
for (PersonnelService.HeadcountSummary summary : PersonnelService.summarizeActiveHeadcount()) {
    System.debug(summary.department + ': ' + summary.activePersonnel);
}

// Parent-child SOQL uses the child relationship name. The lookup metadata uses
// relationshipName=Assignments, so the child relationship is Assignments__r.
System.debug('SOQL parent-child example');
for (Personnel__c person : [
    SELECT Employee_Id__c, Display_Name__c,
        (SELECT Assignment_Name__c, Status__c, Start_Date__c FROM Assignments__r)
    FROM Personnel__c
    WHERE Employee_Id__c LIKE 'SAMPLE-%'
    ORDER BY Last_Name__c
]) {
    System.debug(person.Employee_Id__c + ' has ' + person.Assignments__r.size() + ' assignments.');
}
