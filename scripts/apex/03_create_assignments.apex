List<Personnel_Assignment__c> engineeringAssignments =
    PersonnelAssignmentService.createAssignmentForDepartment(
        'Engineering',
        'Q3 Data Platform Readiness',
        'Project',
        Date.today(),
        12
    );

System.debug('Created Engineering assignments: ' + engineeringAssignments.size());

Personnel__c operationsLead = [
    SELECT Id, Display_Name__c
    FROM Personnel__c
    WHERE Employee_Id__c = 'SAMPLE-002'
    LIMIT 1
];

Personnel_Assignment__c assignment = PersonnelAssignmentService.createAssignment(
    operationsLead.Id,
    'Incident Response Rotation',
    'Operations',
    Date.today(),
    8
);

System.debug('Created assignment for ' + operationsLead.Display_Name__c + ': ' + assignment.Id);
