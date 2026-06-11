System.debug('Active personnel in Engineering');
for (Personnel__c person : PersonnelService.findActiveByDepartment(new Set<String>{ 'Engineering' })) {
    System.debug(person.Employee_Id__c + ' ' + person.Display_Name__c + ' ' + person.Role__c);
}

System.debug('Active headcount by department');
for (PersonnelService.HeadcountSummary summary : PersonnelService.summarizeActiveHeadcount()) {
    System.debug(summary.department + ': ' + summary.activePersonnel);
}

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
