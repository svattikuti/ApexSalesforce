trigger PersonnelTrigger on Personnel__c (before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        PersonnelTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        PersonnelTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}
