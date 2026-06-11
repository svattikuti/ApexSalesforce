public with sharing class PersonnelSelector {
    public static List<Personnel__c> selectByIds(Set<Id> personnelIds) {
        if (personnelIds == null || personnelIds.isEmpty()) {
            return new List<Personnel__c>();
        }

        return [
            SELECT Id, Name, Employee_Id__c, First_Name__c, Last_Name__c, Display_Name__c,
                Email__c, Department__c, Role__c, Status__c, Employment_Type__c,
                Hire_Date__c, Termination_Date__c, Clearance_Level__c, Manager__c,
                Work_Location__c, Last_Review_Date__c, Review_Status__c, Notes__c
            FROM Personnel__c
            WHERE Id IN :personnelIds
            ORDER BY Last_Name__c, First_Name__c
        ];
    }

    public static List<Personnel__c> selectByEmployeeIds(Set<String> employeeIds) {
        if (employeeIds == null || employeeIds.isEmpty()) {
            return new List<Personnel__c>();
        }

        return [
            SELECT Id, Name, Employee_Id__c, First_Name__c, Last_Name__c, Display_Name__c,
                Email__c, Department__c, Role__c, Status__c, Employment_Type__c,
                Hire_Date__c, Termination_Date__c, Clearance_Level__c, Manager__c,
                Work_Location__c, Last_Review_Date__c, Review_Status__c, Notes__c
            FROM Personnel__c
            WHERE Employee_Id__c IN :employeeIds
            ORDER BY Last_Name__c, First_Name__c
        ];
    }

    public static List<Personnel__c> selectByDepartment(Set<String> departments, Boolean activeOnly) {
        if (departments == null || departments.isEmpty()) {
            return new List<Personnel__c>();
        }

        if (activeOnly == true) {
            return [
                SELECT Id, Name, Employee_Id__c, First_Name__c, Last_Name__c, Display_Name__c,
                    Email__c, Department__c, Role__c, Status__c, Employment_Type__c,
                    Hire_Date__c, Termination_Date__c, Clearance_Level__c, Manager__c,
                    Work_Location__c, Last_Review_Date__c, Review_Status__c, Notes__c
                FROM Personnel__c
                WHERE Department__c IN :departments
                    AND Status__c = 'Active'
                ORDER BY Last_Name__c, First_Name__c
            ];
        }

        return [
            SELECT Id, Name, Employee_Id__c, First_Name__c, Last_Name__c, Display_Name__c,
                Email__c, Department__c, Role__c, Status__c, Employment_Type__c,
                Hire_Date__c, Termination_Date__c, Clearance_Level__c, Manager__c,
                Work_Location__c, Last_Review_Date__c, Review_Status__c, Notes__c
            FROM Personnel__c
            WHERE Department__c IN :departments
            ORDER BY Last_Name__c, First_Name__c
        ];
    }

    public static Map<Id, Personnel__c> mapById(Set<Id> personnelIds) {
        return new Map<Id, Personnel__c>(selectByIds(personnelIds));
    }
}
