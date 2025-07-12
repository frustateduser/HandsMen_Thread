@IsTest
public class InventoryBatchJobTest {
    
    @IsTest
    static void testInventoryBatchJobRestock() {
        Test.startTest();
        
        // Create test products with low stock (less than 10)
        List<HandsMen_Product__c> lowStockProducts = new List<HandsMen_Product__c>();
        
        HandsMen_Product__c product1 = new HandsMen_Product__c(
            Name = 'Low Stock Product 1',
            Price__c = 100,
            Stock_Quantity__c = 5
        );
        lowStockProducts.add(product1);
        
        HandsMen_Product__c product2 = new HandsMen_Product__c(
            Name = 'Low Stock Product 2', 
            Price__c = 150,
            Stock_Quantity__c = 3
        );
        lowStockProducts.add(product2);
        
        HandsMen_Product__c product3 = new HandsMen_Product__c(
            Name = 'Low Stock Product 3',
            Price__c = 200,
            Stock_Quantity__c = 8
        );
        lowStockProducts.add(product3);
        
        insert lowStockProducts;
        
        // Create inventory records for the products (required by validation rules)
        List<Inventory__c> inventories = new List<Inventory__c>();
        for (HandsMen_Product__c product : lowStockProducts) {
            Inventory__c inventory = new Inventory__c(
                Product__c = product.Id,
                Stock_Quantity__c = product.Stock_Quantity__c,
                Warehouse__c = 'Main Warehouse'
            );
            inventories.add(inventory);
        }
        insert inventories;
        
        // Also create some products with sufficient stock (>= 10) to verify they are not processed
        HandsMen_Product__c highStockProduct = new HandsMen_Product__c(
            Name = 'High Stock Product',
            Price__c = 300,
            Stock_Quantity__c = 25
        );
        insert highStockProduct;
        
        Inventory__c highStockInventory = new Inventory__c(
            Product__c = highStockProduct.Id,
            Stock_Quantity__c = highStockProduct.Stock_Quantity__c,
            Warehouse__c = 'Main Warehouse'
        );
        insert highStockInventory;
        
        // Execute the batch job
        InventoryBatchJob batchJob = new InventoryBatchJob();
        Database.executeBatch(batchJob, 200);
        
        Test.stopTest();
        
        // Verify the results
        List<HandsMen_Product__c> updatedProducts = [
            SELECT Id, Name, Stock_Quantity__c
            FROM HandsMen_Product__c
            WHERE Id IN :lowStockProducts
            ORDER BY Name
        ];
        
        // Each low stock product should have been restocked by 50 units
        System.assertEquals(55, updatedProducts[0].Stock_Quantity__c, 'Product 1 should be restocked from 5 to 55');
        System.assertEquals(53, updatedProducts[1].Stock_Quantity__c, 'Product 2 should be restocked from 3 to 53');
        System.assertEquals(58, updatedProducts[2].Stock_Quantity__c, 'Product 3 should be restocked from 8 to 58');
        
        // Verify high stock product was not affected
        HandsMen_Product__c unchangedProduct = [
            SELECT Id, Stock_Quantity__c
            FROM HandsMen_Product__c
            WHERE Id = :highStockProduct.Id
        ];
        System.assertEquals(25, unchangedProduct.Stock_Quantity__c, 'High stock product should remain unchanged');
    }
    
    @IsTest
    static void testInventoryBatchJobWithNoLowStock() {
        Test.startTest();
        
        // Create only products with sufficient stock (>= 10)
        List<HandsMen_Product__c> products = new List<HandsMen_Product__c>();
        
        HandsMen_Product__c product1 = new HandsMen_Product__c(
            Name = 'Sufficient Stock Product 1',
            Price__c = 100,
            Stock_Quantity__c = 15
        );
        products.add(product1);
        
        HandsMen_Product__c product2 = new HandsMen_Product__c(
            Name = 'Sufficient Stock Product 2',
            Price__c = 200,
            Stock_Quantity__c = 20
        );
        products.add(product2);
        
        insert products;
        
        // Create inventory records
        List<Inventory__c> inventories = new List<Inventory__c>();
        for (HandsMen_Product__c product : products) {
            Inventory__c inventory = new Inventory__c(
                Product__c = product.Id,
                Stock_Quantity__c = product.Stock_Quantity__c,
                Warehouse__c = 'Main Warehouse'
            );
            inventories.add(inventory);
        }
        insert inventories;
        
        // Execute the batch job
        InventoryBatchJob batchJob = new InventoryBatchJob();
        Database.executeBatch(batchJob, 200);
        
        Test.stopTest();
        
        // Verify no products were updated (since none had stock < 10)
        List<HandsMen_Product__c> updatedProducts = [
            SELECT Id, Stock_Quantity__c
            FROM HandsMen_Product__c
            WHERE Id IN :products
        ];
        
        System.assertEquals(15, updatedProducts[0].Stock_Quantity__c, 'Product 1 stock should remain unchanged');
        System.assertEquals(20, updatedProducts[1].Stock_Quantity__c, 'Product 2 stock should remain unchanged');
    }
    
    @IsTest
    static void testInventoryBatchJobSchedulable() {
        Test.startTest();
        
        // Test the schedulable interface
        InventoryBatchJob schedulableJob = new InventoryBatchJob();
        String jobId = System.schedule('Test Inventory Restock Job', '0 0 2 * * ?', schedulableJob);
        
        Test.stopTest();
        
        // Verify the job was scheduled successfully
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
        
        // Verify the scheduled job exists
        List<CronTrigger> scheduledJobs = [
            SELECT Id, CronJobDetail.Name, State
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        
        System.assertEquals(1, scheduledJobs.size(), 'Scheduled job should exist');
        System.assertEquals('Test Inventory Restock Job', scheduledJobs[0].CronJobDetail.Name, 'Job name should match');
    }
    
    @IsTest
    static void testInventoryBatchJobWithZeroStock() {
        Test.startTest();
        
        // Create products with zero stock
        List<HandsMen_Product__c> zeroStockProducts = new List<HandsMen_Product__c>();
        
        HandsMen_Product__c product1 = new HandsMen_Product__c(
            Name = 'Zero Stock Product 1',
            Price__c = 100,
            Stock_Quantity__c = 0
        );
        zeroStockProducts.add(product1);
        
        HandsMen_Product__c product2 = new HandsMen_Product__c(
            Name = 'Zero Stock Product 2',
            Price__c = 150,
            Stock_Quantity__c = 0
        );
        zeroStockProducts.add(product2);
        
        insert zeroStockProducts;
        
        // Create inventory records with minimum valid stock (1 instead of 0)
        List<Inventory__c> inventories = new List<Inventory__c>();
        for (HandsMen_Product__c product : zeroStockProducts) {
            Inventory__c inventory = new Inventory__c(
                Product__c = product.Id,
                Stock_Quantity__c = 1, // Use 1 instead of 0 to satisfy validation
                Warehouse__c = 'Main Warehouse'
            );
            inventories.add(inventory);
        }
        insert inventories;
        
        // Execute the batch job
        InventoryBatchJob batchJob = new InventoryBatchJob();
        Database.executeBatch(batchJob, 200);
        
        Test.stopTest();
        
        // Verify zero stock products were restocked
        List<HandsMen_Product__c> updatedProducts = [
            SELECT Id, Stock_Quantity__c
            FROM HandsMen_Product__c
            WHERE Id IN :zeroStockProducts
            ORDER BY Name
        ];
        
        System.assertEquals(50, updatedProducts[0].Stock_Quantity__c, 'Zero stock product 1 should be restocked to 50');
        System.assertEquals(50, updatedProducts[1].Stock_Quantity__c, 'Zero stock product 2 should be restocked to 50');
    }
    
    @IsTest
    static void testInventoryBatchJobErrorHandling() {
        Test.startTest();
        
        // Create a product with low stock
        HandsMen_Product__c product = new HandsMen_Product__c(
            Name = 'Test Product for Error Handling',
            Price__c = 100,
            Stock_Quantity__c = 5
        );
        insert product;
        
        // Create inventory record
        Inventory__c inventory = new Inventory__c(
            Product__c = product.Id,
            Stock_Quantity__c = product.Stock_Quantity__c,
            Warehouse__c = 'Main Warehouse'
        );
        insert inventory;
        
        // Execute the batch job
        InventoryBatchJob batchJob = new InventoryBatchJob();
        Database.executeBatch(batchJob, 200);
        
        Test.stopTest();
        
        // Verify the product was processed (this tests that the try-catch doesn't prevent normal operation)
        HandsMen_Product__c updatedProduct = [
            SELECT Id, Stock_Quantity__c
            FROM HandsMen_Product__c
            WHERE Id = :product.Id
        ];
        
        System.assertEquals(55, updatedProduct.Stock_Quantity__c, 'Product should be restocked despite error handling code');
    }
}
