# Lightning UI Walkthrough

This guide adds the UI layer to the personnel tracker. It focuses on Lightning Web Components (LWC), the modern Salesforce UI framework.

The example component is:

```text
force-app/main/default/lwc/personnelDashboard
```

It works with:

```text
force-app/main/default/classes/PersonnelDashboardController.cls
```

## What This UI Teaches

- How an LWC bundle is organized.
- How to expose a component to Lightning App Builder.
- How to call Apex with `@wire` for cacheable reads.
- How to call Apex imperatively for button-driven writes.
- How to use Lightning base components such as `lightning-card`, `lightning-combobox`, `lightning-datatable`, `lightning-input`, and `lightning-button`.
- How UI-specific Apex DTOs differ from domain service classes.

## File Map

| File | Purpose |
| --- | --- |
| `personnelDashboard.html` | Template. Defines the card, filters, metrics, tables, and assignment form. |
| `personnelDashboard.js` | Client-side state and behavior. Wires dashboard data and calls Apex when saving. |
| `personnelDashboard.css` | Small component-scoped styling layer. |
| `personnelDashboard.js-meta.xml` | Exposes the component to App, Home, and Record pages. |
| `PersonnelDashboardController.cls` | UI controller that returns LWC-friendly wrapper objects. |
| `PersonnelDashboardControllerTest.cls` | Apex tests for dashboard data and assignment creation. |

## Deploy And Add The Component

Deploy the project:

```bash
sf project deploy start --source-dir force-app
sf org assign permset --name Personnel_Sample_Admin
```

Seed sample data:

```bash
sf apex run --file scripts/apex/01_insert_sample_personnel.apex
sf apex run --file scripts/apex/03_create_assignments.apex
```

Open Lightning App Builder:

1. In Salesforce Setup, search for `Lightning App Builder`.
2. Create a new App Page.
3. Name it `Personnel Dashboard`.
4. Drag the custom component `Personnel Dashboard` onto the page.
5. Save and activate it.

The component is also exposed for Home Pages and Record Pages, so you can place it in more than one UI context while learning.

## Read Path

Start in `personnelDashboard.js`.

The read path is:

```text
@wire(getDashboardData, { departmentFilter: '$selectedDepartment' })
  -> PersonnelDashboardController.getDashboardData(...)
    -> PersonnelService.findActiveByDepartment(...)
    -> PersonnelSelector.selectByDepartment(...)
    -> SOQL
```

Why this pattern:

- The LWC owns browser state such as the selected department.
- The controller owns UI-shaped data.
- The service owns business behavior.
- The selector owns SOQL.

The Apex method is annotated:

```apex
@AuraEnabled(cacheable=true)
public static DashboardData getDashboardData(String departmentFilter)
```

That makes it eligible for LWC `@wire` and client-side caching.

## Write Path

The assignment button uses imperative Apex:

```text
handleCreateAssignment()
  -> createAssignment({ request: { ... } })
    -> PersonnelDashboardController.createAssignment(...)
      -> PersonnelAssignmentService.createAssignment(...)
      -> DML insert
```

Why this pattern:

- Writes should happen only when the user clicks a button.
- Imperative Apex returns a Promise.
- After the write succeeds, the component calls `refreshApex(...)` to reload the wired dashboard.

## UI Concepts To Notice

### Component Bundle

Salesforce expects the folder and files to share the same name:

```text
personnelDashboard/
  personnelDashboard.html
  personnelDashboard.js
  personnelDashboard.css
  personnelDashboard.js-meta.xml
```

### Lightning Base Components

The HTML uses base components instead of hand-building controls:

- `lightning-card`
- `lightning-combobox`
- `lightning-datatable`
- `lightning-input`
- `lightning-button`
- `lightning-spinner`

Base components inherit Salesforce Lightning Design System behavior and are the normal starting point for Salesforce UI development.

### Builder Configuration

The `.js-meta.xml` file exposes the component:

```xml
<isExposed>true</isExposed>
<targets>
    <target>lightning__AppPage</target>
    <target>lightning__HomePage</target>
    <target>lightning__RecordPage</target>
</targets>
```

It also defines a builder property:

```xml
<property name="defaultDepartment" type="String" label="Default Department" default="All"/>
```

That property maps to this JavaScript API field:

```js
@api defaultDepartment = 'All';
```

## Exercises

### Exercise 1: Add A Review Filter

Goal: filter the personnel table by review status.

Suggested path:

1. Add `selectedReviewStatus` to `personnelDashboard.js`.
2. Add a second `lightning-combobox` to the template.
3. Filter the `personnelRows` getter client-side.
4. Keep the Apex query unchanged.

This teaches client-side state and derived data.

### Exercise 2: Add A Record Link

Goal: make each personnel row link to the Salesforce record.

Suggested path:

1. Add a `recordUrl` field to `PersonnelRow`.
2. Set it to `'/' + person.Id`.
3. Add a URL column in `PERSONNEL_COLUMNS`.

This teaches datatable column types and record navigation.

### Exercise 3: Replace Hardcoded Picklists

Goal: load department and assignment type values from metadata.

Suggested path:

1. Learn `getObjectInfo` and `getPicklistValues`.
2. Import `Personnel__c` and `Department__c` schema references.
3. Replace `departmentOptions` with metadata-backed options.

This teaches Lightning Data Service and UI API.

### Exercise 4: Add Jest Tests Later

This repo currently focuses on Salesforce deployable source and Apex tests. A natural next step is to add the LWC Jest toolchain and test:

- Department changes call the wired Apex method with a new parameter.
- Row selection enables the Create Assignment button.
- Successful assignment save calls `refreshApex`.

## References

- [Lightning Web Components Developer Guide](https://developer.salesforce.com/docs/platform/lwc/guide)
- [Component Folder](https://developer.salesforce.com/docs/platform/lwc/guide/create-components-folder.html)
- [XML Configuration File Elements](https://developer.salesforce.com/docs/platform/lwc/guide/reference-configuration-tags.html)
- [Call Apex Methods](https://developer.salesforce.com/docs/platform/lwc/guide/apex.html)
- [Wire Apex Methods](https://developer.salesforce.com/docs/platform/lwc/guide/apex-wire-method.html)
- [Call Apex Imperatively](https://developer.salesforce.com/docs/platform/lwc/guide/apex-call-imperative.html)
- [Lightning Data Service](https://developer.salesforce.com/docs/platform/lwc/guide/data-ui-api.html)
- [Lightning Base Components](https://developer.salesforce.com/docs/platform/lwc/guide/base-components-all.html)
