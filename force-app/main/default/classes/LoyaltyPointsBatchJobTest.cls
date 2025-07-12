@IsTest(SeeAllData=false)
public class LoyaltyPointsBatchJobTest {
    
    @IsTest
    static void testLoyaltyPointsBatchJobSimple() {
        Test.startTest();
        
        // Create a simple customer without orders
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'Test',
            LastName__c = 'Customer',
            Email__c = 'test.customer@gmail.com',
            Loyalty_Status__c = 'Gold',
            Loyalty_Points__c = 100,
            Total_Purchases__c = 1000
        );
        insert customer;
        
        // Execute the batch job
        LoyaltyPointsBatchJob batchJob = new LoyaltyPointsBatchJob();
        Database.executeBatch(batchJob, 200);
        
        Test.stopTest();
        
        // Verify the customer still exists (no orders to process)
        HandsMen_Customer__c updatedCustomer = [SELECT Id, Loyalty_Points__c FROM HandsMen_Customer__c WHERE Id = :customer.Id];
        System.assertEquals(100, updatedCustomer.Loyalty_Points__c, 'No points should be added without recent orders');
    }
    
    @IsTest
    static void testSchedulableExecution() {
        Test.startTest();
        
        // Test the schedulable interface
        LoyaltyPointsBatchJob schedulableJob = new LoyaltyPointsBatchJob();
        String jobId = System.schedule('Test Loyalty Points Job', '0 0 0 ? * SUN', schedulableJob);
        
        Test.stopTest();
        
        // Verify the job was scheduled
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
    }
    
    @IsTest
    static void testBatchJobWithNoOrdersSimple() {
        Test.startTest();
        
        // Create customers without any orders
        List<HandsMen_Customer__c> customers = new List<HandsMen_Customer__c>();
        customers.add(new HandsMen_Customer__c(
            FirstName__c = 'Customer1',
            LastName__c = 'Test',
            Email__c = 'customer1@gmail.com',
            Loyalty_Points__c = 50
        ));
        customers.add(new HandsMen_Customer__c(
            FirstName__c = 'Customer2',
            LastName__c = 'Test',
            Email__c = 'customer2@gmail.com',
            Loyalty_Points__c = 75
        ));
        insert customers;
        
        LoyaltyPointsBatchJob batchJob = new LoyaltyPointsBatchJob();
        Database.executeBatch(batchJob, 200);
        
        Test.stopTest();
        
        // Verify no points were added
        List<HandsMen_Customer__c> updatedCustomers = [
            SELECT Id, Loyalty_Points__c
            FROM HandsMen_Customer__c
            WHERE Id IN :customers
        ];
        
        for (HandsMen_Customer__c customer : updatedCustomers) {
            System.assert(customer.Loyalty_Points__c <= 75, 'No additional points should be added when no recent orders exist');
        }
    }
}
