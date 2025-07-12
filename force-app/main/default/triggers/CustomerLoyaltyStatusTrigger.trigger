trigger CustomerLoyaltyStatusTrigger on HandsMen_Customer__c (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        LoyaltyStatusHandler.updateLoyaltyStatus(Trigger.new);
    }
}
