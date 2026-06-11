# Personnel Tracker Walkthrough

This guide walks through the project as a learning exercise. It assumes you know programming concepts from TypeScript or Python and want to understand how those ideas show up in Salesforce Apex.

Use this order:

1. Deploy metadata.
2. Run anonymous Apex like a REPL.
3. Trace the service and selector classes.
4. Learn the trigger path.
5. Run the tests.
6. Run Batch Apex.
7. Make one guided change.
8. Add a Lightning Web Component UI.
9. Study SOQL as its own skill.
10. Use Dreamforce themes as a compass for what to add next.

## Mental Model

Apex is not a standalone app server. Your code runs inside Salesforce transactions. That changes how you design:

- Records are `sObject` instances, such as `Personnel__c`.
- Database reads use SOQL.
- Database writes use DML.
- One transaction may contain 1 record or 200 records.
- Governor limits reward bulk-safe code.
- Tests create their own data and do not use production records by default.

If you come from TypeScript or Python, map the files this way:

| Familiar idea | Apex project file |
| --- | --- |
| Repository or DAO | `PersonnelSelector.cls` |
| Service layer | `PersonnelService.cls`, `PersonnelAssignmentService.cls` |
| Event hook | `PersonnelTrigger.trigger` |
| Event handler | `PersonnelTriggerHandler.cls` |
| Background job | `PersonnelReviewBatch.cls` |
| Fixtures/factories | `PersonnelTestDataFactory.cls` |
| Small REPL scripts | `scripts/apex/*.apex` |
| Salesforce UI component | `lwc/personnelDashboard` |

## Setup Checkpoint

Install the Salesforce CLI and authenticate an org:

```bash
sf org login web --alias PersonnelDev --set-default
```

Deploy the source:

```bash
sf project deploy start --source-dir force-app
sf org assign permset --name Personnel_Sample_Admin
```

Open the org:

```bash
sf org open
```

Checkpoint:

- In Object Manager, find `Personnel`.
- Confirm fields such as `Employee ID`, `Department`, `Review Status`, and `Manager`.
- Confirm `Personnel Assignment` has a lookup to `Personnel`.

## Walkthrough 1: Metadata Is Source Code

Read:

- `force-app/main/default/objects/Personnel__c/Personnel__c.object-meta.xml`
- `force-app/main/default/objects/Personnel__c/fields/Employee_Id__c.field-meta.xml`
- `force-app/main/default/objects/Personnel__c/validationRules/Termination_Date_Required.validationRule-meta.xml`

What to notice:

- `Personnel__c` is a custom object.
- `Employee_Id__c` is marked as an external ID and unique field.
- Validation rules live in source control like Apex code.
- The project avoids SSNs, birth dates, and compensation fields because sample HR data should not normalize collecting sensitive data.

Exercise:

1. Add a picklist value to `Department__c`.
2. Deploy again.
3. Check the field in Object Manager.

## Walkthrough 2: Anonymous Apex As A REPL

Run:

```bash
sf apex run --file scripts/apex/01_insert_sample_personnel.apex
```

Trace this path:

```text
01_insert_sample_personnel.apex
  -> PersonnelService.upsertPersonnel(...)
    -> PersonnelService.normalizeForSave(...)
    -> PersonnelSelector.selectByEmployeeIds(...)
    -> Database.upsert(...)
      -> PersonnelTrigger.before insert/before update
        -> PersonnelTriggerHandler.beforeInsert/beforeUpdate(...)
```

What to notice:

- The script creates three `Personnel__c` records in memory.
- The service accepts a list, not a single record. This is intentional.
- The service normalizes email and default picklist fields before DML.
- The selector performs one SOQL query for all employee IDs.
- DML runs once for the whole list.
- The trigger runs automatically because DML happened.

Checkpoint query:

```bash
sf data query --query "SELECT Employee_Id__c, Display_Name__c, Email__c, Review_Status__c FROM Personnel__c WHERE Employee_Id__c LIKE 'SAMPLE-%'"
```

Exercise:

1. Change `ADA.LOVELACE@example.com` to another mixed-case email.
2. Run the script again.
3. Query the record.
4. Confirm the email is lowercased and no duplicate record was created.

## Walkthrough 3: SOQL Belongs In Selectors

Run:

```bash
sf apex run --file scripts/apex/02_query_headcount.apex
sf apex run --file scripts/apex/06_soql_practice.apex
```

Read:

- `docs/soql-guide.md`
- `force-app/main/default/classes/PersonnelSelector.cls`
- `force-app/main/default/classes/PersonnelService.cls`

What to notice:

- Selector methods return records and hide query details.
- Service methods express business intent, such as `findActiveByDepartment`.
- `summarizeActiveHeadcount` uses `AggregateResult`, which is Apex's way to work with grouped SOQL results.
- Relationship queries use Salesforce relationship names such as `Assignments__r` and `Personnel__r`.
- Bind variables such as `:department` keep filter values separate from query structure.

Exercise:

Add a selector method:

```apex
public static List<Personnel__c> selectByClearanceLevel(String clearanceLevel) {
    if (String.isBlank(clearanceLevel)) {
        return new List<Personnel__c>();
    }

    return [
        SELECT Id, Employee_Id__c, Display_Name__c, Clearance_Level__c
        FROM Personnel__c
        WHERE Clearance_Level__c = :clearanceLevel
        ORDER BY Last_Name__c, First_Name__c
    ];
}
```

Then call it from a new anonymous Apex script.

## Walkthrough 4: Services Own Business Rules

Run:

```bash
sf apex run --file scripts/apex/03_create_assignments.apex
```

Read:

- `PersonnelAssignmentService.createAssignment`
- `PersonnelAssignmentService.createAssignmentForDepartment`
- `PersonnelAssignmentService.closeOpenAssignments`

What to notice:

- The service rejects assignments for inactive personnel.
- The department method creates many assignments with one insert.
- Closing assignments queries open work once and updates records as a collection.

Exercise:

Add a policy: assignments cannot exceed 40 hours per week.

Suggested order:

1. Add a failing test to `PersonnelAssignmentServiceTest`.
2. Run only that test class.
3. Add the validation to `PersonnelAssignmentService`.
4. Re-run the test class.

The point is not just coverage. The point is to let tests describe the rule before production code changes.

## Walkthrough 5: One Thin Trigger

Read:

- `force-app/main/default/triggers/PersonnelTrigger.trigger`
- `force-app/main/default/classes/PersonnelTriggerHandler.cls`

What to notice:

- The trigger has no business logic.
- The handler has one method per trigger context.
- The handler calls the service for normalization.
- `addError` blocks a save inside the current transaction.

Run:

```bash
sf apex run test --class-names PersonnelTriggerHandlerTest --result-format human --wait 10
```

Exercise:

Add a rule that only terminated records may have `Termination_Date__c`.

Think through the logic:

```text
If Status__c != 'Terminated' and Termination_Date__c is not blank,
block the save with addError.
```

Add both tests:

- Active record with no termination date succeeds.
- Active record with a termination date fails.

## Walkthrough 6: Bulk Safety

Read:

- `PersonnelServiceTest.upsertPersonnel_handlesTwoHundredRecords`
- `PersonnelService.upsertPersonnel`

What to notice:

- The test creates 200 records because Salesforce may pass trigger records in chunks of up to 200.
- `Set<String>` gathers keys.
- `Map<String, Id>` stores existing records.
- SOQL and DML are outside loops.

Run:

```bash
sf apex run test --class-names PersonnelServiceTest --result-format human --wait 10
```

Exercise:

Change the test to 201 records. It should still pass because the service does not depend on a single-record path.

## Walkthrough 7: Batch Apex

Run:

```bash
sf apex run --file scripts/apex/05_run_review_batch.apex
```

Read:

- `PersonnelReviewBatch.start`
- `PersonnelReviewBatch.execute`
- `PersonnelReviewBatch.finish`
- `PersonnelReviewBatch.calculateReviewStatus`
- `PersonnelReviewBatchTest.runNow_updatesReviewStatusInAsyncBatch`

What to notice:

- `start` finds the records.
- `execute` processes one batch scope.
- `finish` is empty now, but this is where notifications or logging often go.
- `Test.startTest()` and `Test.stopTest()` force async work to complete during tests.

Exercise:

Change the review policy:

- `Current`: reviewed within 180 days.
- `Due Soon`: reviewed between 181 and 240 days.
- `Overdue`: reviewed after 240 days or never reviewed.

Update the test first, then update `calculateReviewStatus`.

## Walkthrough 8: Cleanup

Run:

```bash
sf apex run --file scripts/apex/99_cleanup_sample_data.apex
```

What to notice:

- It deletes assignments before deleting personnel.
- It only targets sample IDs with `SAMPLE-%` or `BULK-%`.
- Cleanup scripts should be narrow and obvious.

## Walkthrough 9: Lightning UI

Read:

- `docs/lightning-ui-walkthrough.md`
- `force-app/main/default/lwc/personnelDashboard/personnelDashboard.html`
- `force-app/main/default/lwc/personnelDashboard/personnelDashboard.js`
- `force-app/main/default/classes/PersonnelDashboardController.cls`

What to notice:

- The LWC uses `@wire` to read cacheable dashboard data.
- The LWC uses imperative Apex to create assignments from a button click.
- The Apex controller returns UI-friendly DTOs instead of raw domain internals.
- The `.js-meta.xml` file exposes the component to Lightning App Builder.

Run:

```bash
sf project deploy start --source-dir force-app
sf apex run test --class-names PersonnelDashboardControllerTest --result-format human --wait 10
```

Then add `Personnel Dashboard` to a Lightning App Page in Lightning App Builder.

## Common Apex Terms

| Term | Meaning |
| --- | --- |
| sObject | Generic Salesforce record type. `Personnel__c` is a custom sObject. |
| SOQL | Salesforce Object Query Language, used to read records. |
| DML | Insert, update, upsert, delete, and undelete operations. |
| Trigger | Code that runs automatically before or after DML. |
| Governor limits | Per-transaction resource limits that shape Apex design. |
| Batch Apex | Async processing for large record sets. |
| Test.startTest | Resets limits and starts async test capture. |
| Test.stopTest | Runs queued async work before assertions. |

## Suggested Next Build

Build `PersonnelSkill__c`:

1. Create a child object with `Personnel__c`, `Skill_Name__c`, `Skill_Level__c`, and `Verified_Date__c`.
2. Add `PersonnelSkillService.assignSkills`.
3. Add a selector method for skill lookup.
4. Add tests for one record, many records, and duplicate skill prevention.
5. Add an anonymous Apex script that assigns skills to the sample personnel.

That extension repeats the same pattern in a new domain, which is the fastest way to make Apex feel less mysterious.

## Dreamforce Compass

Dreamforce 2026 is framed around the Agentic Enterprise, with official agenda themes around Agentforce, Slack, Data 360, secure AI, and hands-on training. Do not let that pull you away from fundamentals too early. Use `docs/dreamforce-learning-notes.md` to translate conference themes into small Salesforce developer exercises.
