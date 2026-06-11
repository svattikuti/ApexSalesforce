public with sharing class PersonnelService {
    public class PersonnelException extends Exception {
    }

    // Small DTO used by scripts or UI layers that need aggregate headcount data
    // without receiving raw AggregateResult objects.
    public class HeadcountSummary {
        @AuraEnabled public String department;
        @AuraEnabled public Integer activePersonnel;

        public HeadcountSummary(String department, Integer activePersonnel) {
            this.department = department;
            this.activePersonnel = activePersonnel;
        }
    }

    public static List<Database.UpsertResult> upsertPersonnel(List<Personnel__c> people) {
        if (people == null || people.isEmpty()) {
            return new List<Database.UpsertResult>();
        }

        // Bulk pattern, step 1: collect keys from every incoming record.
        // Never query inside a loop for each record.
        Set<String> employeeIds = new Set<String>();
        for (Personnel__c person : people) {
            normalizeForSave(person);
            if (!String.isBlank(person.Employee_Id__c)) {
                employeeIds.add(person.Employee_Id__c);
            }
        }

        // Bulk pattern, step 2: query existing records once and index them.
        Map<String, Id> existingIdsByEmployeeId = new Map<String, Id>();
        for (Personnel__c existing : PersonnelSelector.selectByEmployeeIds(employeeIds)) {
            existingIdsByEmployeeId.put(existing.Employee_Id__c, existing.Id);
        }

        // Bulk pattern, step 3: set Ids before upsert so existing records update
        // and new Employee IDs insert. The final DML call still runs once.
        for (Personnel__c person : people) {
            if (person.Id == null && existingIdsByEmployeeId.containsKey(person.Employee_Id__c)) {
                person.Id = existingIdsByEmployeeId.get(person.Employee_Id__c);
            }
        }

        return Database.upsert(people, false);
    }

    public static List<Personnel__c> findActiveByDepartment(Set<String> departments) {
        return PersonnelSelector.selectByDepartment(departments, true);
    }

    public static List<HeadcountSummary> summarizeActiveHeadcount() {
        List<HeadcountSummary> summaries = new List<HeadcountSummary>();

        // AggregateResult is how Apex returns GROUP BY rows.
        for (AggregateResult row : [
            SELECT Department__c department, COUNT(Id) activePersonnel
            FROM Personnel__c
            WHERE Status__c = 'Active'
            GROUP BY Department__c
            ORDER BY Department__c
        ]) {
            summaries.add(
                new HeadcountSummary(
                    (String) row.get('department'),
                    (Integer) row.get('activePersonnel')
                )
            );
        }

        return summaries;
    }

    public static void terminatePersonnel(Set<Id> personnelIds, Date terminationDate) {
        if (personnelIds == null || personnelIds.isEmpty()) {
            return;
        }
        if (terminationDate == null) {
            throw new PersonnelException('A termination date is required.');
        }

        List<Personnel__c> peopleToUpdate = new List<Personnel__c>();
        for (Personnel__c person : PersonnelSelector.selectByIds(personnelIds)) {
            peopleToUpdate.add(
                new Personnel__c(
                    Id = person.Id,
                    Status__c = 'Terminated',
                    Termination_Date__c = terminationDate
                )
            );
        }

        if (!peopleToUpdate.isEmpty()) {
            update peopleToUpdate;
        }

        // Termination is a business event, so the service also closes related work.
        PersonnelAssignmentService.closeOpenAssignments(personnelIds, terminationDate);
    }

    public static void normalizeForSave(Personnel__c person) {
        if (person == null) {
            return;
        }

        // Keep data cleanup in one reusable place. The trigger and anonymous
        // scripts both flow through this method.
        if (!String.isBlank(person.Email__c)) {
            person.Email__c = person.Email__c.trim().toLowerCase();
        }
        if (String.isBlank(person.Status__c)) {
            person.Status__c = 'Active';
        }
        if (String.isBlank(person.Employment_Type__c)) {
            person.Employment_Type__c = 'Full Time';
        }
        if (String.isBlank(person.Review_Status__c)) {
            person.Review_Status__c = 'Not Started';
        }
        if (String.isBlank(person.Clearance_Level__c)) {
            person.Clearance_Level__c = 'None';
        }
    }
}
