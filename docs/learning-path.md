# Learning Path

Use this project like a small course. Each step has a file to read, a command to run, and a change to try.

## 1. Deploy Metadata First

Read:

- `sfdx-project.json`
- `force-app/main/default/objects/Personnel__c/Personnel__c.object-meta.xml`
- `force-app/main/default/objects/Personnel__c/fields/Employee_Id__c.field-meta.xml`

Run:

```bash
sf project deploy start --source-dir force-app
```

Try:

- Add a new picklist value to `Department__c`.
- Deploy again.
- Observe how metadata changes are source-controlled just like code.

## 2. Use Anonymous Apex As A REPL

Read:

- `scripts/apex/01_insert_sample_personnel.apex`
- `force-app/main/default/classes/PersonnelService.cls`

Run:

```bash
sf apex run --file scripts/apex/01_insert_sample_personnel.apex
```

Try:

- Change an email to mixed case.
- Run the script again.
- Query the record and notice the trigger/service normalization.

## 3. Learn SOQL Through A Selector

Read:

- `force-app/main/default/classes/PersonnelSelector.cls`
- `scripts/apex/02_query_headcount.apex`

Run:

```bash
sf apex run --file scripts/apex/02_query_headcount.apex
```

Try:

- Add a selector method that finds personnel by clearance level.
- Call that method from an anonymous Apex script.

## 4. Keep Business Logic In Services

Read:

- `force-app/main/default/classes/PersonnelAssignmentService.cls`
- `scripts/apex/03_create_assignments.apex`

Run:

```bash
sf apex run --file scripts/apex/03_create_assignments.apex
```

Try:

- Add a rule that rejects assignments above 40 hours per week.
- Write a negative test before changing the service.

## 5. Use One Thin Trigger

Read:

- `force-app/main/default/triggers/PersonnelTrigger.trigger`
- `force-app/main/default/classes/PersonnelTriggerHandler.cls`
- `force-app/main/default/classes/PersonnelTriggerHandlerTest.cls`

Run:

```bash
sf apex run test --class-names PersonnelTriggerHandlerTest --result-format human --wait 10
```

Try:

- Add a guard that prevents setting a termination date unless status is `Terminated`.
- Test both allowed and rejected cases.

## 6. Practice Bulk Safety

Read:

- `force-app/main/default/classes/PersonnelServiceTest.cls`

Run:

```bash
sf apex run test --class-names PersonnelServiceTest --result-format human --wait 10
```

Try:

- Change the 200-record test to 201 records.
- Keep the service code bulk-safe by avoiding SOQL or DML inside loops.

## 7. Learn Batch Apex After Bulk Apex

Read:

- `force-app/main/default/classes/PersonnelReviewBatch.cls`
- `force-app/main/default/classes/PersonnelReviewBatchTest.cls`
- `scripts/apex/05_run_review_batch.apex`

Run:

```bash
sf apex run --file scripts/apex/05_run_review_batch.apex
sf apex run test --class-names PersonnelReviewBatchTest --result-format human --wait 10
```

Try:

- Change the review thresholds from 300/365 days to your preferred policy.
- Update `calculateReviewStatus_returnsExpectedValues` first, watch it fail, then update the batch class.

## 8. Add A Lightning UI

Read:

- `docs/lightning-ui-walkthrough.md`
- `force-app/main/default/lwc/personnelDashboard/personnelDashboard.html`
- `force-app/main/default/lwc/personnelDashboard/personnelDashboard.js`
- `force-app/main/default/classes/PersonnelDashboardController.cls`

Run:

```bash
sf project deploy start --source-dir force-app
sf apex run --file scripts/apex/01_insert_sample_personnel.apex
sf apex run --file scripts/apex/03_create_assignments.apex
sf apex run test --class-names PersonnelDashboardControllerTest --result-format human --wait 10
```

Try:

- Add the `Personnel Dashboard` component to a Lightning App Page.
- Change the default department property in Lightning App Builder.
- Add a client-side review-status filter.

## 9. Add Quality Tooling Later

Once the sample deploys and tests pass, add one quality tool at a time:

- Salesforce Code Analyzer or PMD for static checks.
- Prettier for metadata and formatting.
- CI commands that deploy to a scratch org and run the Apex tests.

Start with behavior and deployability. Tooling makes more sense after the loop is familiar.
