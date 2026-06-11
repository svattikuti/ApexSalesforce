# Personnel Apex Sample Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Salesforce DX learning project for tracking personnel data with custom metadata, Apex service classes, trigger handling, batch processing, tests, and runnable VS Code anonymous Apex scripts.

**Architecture:** The sample uses a small HR-style domain with `Personnel__c` as the parent record and `Personnel_Assignment__c` as a child record. Apex is split into service classes for business logic, a trigger handler for record lifecycle rules, a batch/scheduler for review status maintenance, and test classes that demonstrate Apex testing patterns.

**Tech Stack:** Salesforce DX source format, Apex, SOQL, DML, Apex tests, Batch Apex, Schedulable Apex, anonymous Apex scripts, VS Code Salesforce extensions.

---

### Task 1: Project Structure

**Files:**
- Create: `sfdx-project.json`
- Create: `.forceignore`
- Create: `.vscode/extensions.json`
- Create: `.vscode/settings.json`
- Create: `config/project-scratch-def.json`
- Create: `manifest/package.xml`

- [x] Create Salesforce DX and VS Code configuration files.
- [x] Verify JSON files parse with `python3 -m json.tool`.

### Task 2: Metadata Model

**Files:**
- Create: `force-app/main/default/objects/Personnel__c/Personnel__c.object-meta.xml`
- Create: `force-app/main/default/objects/Personnel__c/fields/*.field-meta.xml`
- Create: `force-app/main/default/objects/Personnel__c/validationRules/*.validationRule-meta.xml`
- Create: `force-app/main/default/objects/Personnel_Assignment__c/Personnel_Assignment__c.object-meta.xml`
- Create: `force-app/main/default/objects/Personnel_Assignment__c/fields/*.field-meta.xml`
- Create: `force-app/main/default/objects/Personnel_Assignment__c/validationRules/*.validationRule-meta.xml`
- Create: `force-app/main/default/permissionsets/Personnel_Sample_Admin.permissionset-meta.xml`

- [x] Add deployable custom objects, fields, validation rules, and permissions.
- [x] Verify XML metadata is well-formed.

### Task 3: Apex Domain Logic

**Files:**
- Create: `force-app/main/default/classes/PersonnelService.cls`
- Create: `force-app/main/default/classes/PersonnelSelector.cls`
- Create: `force-app/main/default/classes/PersonnelAssignmentService.cls`
- Create: `force-app/main/default/classes/PersonnelTriggerHandler.cls`
- Create: `force-app/main/default/triggers/PersonnelTrigger.trigger`
- Create: `force-app/main/default/classes/PersonnelReviewBatch.cls`

- [x] Add bulk-safe Apex service and trigger patterns.
- [x] Add Batch Apex and Schedulable Apex for review status refreshes.

### Task 4: Apex Tests

**Files:**
- Create: `force-app/main/default/classes/PersonnelTestDataFactory.cls`
- Create: `force-app/main/default/classes/PersonnelServiceTest.cls`
- Create: `force-app/main/default/classes/PersonnelTriggerHandlerTest.cls`
- Create: `force-app/main/default/classes/PersonnelAssignmentServiceTest.cls`
- Create: `force-app/main/default/classes/PersonnelReviewBatchTest.cls`

- [x] Add tests that teach Arrange-Act-Assert, `Test.startTest()`, async verification, and negative-save assertions.
- [ ] Run Apex tests in a Salesforce org when one is authorized and Salesforce CLI is installed.

### Task 5: Learning Scripts and Docs

**Files:**
- Create: `scripts/apex/*.apex`
- Create: `README.md`
- Create: `docs/learning-path.md`

- [x] Add anonymous Apex scripts for insert, query, update, batch, and cleanup workflows.
- [x] Add learning documentation with official Salesforce links and extension workflow commands.

### Task 6: Verification

- [x] Parse JSON and XML locally.
- [x] Check expected files exist.
- [ ] If Salesforce CLI and an org are available, run a deploy validation and Apex tests.
