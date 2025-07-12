trigger OrderTrigger on HandsMen_Order__c(before insert, before update, after insert, after update) {
  if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
    OrderTriggerHandler.validateOrderQuantity(Trigger.new);
  }
  
  if (Trigger.isAfter && Trigger.isInsert) {
    OrderTriggerHandler.handleAfterInsert(Trigger.new);
  }
  
  if (Trigger.isAfter && Trigger.isUpdate) {
    OrderTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
  }
}