// SOQL Guide practice script.
// Run after:
// sf apex run --file scripts/apex/01_insert_sample_personnel.apex
// sf apex run --file scripts/apex/03_create_assignments.apex
//
// This script is intentionally read-only. It demonstrates common SOQL shapes
// using the custom Personnel__c and Personnel_Assignment__c objects.

System.debug('1) Basic SELECT with WHERE, ORDER BY, and LIMIT');
List<Personnel__c> activeEngineeringPeople = [
    SELECT Id, Employee_Id__c, Display_Name__c, Department__c, Role__c, Review_Status__c
    FROM Personnel__c
    WHERE Department__c = 'Engineering'
        AND Status__c = 'Active'
    ORDER BY Last_Name__c, First_Name__c
    LIMIT 50
];
for (Personnel__c person : activeEngineeringPeople) {
    System.debug(person.Employee_Id__c + ' | ' + person.Display_Name__c + ' | ' + person.Role__c);
}

System.debug('2) Bind variables, similar to parameterized query values');
String targetDepartment = 'Operations';
Set<String> targetStatuses = new Set<String>{ 'Active', 'On Leave' };
for (Personnel__c person : [
    SELECT Employee_Id__c, Display_Name__c, Department__c, Status__c
    FROM Personnel__c
    WHERE Department__c = :targetDepartment
        AND Status__c IN :targetStatuses
    ORDER BY Display_Name__c
]) {
    System.debug('Bound query result: ' + person.Display_Name__c + ' status=' + person.Status__c);
}

System.debug('3) Parent-to-child relationship query with Assignments__r');
for (Personnel__c person : [
    SELECT Employee_Id__c, Display_Name__c,
        (
            SELECT Assignment_Name__c, Status__c, Start_Date__c
            FROM Assignments__r
            WHERE Status__c = 'Active'
            ORDER BY Start_Date__c DESC
        )
    FROM Personnel__c
    WHERE Employee_Id__c LIKE 'SAMPLE-%'
    ORDER BY Last_Name__c
]) {
    System.debug(person.Display_Name__c + ' active assignment count=' + person.Assignments__r.size());
    for (Personnel_Assignment__c assignment : person.Assignments__r) {
        System.debug('  - ' + assignment.Assignment_Name__c + ' starts ' + assignment.Start_Date__c);
    }
}

System.debug('4) Child-to-parent relationship query with Personnel__r');
for (Personnel_Assignment__c assignment : [
    SELECT Assignment_Name__c, Assignment_Type__c, Status__c,
        Personnel__r.Employee_Id__c, Personnel__r.Display_Name__c
    FROM Personnel_Assignment__c
    WHERE Personnel__r.Employee_Id__c LIKE 'SAMPLE-%'
    ORDER BY Start_Date__c DESC, Assignment_Name__c
    LIMIT 20
]) {
    System.debug(
        assignment.Assignment_Name__c + ' belongs to '
        + assignment.Personnel__r.Employee_Id__c + ' '
        + assignment.Personnel__r.Display_Name__c
    );
}

System.debug('5) Aggregate query with GROUP BY');
for (AggregateResult row : [
    SELECT Department__c department, COUNT(Id) activePersonnel
    FROM Personnel__c
    WHERE Status__c = 'Active'
    GROUP BY Department__c
    ORDER BY Department__c
]) {
    System.debug((String) row.get('department') + ': ' + (Integer) row.get('activePersonnel'));
}

System.debug('6) SOQL for-loop list form for chunked iteration');
Integer chunksSeen = 0;
Integer rowsSeen = 0;
for (List<Personnel__c> scope : [
    SELECT Id, Employee_Id__c, Review_Status__c
    FROM Personnel__c
    WHERE Employee_Id__c LIKE 'SAMPLE-%'
]) {
    chunksSeen++;
    rowsSeen += scope.size();
    System.debug('Chunk ' + chunksSeen + ' size=' + scope.size());
}
System.debug('SOQL for-loop total rows=' + rowsSeen + ', chunks=' + chunksSeen);
