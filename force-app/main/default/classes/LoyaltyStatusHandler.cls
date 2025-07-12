public class LoyaltyStatusHandler {
    public static void updateLoyaltyStatus(List<HandsMen_Customer__c> customers) {
        for (HandsMen_Customer__c customer : customers) {
            if (customer.Total_Purchases__c != null) {
                if (customer.Total_Purchases__c >= 1000) {
                    customer.Loyalty_Status__c = 'Gold';
                } else if (customer.Total_Purchases__c >= 500) {
                    customer.Loyalty_Status__c = 'Silver';
                } else if (customer.Total_Purchases__c >= 100) {
                    customer.Loyalty_Status__c = 'Bronze';
                }
                // If < 100, loyalty status remains null (no assignment)
            }
        }
    }
}