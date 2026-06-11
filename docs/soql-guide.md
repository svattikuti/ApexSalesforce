# SOQL Guide For JavaScript And Python Developers

This guide teaches SOQL through the personnel tracker project. It assumes you already know how to filter arrays, query SQL tables, or call an ORM, and want to understand how Salesforce data access feels different.

Read this with these files open:

- `force-app/main/default/classes/PersonnelSelector.cls`
- `force-app/main/default/classes/PersonnelService.cls`
- `scripts/apex/02_query_headcount.apex`
- `scripts/apex/06_soql_practice.apex`

## The Mental Model

SOQL is Salesforce Object Query Language. It reads records from Salesforce objects such as `Personnel__c` and `Personnel_Assignment__c`.

| If you know... | Think of SOQL as... | Important difference |
| --- | --- | --- |
| SQL | `SELECT` queries over Salesforce objects | No arbitrary joins, no `SELECT *`, and relationship traversal uses Salesforce relationship names. |
| TypeScript arrays | A server-side filter/map before data reaches Apex or LWC | You must select every field you plan to read. |
| Python ORMs | A query layer over records | Apex has governor limits, so query once for collections instead of querying inside loops. |
| REST APIs | A shape contract for returned data | The selected fields are the shape. Missing fields throw runtime errors when accessed. |

SOQL is not a general SQL dialect. It is optimized around Salesforce metadata, sharing, relationships, and multitenant limits.

## Where SOQL Lives In This Project

Most SOQL belongs in selector classes:

```apex
public with sharing class PersonnelSelector {
    public static List<Personnel__c> selectByEmployeeIds(Set<String> employeeIds) {
        if (employeeIds == null || employeeIds.isEmpty()) {
            return new List<Personnel__c>();
        }

        return [
            SELECT Id, Employee_Id__c, Display_Name__c, Department__c, Status__c
            FROM Personnel__c
            WHERE Employee_Id__c IN :employeeIds
            ORDER BY Last_Name__c, First_Name__c
        ];
    }
}
```

The service layer calls selectors. Anonymous Apex scripts call services or selectors while you learn. Lightning controllers should call services and return UI-friendly DTOs.

```text
LWC or script
  -> Apex controller or service
    -> selector
      -> SOQL
```

## Run The Practice Script

Seed the sample data first:

```bash
sf apex run --file scripts/apex/01_insert_sample_personnel.apex
sf apex run --file scripts/apex/03_create_assignments.apex
```

Then run the SOQL practice script:

```bash
sf apex run --file scripts/apex/06_soql_practice.apex
```

It demonstrates:

- Basic `SELECT ... FROM ... WHERE ... ORDER BY`.
- Apex bind variables with `:variableName`.
- Parent-to-child relationship queries with `Assignments__r`.
- Child-to-parent relationship queries with `Personnel__r`.
- Aggregate queries with `GROUP BY`.
- SOQL for-loops for chunked iteration.

## Basic Query Shape

SOQL follows this basic order:

```sql
SELECT fields
FROM ObjectName
WHERE conditions
ORDER BY fields
LIMIT numberOfRows
```

Project example:

```apex
List<Personnel__c> engineers = [
    SELECT Id, Employee_Id__c, Display_Name__c, Department__c, Role__c
    FROM Personnel__c
    WHERE Department__c = 'Engineering'
        AND Status__c = 'Active'
    ORDER BY Last_Name__c, First_Name__c
    LIMIT 50
];
```

Things to notice:

- Custom objects end in `__c`.
- Custom fields end in `__c`.
- You list fields explicitly. There is no normal `SELECT *`.
- If you access a field that was not selected, Apex can throw an `SObject row was retrieved via SOQL without querying the requested field` error.
- Always add `ORDER BY` when row order matters.

## Bind Variables

Do not build query strings when inline SOQL can use bind variables.

```apex
String department = 'Engineering';
Set<String> statuses = new Set<String>{ 'Active', 'On Leave' };

List<Personnel__c> people = [
    SELECT Id, Employee_Id__c, Display_Name__c, Status__c
    FROM Personnel__c
    WHERE Department__c = :department
        AND Status__c IN :statuses
];
```

This is similar to parameterized SQL in Python or prepared statements in other stacks. It also keeps your code safer than concatenating user input into dynamic SOQL.

## Relationship Queries

Salesforce relationships are metadata. You do not join arbitrary tables. You either go from parent to child with a nested query or from child to parent with dot notation.

### Parent To Child

`Personnel_Assignment__c.Personnel__c` defines a lookup relationship to `Personnel__c`. Its child relationship name is `Assignments`, so the parent-to-child relationship is `Assignments__r`.

```apex
List<Personnel__c> peopleWithAssignments = [
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
];
```

Use this when the main thing you are listing is the parent, and the child rows are supporting detail.

### Child To Parent

From the assignment object, use `Personnel__r` to reach fields on the parent personnel record.

```apex
List<Personnel_Assignment__c> assignments = [
    SELECT Assignment_Name__c, Status__c, Personnel__r.Display_Name__c
    FROM Personnel_Assignment__c
    WHERE Status__c = 'Active'
    ORDER BY Start_Date__c DESC
];
```

Use this when the main thing you are listing is the child record.

## Aggregate Queries

Aggregate queries return `AggregateResult`, not normal sObjects.

```apex
for (AggregateResult row : [
    SELECT Department__c department, COUNT(Id) activePersonnel
    FROM Personnel__c
    WHERE Status__c = 'Active'
    GROUP BY Department__c
    ORDER BY Department__c
]) {
    String department = (String) row.get('department');
    Integer countPeople = (Integer) row.get('activePersonnel');
    System.debug(department + ': ' + countPeople);
}
```

This is close to SQL `GROUP BY`, but aliases matter because you pull values out with `row.get('alias')`.

## SOQL For-Loops

When you expect many records, a SOQL for-loop lets Salesforce retrieve records in chunks.

```apex
for (List<Personnel__c> scope : [
    SELECT Id, Employee_Id__c, Review_Status__c
    FROM Personnel__c
    WHERE Status__c = 'Active'
]) {
    System.debug('Chunk size: ' + scope.size());
}
```

The list form is useful because you can do bulk work per chunk. That maps nicely to Python batch processing or JavaScript pagination, except Salesforce manages the query cursor for you.

## Bulk-Safe Query Pattern

Do this:

```apex
Set<String> employeeIds = new Set<String>();
for (Personnel__c person : incomingPeople) {
    employeeIds.add(person.Employee_Id__c);
}

Map<String, Personnel__c> existingByEmployeeId = new Map<String, Personnel__c>();
for (Personnel__c existing : PersonnelSelector.selectByEmployeeIds(employeeIds)) {
    existingByEmployeeId.put(existing.Employee_Id__c, existing);
}
```

Avoid this:

```apex
for (Personnel__c person : incomingPeople) {
    Personnel__c existing = [
        SELECT Id, Employee_Id__c
        FROM Personnel__c
        WHERE Employee_Id__c = :person.Employee_Id__c
        LIMIT 1
    ];
}
```

The second version burns one query per record. In Salesforce, that is how code hits governor limits. The first version gathers keys, queries once, and uses a map.

## Security Habits For SOQL

There are three different concerns that new Salesforce programmers often blend together:

| Concern | What it controls | Project status |
| --- | --- | --- |
| Sharing | Which records the current user can see | Classes use `with sharing` as the baseline. |
| CRUD/FLS | Which objects and fields the user can access | A future improvement should add user-mode reads/writes or `stripInaccessible` to the UI controller. |
| Injection | Whether user input can alter query structure | Inline SOQL with bind variables is the default pattern in this project. |

When you later build dynamic SOQL, whitelist object names, field names, sort directions, and filter operators. Bind variables protect values, not arbitrary query fragments.

## How To Practice

1. Run `01_insert_sample_personnel.apex`.
2. Run `06_soql_practice.apex`.
3. Add a selector method named `selectByClearanceLevel`.
4. Add an anonymous Apex script that calls it for `Secret`.
5. Add a test that inserts three people with different clearance levels and asserts the selector returns only matching records.
6. Refactor duplicate field lists only if the duplication starts making changes error-prone.

## Recent Resources Checked

These resources shaped this guide:

- [Trailhead: Write SOQL Queries](https://trailhead.salesforce.com/content/learn/modules/apex_database/apex_database_soql) - current Trailhead unit checked on 2026-06-11. It covers inline SOQL, binds, relationships, and SOQL for-loops.
- [LWC Developer Guide: Call Apex Methods](https://developer.salesforce.com/docs/platform/lwc/guide/apex.html) - current Salesforce docs checked on 2026-06-11. It explains that LWCs can call Apex with `@wire` or imperatively and that Apex limits apply per invocation.
- [LWC Developer Guide: API Versioning](https://developer.salesforce.com/docs/platform/lwc/guide/get-started-api-versioning.html) - current Salesforce docs checked on 2026-06-11. It notes LWC API versioning support beginning in Winter '24 and required component versioning beginning in Spring '25.
- [trailheadapps/apex-recipes](https://github.com/trailheadapps/apex-recipes) - official sample repo checked through the GitHub API on 2026-06-11; pushed 2026-06-02 and updated 2026-06-07.
- [trailheadapps/lwc-recipes](https://github.com/trailheadapps/lwc-recipes) - official sample repo checked through the GitHub API on 2026-06-11; pushed 2026-06-03 and updated 2026-06-11.

Use official docs for syntax and platform rules. Use the recipe repos after this project feels comfortable, because they are broader reference libraries rather than guided lessons.
