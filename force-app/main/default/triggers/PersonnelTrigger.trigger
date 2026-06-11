trigger PersonnelTrigger on Personnel__c (before insert, before update) {
    // Keep triggers thin. The trigger decides which context happened; the handler
    // owns the behavior.
    if (Trigger.isBefore && Trigger.isInsert) {
        PersonnelTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        PersonnelTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}
