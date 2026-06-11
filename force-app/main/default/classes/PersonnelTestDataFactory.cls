@IsTest
public class PersonnelTestDataFactory {
    public static Personnel__c buildPerson(String employeeId, String department) {
        String safeEmployeeId = String.isBlank(employeeId) ? 'EMP-0001' : employeeId;
        return new Personnel__c(
            Employee_Id__c = safeEmployeeId,
            First_Name__c = 'Test',
            Last_Name__c = 'Person ' + safeEmployeeId,
            Email__c = safeEmployeeId.toLowerCase() + '@example.com',
            Department__c = String.isBlank(department) ? 'Operations' : department,
            Role__c = 'Analyst',
            Status__c = 'Active',
            Employment_Type__c = 'Full Time',
            Hire_Date__c = Date.today().addYears(-1),
            Clearance_Level__c = 'None',
            Work_Location__c = 'Remote',
            Last_Review_Date__c = Date.today(),
            Review_Status__c = 'Current'
        );
    }

    public static List<Personnel__c> buildPeople(Integer count, String department, String prefix) {
        List<Personnel__c> people = new List<Personnel__c>();
        Integer safeCount = count == null || count < 0 ? 0 : count;
        String safePrefix = String.isBlank(prefix) ? 'EMP' : prefix;

        for (Integer i = 0; i < safeCount; i++) {
            String suffix = String.valueOf(10000 + i).substring(1);
            people.add(buildPerson(safePrefix + '-' + suffix, department));
        }
        return people;
    }

    public static List<Personnel__c> insertPeople(Integer count, String department, String prefix) {
        List<Personnel__c> people = buildPeople(count, department, prefix);
        insert people;
        return people;
    }

    public static Personnel_Assignment__c buildAssignment(Id personnelId, String name, Date startDate) {
        return new Personnel_Assignment__c(
            Personnel__c = personnelId,
            Assignment_Name__c = String.isBlank(name) ? 'Sample Assignment' : name,
            Assignment_Type__c = 'Project',
            Status__c = 'Active',
            Start_Date__c = startDate == null ? Date.today() : startDate,
            Hours_Per_Week__c = 20
        );
    }
}
