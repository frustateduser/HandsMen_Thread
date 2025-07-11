@isTest
public class OrderTriggerHandlerTest {
  @isTest
  static void testConfirmedStatus_ValidQuantity() {
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = 600
    );
    Test.startTest();
    insert order;
    Test.stopTest();

    HandsMen_Order__c result = [
      SELECT Id, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals(
      600,
      result.Quantity__c,
      'Confirmed order with valid quantity should insert successfully'
    );
  }

  @isTest
  static void testConfirmedStatus_InvalidQuantity() {
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Confirmed',
      Quantity__c = 400
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
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = 300
    );
    Test.startTest();
    insert order;
    Test.stopTest();

    HandsMen_Order__c result = [
      SELECT Id, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals(
      300,
      result.Quantity__c,
      'Pending order with valid quantity should insert successfully'
    );
  }

  @isTest
  static void testPendingStatus_InvalidQuantity() {
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Pending',
      Quantity__c = 100
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
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Rejection',
      Quantity__c = 0
    );
    Test.startTest();
    insert order;
    Test.stopTest();

    HandsMen_Order__c result = [
      SELECT Id, Quantity__c
      FROM HandsMen_Order__c
      WHERE Id = :order.Id
    ];
    System.assertEquals(
      0,
      result.Quantity__c,
      'Rejection order with quantity 0 should insert successfully'
    );
  }

  @isTest
  static void testRejectionStatus_InvalidQuantity() {
    HandsMen_Order__c order = new HandsMen_Order__c(
      Status__c = 'Rejection',
      Quantity__c = 100
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
}
