# Apex Personnel Tracker Sample

This is a Salesforce DX learning project for tracking personnel data in Salesforce. It includes deployable custom objects, Apex service classes, a trigger handler, Batch Apex, unit tests, anonymous Apex scripts, and a small CSV seed file.

The project is intentionally heavier than a snippet collection because it is meant for someone who already knows TypeScript or Python and wants to learn how Apex projects are organized in VS Code.

## What You Will Learn

- Salesforce DX project layout: `force-app`, `config`, `manifest`, `scripts/apex`, and `.vscode`.
- Custom metadata: objects, fields, formulas, validation rules, and permission sets.
- Apex basics: sObjects, SOQL, DML, exceptions, static methods, and inner classes.
- Apex architecture: selector, service, trigger handler, one thin trigger, and batch processing.
- Bulk-safe thinking: methods accept lists/sets and tests include a 200-record path.
- Tests: `@IsTest`, factories, positive tests, negative tests, async tests, and assertions.

## Project Map

| Path | Purpose |
| --- | --- |
| `force-app/main/default/objects/Personnel__c` | Parent personnel object and fields. |
| `force-app/main/default/objects/Personnel_Assignment__c` | Child assignment object and relationship to personnel. |
| `force-app/main/default/classes/PersonnelSelector.cls` | SOQL read layer, similar to a repository in other stacks. |
| `force-app/main/default/classes/PersonnelService.cls` | Personnel business operations: upsert, query, summarize, terminate. |
| `force-app/main/default/classes/PersonnelAssignmentService.cls` | Assignment creation and closeout behavior. |
| `force-app/main/default/classes/PersonnelTriggerHandler.cls` | Trigger lifecycle rules and normalization. |
| `force-app/main/default/triggers/PersonnelTrigger.trigger` | Thin trigger that delegates to the handler. |
| `force-app/main/default/classes/PersonnelReviewBatch.cls` | Batch and schedulable Apex example. |
| `force-app/main/default/classes/*Test.cls` | Behavior-focused Apex tests. |
| `scripts/apex` | Anonymous Apex scripts you can run from VS Code or the Salesforce CLI. |
| `data/personnel-sample.csv` | Optional CSV seed data for bulk upsert practice. |

## Setup

Install:

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Salesforce Extensions for VS Code](https://developer.salesforce.com/tools/vscode/en/getting-started/install)

Authorize an org you can deploy to:

```bash
sf org login web --alias PersonnelDev --set-default
```

If you have Dev Hub enabled and want a scratch org:

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias PersonnelScratch --set-default --duration-days 7
```

Deploy the project:

```bash
sf project deploy start --source-dir force-app
sf org assign permset --name Personnel_Sample_Admin
sf org open
```

## Run the Scripts

From a terminal:

```bash
sf apex run --file scripts/apex/01_insert_sample_personnel.apex
sf apex run --file scripts/apex/02_query_headcount.apex
sf apex run --file scripts/apex/03_create_assignments.apex
sf apex run --file scripts/apex/05_run_review_batch.apex
```

From VS Code:

1. Open a file in `scripts/apex`.
2. Use the Command Palette.
3. Run `SFDX: Execute Anonymous Apex with Currently Selected Text` or `SFDX: Execute Anonymous Apex with Editor Contents`.

Optional CSV upsert:

```bash
sf data upsert bulk --sobject Personnel__c --file data/personnel-sample.csv --external-id Employee_Id__c --wait 10
```

## Run Tests

```bash
sf apex run test \
  --class-names PersonnelServiceTest,PersonnelTriggerHandlerTest,PersonnelAssignmentServiceTest,PersonnelReviewBatchTest \
  --result-format human \
  --code-coverage \
  --wait 10
```

Salesforce requires at least 75% Apex coverage for deployment, but that is only a minimum gate. The tests here are written to verify behavior and teach patterns.

## How To Improve This

- Add a `PersonnelSkill__c` object and write a service that assigns skills in bulk.
- Add restricted-user tests to learn sharing and CRUD/FLS checks.
- Add a Queueable Apex class that sends a follow-up task after personnel termination.
- Replace the simple selector with a more formal enterprise pattern after the basics feel natural.
- Add PMD or Salesforce Code Analyzer rules once the project is deployed and tests are passing.

## References

- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm)
- [Salesforce Extensions for VS Code](https://developer.salesforce.com/tools/vscode)
- [Trailhead: Apex Basics and Database](https://trailhead.salesforce.com/content/learn/modules/apex_database)
- [Trailhead: Apex Triggers](https://trailhead.salesforce.com/content/learn/modules/apex_triggers)
- [Trailhead: Apex Testing](https://trailhead.salesforce.com/content/learn/modules/apex_testing)
- [Trailhead: Asynchronous Apex](https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex)
- [Apex Recipes](https://github.com/trailheadapps/apex-recipes)
