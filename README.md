# HandsMen Thread - Salesforce Business Solution 🛠️

A comprehensive Salesforce DX project for HandsMen retail business management, including customer relationships, inventory, orders, and marketing campaigns.

## 📋 Project Overview

Complete Salesforce metadata synchronization with 300+ files across 16 metadata types, providing end-to-end business management capabilities for retail operations.

### � Repository Status

- **Test Coverage**: 41/41 tests passing (100%)
- **Batch Processing**: Automated loyalty points & inventory management
- **Inventory System**: Real-time stock control with validation
- **Last Updated**: July 12, 2025

## 🤖 Automated Systems

### Batch Processing
- **Loyalty Points**: Weekly calculation every Sunday 12 AM (1 point per $1 spent)
- **Inventory Restocking**: Automated restocking for products < 10 units
- **Scheduling**: Configurable timing with error handling

### Inventory Management
- **Stock Deduction**: Real-time reduction on order confirmation
- **Stock Restoration**: Automatic restoration on order cancellation
- **Validation**: Prevents overselling and negative inventory

##  Loyalty Management

### Tier System
- **Gold**: $1,000+ total purchases (1.5x bonus)
- **Silver**: $500-$999 total purchases (1.25x bonus)
- **Bronze**: $100-$499 total purchases (1.1x bonus)
- **Automatic tier assignment** based on purchase history
## 📋 Core Objects

### Business Entities
- **HandsMen_Customer__c**: Customer management with loyalty tracking
- **HandsMen_Order__c**: Order processing with inventory integration  
- **HandsMen_Product__c**: Product catalog with stock management
- **Inventory__c**: Stock levels and availability tracking
- **HandsMen_Campaign__c**: Marketing campaign management

## 🚀 Getting Started

### Prerequisites
- Salesforce CLI (sfdx)
- Git
- VS Code with Salesforce extensions

### Quick Deploy
```bash
# Clone repository
git clone https://github.com/frustateduser/HandsMen_Thread.git

# Deploy to org
sfdx force:source:deploy --sourcepath force-app

# Run tests
sfdx force:apex:test:run --wait 10 --resultformat human

# Schedule batch jobs
sfdx force:apex:execute -f scripts/apex/schedule-loyalty-batch.apex
```

## 🔧 Development

### Key Classes
- `LoyaltyPointsBatchJob.cls` - Weekly points calculation
- `InventoryBatchJob.cls` - Automated restocking
- `InventoryStockDeductionHandler.cls` - Real-time inventory control
- `OrderTriggerHandler.cls` - Order validation and processing
- `LoyaltyStatusHandler.cls` - Customer tier management

### Test Coverage
- **Total Tests**: 41/41 passing (100%)
- **Batch Jobs**: 8 test methods with full coverage
- **Inventory**: 10 comprehensive test scenarios
- **Orders**: 16 validation and business logic tests
- **Loyalty**: 7 tier management test cases


