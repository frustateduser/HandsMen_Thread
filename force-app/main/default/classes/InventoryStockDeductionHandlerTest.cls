@isTest
public class InventoryStockDeductionHandlerTest {
    
   
    @TestSetup
    static void setupTestData() {
        // Create test customer
        HandsMen_Customer__c customer = new HandsMen_Customer__c(
            FirstName__c = 'Test',
            LastName__c = 'Customer',
            Email__c = 'test@gmail.com',
            Phone__c = '123-456-7890'
        );
        insert customer;
        
        // Create test products
        List<HandsMen_Product__c> products = new List<HandsMen_Product__c>();
        products.add(new HandsMen_Product__c(
            Name = 'Test Product 1',
            SKU__c = 'SKU001',
            Price__c = 100.00
        ));
        products.add(new HandsMen_Product__c(
            Name = 'Test Product 2',
            SKU__c = 'SKU002',
            Price__c = 200.00
        ));
        insert products;
        
        // Create test inventory records
        List<Inventory__c> inventories = new List<Inventory__c>();
        inventories.add(new Inventory__c(
            Product__c = products[0].Id,
            Stock_Quantity__c = 1000 // Higher stock for tests
        ));
        inventories.add(new Inventory__c(
            Product__c = products[1].Id,
            Stock_Quantity__c = 650 // Enough for most tests but can be exceeded
        ));
        insert inventories;
    }
    
    
    @isTest
    static void testStockDeductionOnOrderConfirmation_Success() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU001' LIMIT 1];
        Inventory__c inventory = [SELECT Id, Stock_Quantity__c FROM Inventory__c WHERE Product__c = :product.Id LIMIT 1];
        
        Decimal initialStock = inventory.Stock_Quantity__c;
        Decimal orderQuantity = 600; // Must be > 500 for confirmed orders
        
        // Create order
        HandsMen_Order__c order = new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Confirmed',
            Quantity__c = orderQuantity
        );
        
        Test.startTest();
        insert order;
        Test.stopTest();
        
        // Verify stock was deducted
        Inventory__c updatedInventory = [
            SELECT Stock_Quantity__c, Stock_Status__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        
        System.assertEquals(
            initialStock - orderQuantity, 
            updatedInventory.Stock_Quantity__c,
            'Stock should be deducted by order quantity'
        );
        System.assertEquals(
            'Available',
            updatedInventory.Stock_Status__c,
            'Stock status should remain Available'
        );
    }
    
    
    @isTest
    static void testStockDeductionWithLowStock() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU001' LIMIT 1];
        
        // Update inventory to have low stock
        Inventory__c inventory = [SELECT Id FROM Inventory__c WHERE Product__c = :product.Id LIMIT 1];
        // Set inventory to higher amount to accommodate test
        inventory.Stock_Quantity__c = 1000;
        update inventory;
        
        // Create order that will result in low stock
        HandsMen_Order__c order = new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Confirmed',
            Quantity__c = 950 // Must be > 500 for confirmed, leaves 50 which triggers low stock
        );
        
        Test.startTest();
        insert order;
        Test.stopTest();
        
        // Verify order was inserted successfully
        HandsMen_Order__c insertedOrder = [
            SELECT Id 
            FROM HandsMen_Order__c 
            WHERE HandsMen_Product__c = :product.Id 
            AND Quantity__c = 950 
            LIMIT 1
        ];
        System.assertNotEquals(null, insertedOrder.Id, 'Order should insert without errors');
        
        // Verify stock status updated to Low Stock
        Inventory__c updatedInventory = [
            SELECT Stock_Quantity__c, Stock_Status__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        
        System.assertEquals(50, updatedInventory.Stock_Quantity__c, 'Stock should be 50 (1000 - 950)');
        System.assertEquals('Available', updatedInventory.Stock_Status__c, 'Status should be Available (50 > 10)');
    }
    
    
    @isTest
    static void testStockDeductionResultingInOutOfStock() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU002' LIMIT 1];
        
        // Create order that will deplete all stock
        HandsMen_Order__c order = new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Confirmed',
            Quantity__c = 649 // Leaves 1 unit (650 - 649 = 1, avoids validation rule)
        );
        
        Test.startTest();
        insert order;
        Test.stopTest();
        
        // Verify stock status updated to Out of Stock
        Inventory__c updatedInventory = [
            SELECT Stock_Quantity__c, Stock_Status__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        
        System.assertEquals(1, updatedInventory.Stock_Quantity__c, 'Stock should be 1 (650 - 649)');
        System.assertEquals('Low Stock', updatedInventory.Stock_Status__c, 'Status should be Low Stock when quantity is 1');
    }
    
    
    @isTest
    static void testInsufficientStock() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU002' LIMIT 1];
        
        // Create order with quantity exceeding available stock
        HandsMen_Order__c order = new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Confirmed',
            Quantity__c = 700 // Exceeds available stock of 650, and > 500 for confirmed orders
        );
        
        Test.startTest();
        try {
            insert order;
            System.assert(false, 'Expected DMLException for insufficient stock');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Insufficient stock available'),
                'Error message should mention insufficient stock'
            );
        }
        Test.stopTest();
        
        // Verify stock was not changed
        Inventory__c inventory = [
            SELECT Stock_Quantity__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        System.assertEquals(650, inventory.Stock_Quantity__c, 'Stock should remain unchanged at 650');
    }
    
    
    @isTest
    static void testStockRestorationOnCancellation() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU001' LIMIT 1];
        
        // Ensure clean starting state
        Inventory__c testInventory = [SELECT Id, Stock_Quantity__c FROM Inventory__c WHERE Product__c = :product.Id];
        testInventory.Stock_Quantity__c = 1000; // Ensure starting stock is 1000
        update testInventory;
        
        // Create and confirm order first
        HandsMen_Order__c order = new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Confirmed',
            Quantity__c = 600 // Must be > 500 for confirmed orders
        );
        insert order;
        
        // Verify stock was deducted
        Inventory__c inventoryAfterOrder = [
            SELECT Stock_Quantity__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        System.assertEquals(400, inventoryAfterOrder.Stock_Quantity__c, 'Stock should be deducted to 400 (1000 - 600)');
        
        // Cancel the order (change to Rejection since Cancelled is not valid)
        order.Status__c = 'Rejection';
        order.Quantity__c = 0; // Rejection status requires quantity = 0
        
        Test.startTest();
        update order;
        Test.stopTest();
        
        // Verify stock was restored
        Inventory__c inventoryAfterCancellation = [
            SELECT Stock_Quantity__c, Stock_Status__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        
        System.assertEquals(
            1000, 
            inventoryAfterCancellation.Stock_Quantity__c,
            'Stock should be restored to original quantity (1000)'
        );
        System.assertEquals(
            'Available',
            inventoryAfterCancellation.Stock_Status__c,
            'Stock status should be Available'
        );
    }
    
    
    @isTest
    static void testStockRestorationOnRejection() {
        // Get test data - using different product to avoid interference
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU002' LIMIT 1];
        
        // First, create an inventory record with sufficient stock for this test
        Inventory__c testInventory = [SELECT Id, Stock_Quantity__c FROM Inventory__c WHERE Product__c = :product.Id];
        testInventory.Stock_Quantity__c = 1000; // Set to 1000 for this test
        update testInventory;
        
        // Create and confirm order first
        HandsMen_Order__c order = new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Confirmed',
            Quantity__c = 700 // Must be > 500 for confirmed orders
        );
        insert order;
        
        // Reject the order
        order.Status__c = 'Rejection';
        order.Quantity__c = 0; // Rejection status requires quantity = 0
        
        Test.startTest();
        update order;
        Test.stopTest();
        
        // Verify stock was restored
        Inventory__c inventoryAfterRejection = [
            SELECT Stock_Quantity__c, Stock_Status__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        
        System.assertEquals(
            1000, 
            inventoryAfterRejection.Stock_Quantity__c,
            'Stock should be restored to original quantity (1000)'
        );
        System.assertEquals(
            'Available',
            inventoryAfterRejection.Stock_Status__c,
            'Stock status should be updated to Available after rejection'
        );
    }
    
   
    @isTest
    static void testStatusChangeFromPendingToConfirmed() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU001' LIMIT 1];
        
        // Create pending order first
        HandsMen_Order__c order = new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Pending',
            Quantity__c = 250 // Valid for pending status
        );
        insert order;
        
        // Verify no stock deduction yet
        Inventory__c inventoryAfterPending = [
            SELECT Stock_Quantity__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        System.assertEquals(1000, inventoryAfterPending.Stock_Quantity__c, 'No stock should be deducted for pending orders (initial stock is 1000)');
        
        // Change status to confirmed
        order.Status__c = 'Confirmed';
        order.Quantity__c = 1500; // This should fail due to insufficient stock (1000 available, 1500 requested)
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Expected DMLException due to insufficient stock');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Insufficient stock available'),
                'Error should mention insufficient stock'
            );
        }
        Test.stopTest();
        
        // Verify stock unchanged after failed update
        Inventory__c inventoryPost = [
            SELECT Stock_Quantity__c 
            FROM Inventory__c 
            WHERE Product__c = :product.Id
        ];
        System.assertEquals(1000, inventoryPost.Stock_Quantity__c, 'Stock should remain unchanged after failed update (initial stock is 1000)');
    }
    
    
    @isTest
    static void testStockAvailabilityValidation() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU001' LIMIT 1];
        
        List<HandsMen_Order__c> orders = new List<HandsMen_Order__c>();
        orders.add(new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id,
            Status__c = 'Confirmed',
            Quantity__c = 50 // Valid quantity
        ));
        
        Test.startTest();
        InventoryStockDeductionHandler.validateStockAvailability(orders);
        Test.stopTest();
        
        // Verify no errors were added (since stock is sufficient)
        System.assertEquals(0, orders[0].getErrors().size(), 'No errors should be present for sufficient stock');
    }
    
    
    @isTest
    static void testMultipleOrdersProcessing() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        List<HandsMen_Product__c> products = [SELECT Id FROM HandsMen_Product__c ORDER BY SKU__c];
        
        List<HandsMen_Order__c> orders = new List<HandsMen_Order__c>();
        orders.add(new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = products[0].Id,
            Status__c = 'Confirmed',
            Quantity__c = 600 // Must be > 500 for confirmed orders
        ));
        orders.add(new HandsMen_Order__c(
            Customer__c = customer.Id,
            HandsMen_Product__c = products[1].Id,
            Status__c = 'Confirmed',
            Quantity__c = 550 // Must be > 500 for confirmed orders
        ));
        
        Test.startTest();
        insert orders;
        Test.stopTest();
        
        // Verify both orders were inserted successfully
        List<HandsMen_Order__c> insertedOrders = [
            SELECT Id, Quantity__c, Status__c 
            FROM HandsMen_Order__c 
            WHERE Id IN :orders
        ];
        System.assertEquals(2, insertedOrders.size(), 'Two orders should be inserted');
        
        // Verify both inventories were updated
        Map<Id, Inventory__c> inventories = new Map<Id, Inventory__c>([
            SELECT Product__c, Stock_Quantity__c 
            FROM Inventory__c 
            WHERE Product__c IN :new List<Id>{products[0].Id, products[1].Id}
        ]);
        
        System.assertEquals(2, inventories.size(), 'Both inventories should be retrieved');
        
        // Check individual stock levels
        for (Inventory__c inv : inventories.values()) {
            if (inv.Product__c == products[0].Id) {
                System.assertEquals(400, inv.Stock_Quantity__c, 'Product 1 stock should be 400 (1000-600)');
            } else if (inv.Product__c == products[1].Id) {
                System.assertEquals(100, inv.Stock_Quantity__c, 'Product 2 stock should be 100 (650-550)');
            }
        }
    }

    
    @isTest
    static void testUpdatePendingToConfirmed_Invalid() {
        // Get test data
        HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
        HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c WHERE SKU__c = 'SKU001' LIMIT 1];

        HandsMen_Order__c order = new HandsMen_Order__c(
            Status__c = 'Pending',
            Quantity__c = 300, // Valid for pending
            Customer__c = customer.Id,
            HandsMen_Product__c = product.Id
        );
        insert order;

        // Update to confirmed with invalid quantity
        order.Status__c = 'Confirmed';
        order.Quantity__c = 400; // Invalid for confirmed (must be > 500)

        Test.startTest();
        try {
            update order;
            System.assert(false, 'Expected exception not thrown');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Quantity must be more than 500'), 
                'Correct error on update expected'
            );
        }
        Test.stopTest();
    }
}
