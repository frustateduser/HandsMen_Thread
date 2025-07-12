@isTest
public class LoyaltyStatusHandlerTest {

    @TestSetup
    static void setupTestData() {
        // Create one sample product and inventory if your logic depends on it
        HandsMen_Product__c product = new HandsMen_Product__c(
            Name = 'Test Product',
            SKU__c = 'TP-001',
            Price__c = 100
        );
        insert product;

        Inventory__c inventory = new Inventory__c(
            Product__c = product.Id,
            Stock_Quantity__c = 1000
        );
        insert inventory;
    }

    @isTest
    static void testBronzeLoyaltyStatus() {
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'John',
            LastName__c = 'Doe',
            Email__c = 'john@gmail.com',
            Phone__c = '1234567890',
            Total_Purchases__c = 300
        );
        insert customer;

        HandsMen_Customer__c result = [
            SELECT Loyalty_Status__c FROM HandsMen_Customer__c WHERE Id = :customer.Id
        ];
        System.assertEquals('Bronze', result.Loyalty_Status__c);
    }

    @isTest
    static void testSilverLoyaltyStatus() {
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'Alice',
            LastName__c = 'Smith',
            Email__c = 'alice@gmail.com',
            Phone__c = '9876543210',
            Total_Purchases__c = 700
        );
        insert customer;

        HandsMen_Customer__c result = [
            SELECT Loyalty_Status__c FROM HandsMen_Customer__c WHERE Id = :customer.Id
        ];
        System.assertEquals('Silver', result.Loyalty_Status__c);
    }

    @isTest
    static void testGoldLoyaltyStatus() {
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'Mark',
            LastName__c = 'Lee',
            Email__c = 'mark@gmail.com',
            Phone__c = '1112223333',
            Total_Purchases__c = 1500
        );
        insert customer;

        HandsMen_Customer__c result = [
            SELECT Loyalty_Status__c FROM HandsMen_Customer__c WHERE Id = :customer.Id
        ];
        System.assertEquals('Gold', result.Loyalty_Status__c);
    }

    @isTest
    static void testUpdateLoyaltyStatus() {
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'Sam',
            LastName__c = 'Green',
            Email__c = 'sam@gmail.com',
            Phone__c = '4445556666',
            Total_Purchases__c = 200
        );
        insert customer;

        // Update purchases to reach gold tier
        customer.Total_Purchases__c = 1200;
        update customer;

        HandsMen_Customer__c result = [
            SELECT Loyalty_Status__c FROM HandsMen_Customer__c WHERE Id = :customer.Id
        ];
        System.assertEquals('Gold', result.Loyalty_Status__c);
    }

    @isTest
    static void testNoLoyaltyStatusForLowPurchases() {
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'Low',
            LastName__c = 'Spender',
            Email__c = 'lowspender@gmail.com',
            Phone__c = '0001112222',
            Total_Purchases__c = 50
        );
        insert customer;

        HandsMen_Customer__c result = [
            SELECT Loyalty_Status__c FROM HandsMen_Customer__c WHERE Id = :customer.Id
        ];
        System.assertEquals(null, result.Loyalty_Status__c, 'Loyalty status should remain null for low purchases');
    }

    @isTest
    static void testLoyaltyStatusUpgrade() {
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'Upgrade',
            LastName__c = 'Test',
            Email__c = 'upgrade@gmail.com',
            Phone__c = '3334445555',
            Total_Purchases__c = 500
        );
        insert customer;

        customer.Total_Purchases__c = 1100;
        update customer;

        HandsMen_Customer__c result = [
            SELECT Loyalty_Status__c FROM HandsMen_Customer__c WHERE Id = :customer.Id
        ];
        System.assertEquals('Gold', result.Loyalty_Status__c);
    }

    @isTest
    static void testBulkOrderProcessing() {
        List<HandsMen_Customer__c> customers = new List<HandsMen_Customer__c>();
        for (Integer i = 0; i < 5; i++) {
            customers.add(new HandsMen_Customer__c(
                FirstName__c = 'Bulk' + i,
                LastName__c = 'Customer',
                Email__c = 'bulk' + i + '@gmail.com',
                Phone__c = '99999999' + i,
                Total_Purchases__c = 800 + (i * 100)
            ));
        }
        insert customers;

        List<HandsMen_Customer__c> results = [
            SELECT Loyalty_Status__c, Total_Purchases__c 
            FROM HandsMen_Customer__c 
            WHERE Id IN :customers
        ];

        for (HandsMen_Customer__c cust : results) {
            if (cust.Total_Purchases__c >= 1000) {
                System.assertEquals('Gold', cust.Loyalty_Status__c);
            } else if (cust.Total_Purchases__c >= 500) {
                System.assertEquals('Silver', cust.Loyalty_Status__c);
            } else {
                System.assertEquals('Bronze', cust.Loyalty_Status__c);
            }
        }
    }
}
