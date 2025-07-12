public class InventoryStockDeductionHandler {
    
    public static void deductStockOnOrderConfirmation(List<HandsMen_Order__c> orderList) {
        deductStockOnOrderConfirmation(orderList, null);
    }
    
    public static void deductStockOnOrderConfirmation(List<HandsMen_Order__c> orderList, Map<Id, HandsMen_Order__c> oldOrderMap) {
        
        List<HandsMen_Order__c> ordersToProcess = new List<HandsMen_Order__c>();
        
        for (HandsMen_Order__c order : orderList) {
            if (order.Status__c == 'Confirmed' || order.Status__c == 'Completed') {
                if (oldOrderMap == null || 
                    (oldOrderMap.containsKey(order.Id) && 
                     oldOrderMap.get(order.Id).Status__c != 'Confirmed' && 
                     oldOrderMap.get(order.Id).Status__c != 'Completed')) {
                    ordersToProcess.add(order);
                }
            }
        }
        
        if (ordersToProcess.isEmpty()) {
            return;
        }
        
        Set<Id> productIds = new Set<Id>();
        for (HandsMen_Order__c order : ordersToProcess) {
            if (order.HandsMen_Product__c != null) {
                productIds.add(order.HandsMen_Product__c);
            }
        }
        
        if (productIds.isEmpty()) {
            System.debug('No products found in orders for stock deduction');
            return;
        }
    
        Map<Id, Inventory__c> productToInventoryMap = new Map<Id, Inventory__c>();
        List<Inventory__c> inventoryRecords = [
            SELECT Id, Product__c, Stock_Quantity__c, Stock_Status__c
            FROM Inventory__c
            WHERE Product__c IN :productIds
        ];
        
        for (Inventory__c inventory : inventoryRecords) {
            productToInventoryMap.put(inventory.Product__c, inventory);
        }
        
        List<Inventory__c> inventoriesToUpdate = new List<Inventory__c>();
        List<String> errorMessages = new List<String>();
        
        for (HandsMen_Order__c order : ordersToProcess) {
            if (order.HandsMen_Product__c != null && order.Quantity__c != null) {
                Inventory__c inventory = productToInventoryMap.get(order.HandsMen_Product__c);
                
                if (inventory != null) {
                    
                    if (inventory.Stock_Quantity__c >= order.Quantity__c) {
                        
                        inventory.Stock_Quantity__c -= order.Quantity__c;
                        
                        updateStockStatus(inventory);
                        
                        inventoriesToUpdate.add(inventory);
                        
                        System.debug('Stock deducted for Product: ' + order.HandsMen_Product__c + 
                                   ', Quantity: ' + order.Quantity__c + 
                                   ', Remaining Stock: ' + inventory.Stock_Quantity__c);
                    } else {
                        
                        String errorMsg = 'Insufficient stock available. Required: ' + 
                                        order.Quantity__c + ', Available: ' + inventory.Stock_Quantity__c;
                        order.addError(errorMsg);
                        errorMessages.add(errorMsg);
                    }
                } else {
                    
                    String errorMsg = 'No inventory record found for the selected product';
                    order.addError(errorMsg);
                    errorMessages.add(errorMsg);
                }
            }
        }
        
        if (!inventoriesToUpdate.isEmpty()) {
            try {
                update inventoriesToUpdate;
                System.debug('Successfully updated ' + inventoriesToUpdate.size() + ' inventory records');
            } catch (DmlException e) {
                System.debug('Error updating inventory records: ' + e.getMessage());
                // Add errors to orders if inventory update fails
                for (HandsMen_Order__c order : ordersToProcess) {
                    order.addError('Failed to update inventory: ' + e.getMessage());
                }
            }
        }
        
        if (!errorMessages.isEmpty()) {
            System.debug('Stock deduction errors: ' + String.join(errorMessages, '; '));
        }
    }
    
    
    private static void updateStockStatus(Inventory__c inventory) {
        System.debug('Stock quantity updated to: ' + inventory.Stock_Quantity__c);
    }
    
    
    public static void restoreStockOnOrderCancellation(List<HandsMen_Order__c> orderList, Map<Id, HandsMen_Order__c> oldOrderMap) {
        
        List<HandsMen_Order__c> ordersToProcess = new List<HandsMen_Order__c>();
        
        for (HandsMen_Order__c order : orderList) {
            if ((order.Status__c == 'Cancelled' || order.Status__c == 'Rejection') &&
                oldOrderMap != null && oldOrderMap.containsKey(order.Id) &&
                (oldOrderMap.get(order.Id).Status__c == 'Confirmed' || 
                 oldOrderMap.get(order.Id).Status__c == 'Completed')) {
                ordersToProcess.add(order);
            }
        }
        
        if (ordersToProcess.isEmpty()) {
            return;
        }
        
        
        Set<Id> productIds = new Set<Id>();
        for (HandsMen_Order__c order : ordersToProcess) {
            if (order.HandsMen_Product__c != null) {
                productIds.add(order.HandsMen_Product__c);
            }
        }
        
        if (productIds.isEmpty()) {
            return;
        }
        
        
        Map<Id, Inventory__c> productToInventoryMap = new Map<Id, Inventory__c>();
        List<Inventory__c> inventoryRecords = [
            SELECT Id, Product__c, Stock_Quantity__c, Stock_Status__c
            FROM Inventory__c
            WHERE Product__c IN :productIds
        ];
        
        for (Inventory__c inventory : inventoryRecords) {
            productToInventoryMap.put(inventory.Product__c, inventory);
        }
        
        List<Inventory__c> inventoriesToUpdate = new List<Inventory__c>();
        
        for (HandsMen_Order__c order : ordersToProcess) {
            if (order.HandsMen_Product__c != null && oldOrderMap.containsKey(order.Id)) {
                HandsMen_Order__c oldOrder = oldOrderMap.get(order.Id);
                if (oldOrder.Quantity__c != null && oldOrder.Quantity__c > 0) {
                    Inventory__c inventory = productToInventoryMap.get(order.HandsMen_Product__c);
                    
                    if (inventory != null) {
                        // Restore stock based on the original confirmed quantity
                        inventory.Stock_Quantity__c += oldOrder.Quantity__c;
                        
                        // Update stock status based on new quantity
                        updateStockStatus(inventory);
                        
                        inventoriesToUpdate.add(inventory);
                        
                        System.debug('Stock restored for Product: ' + order.HandsMen_Product__c + 
                                   ', Original Quantity: ' + oldOrder.Quantity__c + 
                                   ', New Stock: ' + inventory.Stock_Quantity__c);
                    }
                }
            }
        }
        
        if (!inventoriesToUpdate.isEmpty()) {
            try {
                update inventoriesToUpdate;
                System.debug('Successfully restored stock for ' + inventoriesToUpdate.size() + ' inventory records');
            } catch (DmlException e) {
                System.debug('Error restoring inventory records: ' + e.getMessage());
            }
        }
    }
    
    
    public static void validateStockAvailability(List<HandsMen_Order__c> orderList) {
        
        List<HandsMen_Order__c> ordersToValidate = new List<HandsMen_Order__c>();
        
        for (HandsMen_Order__c order : orderList) {
            if ((order.Status__c == 'Confirmed' || order.Status__c == 'Completed') && 
                order.HandsMen_Product__c != null && order.Quantity__c != null) {
                ordersToValidate.add(order);
            }
        }
        
        if (ordersToValidate.isEmpty()) {
            return;
        }
        
        Set<Id> productIds = new Set<Id>();
        for (HandsMen_Order__c order : ordersToValidate) {
            productIds.add(order.HandsMen_Product__c);
        }
        
        Map<Id, Inventory__c> productToInventoryMap = new Map<Id, Inventory__c>();
        List<Inventory__c> inventoryRecords = [
            SELECT Id, Product__c, Stock_Quantity__c, Stock_Status__c
            FROM Inventory__c
            WHERE Product__c IN :productIds
        ];
        
        for (Inventory__c inventory : inventoryRecords) {
            productToInventoryMap.put(inventory.Product__c, inventory);
        }
        
        for (HandsMen_Order__c order : ordersToValidate) {
            Inventory__c inventory = productToInventoryMap.get(order.HandsMen_Product__c);
            
            if (inventory == null) {
                order.addError('No inventory record found for the selected product');
            } else if (inventory.Stock_Quantity__c < order.Quantity__c) {
                order.addError('Insufficient stock available. Required: ' + 
                             order.Quantity__c + ', Available: ' + inventory.Stock_Quantity__c);
            }
        }
    }
}
