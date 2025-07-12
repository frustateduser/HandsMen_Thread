@isTest
public class OrderTriggerHandlerTest {
  
  /**
   * @description Creates test data for order trigger tests
   */
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
    
    // Create test product
    HandsMen_Product__c product = new HandsMen_Product__c(
      Name = 'Test Product',
      SKU__c = 'TP-001',
      Price__c = 100.00
    );
    insert product;
    
    // Create test inventory
    Inventory__c inventory = new Inventory__c(
      Product__c = product.Id,
      Stock_Quantity__c = 1000
    );
    insert inventory;
  }

  @isTest
  static void testConfirmedStatus_ValidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = 600,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    insert order;
    Test.stopTest();

    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals('Confirmed', result.Status__c, 'Order status should be Confirmed');
    System.assertEquals(600, result.Quantity__c, 'Order quantity should be 600');
    System.assertNotEquals(null, result.Id, 'Order should be successfully inserted');
  }

  @isTest
  static void testConfirmedStatus_InvalidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = 400,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    try {
      insert order;
      System.assert(
        false,
        'Expected DMLException was not thrown for invalid confirmed quantity'
      );
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be more than 500'),
        'Correct error message expected'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testPendingStatus_ValidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = 300,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    insert order;
    Test.stopTest();

    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals('Pending', result.Status__c, 'Order status should be Pending');
    System.assertEquals(300, result.Quantity__c, 'Order quantity should be 300');
    System.assertNotEquals(null, result.Id, 'Order should be successfully inserted');
  }

  @isTest
  static void testPendingStatus_InvalidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = 100,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    try {
      insert order;
      System.assert(
        false,
        'Expected DMLException was not thrown for invalid pending quantity'
      );
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be more than 200'),
        'Correct error message expected'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testRejectionStatus_ValidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Rejection',
      Quantity__c = 0,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    insert order;
    Test.stopTest();

    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals('Rejection', result.Status__c, 'Order status should be Rejection');
    System.assertEquals(0, result.Quantity__c, 'Order quantity should be 0');
    System.assertNotEquals(null, result.Id, 'Order should be successfully inserted');
  }

  @isTest
  static void testRejectionStatus_InvalidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Rejection',
      Quantity__c = 100,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    try {
      insert order;
      System.assert(
        false,
        'Expected DMLException was not thrown for invalid rejection quantity'
      );
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be 0'),
        'Correct error message expected'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testConfirmedStatus_NullQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = null,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    try {
      insert order;
      System.assert(
        false,
        'Expected DMLException was not thrown for null confirmed quantity'
      );
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be more than 500'),
        'Correct error message expected for null quantity'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testPendingStatus_NullQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = null,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    try {
      insert order;
      System.assert(
        false,
        'Expected DMLException was not thrown for null pending quantity'
      );
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be more than 200'),
        'Correct error message expected for null quantity'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testRejectionStatus_NullQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Rejection',
      Quantity__c = null,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    Test.startTest();
    try {
      insert order;
      System.assert(
        false,
        'Expected DMLException was not thrown for null rejection quantity'
      );
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be 0'),
        'Correct error message expected for null quantity'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testUpdatePendingToConfirmed_ValidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];

    // Create pending order first
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = 300, // Valid for pending
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    insert order;

    // Update to confirmed with valid quantity
    order.Status__c = 'Confirmed';
    order.Quantity__c = 600; // Valid for confirmed (> 500)

    Test.startTest();
    update order;
    Test.stopTest();

    // Verify the update was successful
    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals('Confirmed', result.Status__c, 'Status should be updated to Confirmed');
    System.assertEquals(600, result.Quantity__c, 'Quantity should be updated to 600');
  }

  @isTest
  static void testUpdatePendingToConfirmed_InvalidQuantity() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];

    // Create pending order first
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

    // Verify order remains unchanged after failed update
    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals('Pending', result.Status__c, 'Status should remain Pending after failed update');
    System.assertEquals(300, result.Quantity__c, 'Quantity should remain 300 after failed update');
  }

  @isTest
  static void testUpdateConfirmedToRejection() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];

    // Create confirmed order first
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = 600, // Valid for confirmed
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    insert order;

    // Update to rejection with valid quantity
    order.Status__c = 'Rejection';
    order.Quantity__c = 0; // Valid for rejection

    Test.startTest();
    update order;
    Test.stopTest();

    // Verify the update was successful
    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals('Rejection', result.Status__c, 'Status should be updated to Rejection');
    System.assertEquals(0, result.Quantity__c, 'Quantity should be updated to 0');
  }

  @isTest
  static void testBoundaryValues_ConfirmedStatus() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    // Test exactly 500 (should fail - must be > 500)
    HandsMen_Order__c order500 = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = 500,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    
    Test.startTest();
    try {
      insert order500;
      System.assert(false, 'Expected DMLException for quantity = 500');
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be more than 500'),
        'Error message should indicate quantity must be more than 500'
      );
    }
    
    // Test 501 (should pass - just above boundary)
    HandsMen_Order__c order501 = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = 501,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    insert order501; // Should succeed
    Test.stopTest();
    
    // Verify the successful insert
    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order501.Id
    ];
    System.assertEquals('Confirmed', result.Status__c, 'Status should be Confirmed');
    System.assertEquals(501, result.Quantity__c, 'Quantity should be 501');
  }

  @isTest
  static void testBoundaryValues_PendingStatus() {
    // Get test data
    HandsMen_Customer__c customer = [SELECT Id FROM HandsMen_Customer__c LIMIT 1];
    HandsMen_Product__c product = [SELECT Id FROM HandsMen_Product__c LIMIT 1];
    
    // Test exactly 200 (should fail - must be > 200)
    HandsMen_Order__c order200 = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = 200,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    
    Test.startTest();
    try {
      insert order200;
      System.assert(false, 'Expected DMLException for quantity = 200');
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Quantity must be more than 200'),
        'Error message should indicate quantity must be more than 200'
      );
    }
    
    // Test 201 (should pass - just above boundary)
    HandsMen_Order__c order201 = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = 201,
      Customer__c = customer.Id,
      HandsMen_Product__c = product.Id
    );
    insert order201; // Should succeed
    Test.stopTest();
    
    // Verify the successful insert
    HandsMen_Order__c result = [
      SELECT Id, Status__c, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order201.Id
    ];
    System.assertEquals('Pending', result.Status__c, 'Status should be Pending');
    System.assertEquals(201, result.Quantity__c, 'Quantity should be 201');
  }
}