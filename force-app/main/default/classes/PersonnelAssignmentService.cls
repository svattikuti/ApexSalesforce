public with sharing class PersonnelAssignmentService {
    public class AssignmentException extends Exception {
    }

    public static Personnel_Assignment__c createAssignment(
        Id personnelId,
        String assignmentName,
        String assignmentType,
        Date startDate,
        Decimal hoursPerWeek
    ) {
        if (personnelId == null) {
            throw new AssignmentException('Personnel Id is required.');
        }
        if (String.isBlank(assignmentName)) {
            throw new AssignmentException('Assignment Name is required.');
        }
        if (startDate == null) {
            throw new AssignmentException('Start Date is required.');
        }

        Personnel__c person = PersonnelSelector.mapById(new Set<Id>{ personnelId }).get(personnelId);
        if (person == null) {
            throw new AssignmentException('Personnel record was not found.');
        }
        if (person.Status__c != 'Active') {
            throw new AssignmentException('Assignments can only be created for active personnel.');
        }

        Personnel_Assignment__c assignment = new Personnel_Assignment__c(
            Personnel__c = personnelId,
            Assignment_Name__c = assignmentName.trim(),
            Assignment_Type__c = String.isBlank(assignmentType) ? 'Project' : assignmentType,
            Status__c = 'Active',
            Start_Date__c = startDate,
            Hours_Per_Week__c = hoursPerWeek
        );
        insert assignment;

        return [
            SELECT Id, Name, Personnel__c, Assignment_Name__c, Assignment_Type__c,
                Status__c, Start_Date__c, End_Date__c, Hours_Per_Week__c, Active__c
            FROM Personnel_Assignment__c
            WHERE Id = :assignment.Id
            LIMIT 1
        ];
    }

    public static List<Personnel_Assignment__c> createAssignmentForDepartment(
        String department,
        String assignmentName,
        String assignmentType,
        Date startDate,
        Decimal hoursPerWeek
    ) {
        if (String.isBlank(department)) {
            throw new AssignmentException('Department is required.');
        }

        List<Personnel_Assignment__c> assignments = new List<Personnel_Assignment__c>();
        for (Personnel__c person : PersonnelService.findActiveByDepartment(new Set<String>{ department })) {
            assignments.add(
                new Personnel_Assignment__c(
                    Personnel__c = person.Id,
                    Assignment_Name__c = assignmentName,
                    Assignment_Type__c = String.isBlank(assignmentType) ? 'Project' : assignmentType,
                    Status__c = 'Active',
                    Start_Date__c = startDate,
                    Hours_Per_Week__c = hoursPerWeek
                )
            );
        }

        if (!assignments.isEmpty()) {
            insert assignments;
        }
        return assignments;
    }

    public static void closeOpenAssignments(Set<Id> personnelIds, Date endDate) {
        if (personnelIds == null || personnelIds.isEmpty()) {
            return;
        }
        if (endDate == null) {
            throw new AssignmentException('End Date is required.');
        }

        List<Personnel_Assignment__c> assignmentsToUpdate = new List<Personnel_Assignment__c>();
        for (Personnel_Assignment__c assignment : [
            SELECT Id, Start_Date__c, End_Date__c, Status__c
            FROM Personnel_Assignment__c
            WHERE Personnel__c IN :personnelIds
                AND Status__c IN ('Planned', 'Active')
        ]) {
            if (assignment.Start_Date__c != null && assignment.Start_Date__c > endDate) {
                assignment.Status__c = 'Cancelled';
                assignment.End_Date__c = null;
            } else {
                assignment.Status__c = 'Completed';
                assignment.End_Date__c = endDate;
            }
            assignmentsToUpdate.add(assignment);
        }

        if (!assignmentsToUpdate.isEmpty()) {
            update assignmentsToUpdate;
        }
    }
}
