// Walkthrough 2: Anonymous Apex as a REPL.
// Run with:
// sf apex run --file scripts/apex/01_insert_sample_personnel.apex
//
// This script creates records in memory, then sends the whole list through the
// service layer. Running it twice should update the same Employee IDs instead
// of creating duplicates.
List<Personnel__c> people = new List<Personnel__c>{
    new Personnel__c(
        Employee_Id__c = 'SAMPLE-001',
        First_Name__c = 'Ada',
        Last_Name__c = 'Lovelace',
        Email__c = 'ADA.LOVELACE@example.com',
        Department__c = 'Engineering',
        Role__c = 'Platform Architect',
        Employment_Type__c = 'Full Time',
        Hire_Date__c = Date.today().addYears(-4),
        Clearance_Level__c = 'Secret',
        Work_Location__c = 'Remote',
        Last_Review_Date__c = Date.today().addDays(-45),
        Review_Status__c = 'Current'
    ),
    new Personnel__c(
        Employee_Id__c = 'SAMPLE-002',
        First_Name__c = 'Grace',
        Last_Name__c = 'Hopper',
        Email__c = 'GRACE.HOPPER@example.com',
        Department__c = 'Operations',
        Role__c = 'Operations Lead',
        Employment_Type__c = 'Full Time',
        Hire_Date__c = Date.today().addYears(-6),
        Clearance_Level__c = 'Top Secret',
        Work_Location__c = 'HQ',
        Last_Review_Date__c = Date.today().addDays(-330),
        Review_Status__c = 'Current'
    ),
    new Personnel__c(
        Employee_Id__c = 'SAMPLE-003',
        First_Name__c = 'Katherine',
        Last_Name__c = 'Johnson',
        Email__c = 'KATHERINE.JOHNSON@example.com',
        Department__c = 'Finance',
        Role__c = 'Forecasting Analyst',
        Employment_Type__c = 'Contractor',
        Hire_Date__c = Date.today().addYears(-2),
        Clearance_Level__c = 'Confidential',
        Work_Location__c = 'Field Office',
        Last_Review_Date__c = Date.today().addDays(-390),
        Review_Status__c = 'Current'
    )
};

// The service method normalizes fields, queries existing Employee IDs once,
// then performs one bulk upsert.
List<Database.UpsertResult> results = PersonnelService.upsertPersonnel(people);

// System.debug output appears in the command output or Apex logs.
for (Integer i = 0; i < results.size(); i++) {
    Database.UpsertResult result = results[i];
    System.debug(
        'Personnel upsert ' + people[i].Employee_Id__c
        + ' success=' + result.isSuccess()
        + ' id=' + result.getId()
        + ' created=' + result.isCreated()
    );
    if (!result.isSuccess()) {
        System.debug(result.getErrors());
    }
}
