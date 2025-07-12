global class LoyaltyPointsBatchJob implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all customers - we'll filter orders in the execute method for better control
        return Database.getQueryLocator(
            'SELECT Id, Loyalty_Points__c, Total_Purchases__c, Loyalty_Status__c, ' +
            '(SELECT Id, Total_Amount__c, CreatedDate, Status__c ' +
            'FROM HandsMen_Orders__r ' +
            'WHERE Status__c = \'Completed\') ' +
            'FROM HandsMen_Customer__c'
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> records) {
        List<HandsMen_Customer__c> customersToUpdate = new List<HandsMen_Customer__c>();
        DateTime oneWeekAgo = DateTime.now().addDays(-7);
        
        for (SObject record : records) {
            HandsMen_Customer__c customer = (HandsMen_Customer__c) record;
            
            // Calculate points for the week
            Decimal weeklyPoints = 0;
            
            // Award 1 point for every $1 spent in completed orders from the past week
            for (HandsMen_Order__c order : customer.HandsMen_Orders__r) {
                // Filter for orders from the past week
                if (order.Total_Amount__c != null && order.CreatedDate >= oneWeekAgo) {
                    weeklyPoints += order.Total_Amount__c;
                }
            }
            
            // Add bonus points based on loyalty status
            if (weeklyPoints > 0) {
                if (customer.Loyalty_Status__c == 'Gold') {
                    weeklyPoints *= 1.5; // 50% bonus for Gold members
                } else if (customer.Loyalty_Status__c == 'Silver') {
                    weeklyPoints *= 1.25; // 25% bonus for Silver members
                } else if (customer.Loyalty_Status__c == 'Bronze') {
                    weeklyPoints *= 1.1; // 10% bonus for Bronze members
                }
            }
            
            // Update customer's total loyalty points
            if (weeklyPoints > 0) {
                if (customer.Loyalty_Points__c == null) {
                    customer.Loyalty_Points__c = 0;
                }
                customer.Loyalty_Points__c += weeklyPoints;
                customersToUpdate.add(customer);
            }
        }
        
        // Update customers with new loyalty points
        if (!customersToUpdate.isEmpty()) {
            try {
                update customersToUpdate;
                System.debug('Successfully updated ' + customersToUpdate.size() + ' customers with loyalty points');
            } catch (DmlException e) {
                System.debug('Error updating customer loyalty points: ' + e.getMessage());
                // Log the error for each failed record
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('Failed to update customer ID: ' + customersToUpdate[e.getDmlIndex(i)].Id + 
                                ' - Error: ' + e.getDmlMessage(i));
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Loyalty Points Calculation Batch Job Completed');
        
        // Optional: Send email notification to admin about completion
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                           FROM AsyncApexJob 
                           WHERE Id = :BC.getJobId()];
        
        System.debug('Job Status: ' + job.Status);
        System.debug('Records Processed: ' + job.JobItemsProcessed + ' of ' + job.TotalJobItems);
        System.debug('Errors: ' + job.NumberOfErrors);
    }
    
    // Schedulable interface implementation for weekly execution
    global void execute(SchedulableContext SC) {
        // Execute the batch job every Sunday at 12 AM
        LoyaltyPointsBatchJob batchJob = new LoyaltyPointsBatchJob();
        Database.executeBatch(batchJob, 200);
    }
}
