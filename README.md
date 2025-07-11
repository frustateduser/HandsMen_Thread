# HandsMen Salesforce Project 🛠️

A comprehensive Salesforce application for managing customer relationships, inventory, orders, and marketing campaigns in a retail/e-commerce environment.

## 📋 Project Overview

This Salesforce DX project contains metadata for a complete business management system designed for HandsMen - a retail business focused on tools and hardware. The application includes custom objects, automation, and business logic to streamline operations.

## 🏗️ Architecture

### Custom Objects
- **HandsMen_Customer__c** - Customer management with loyalty tracking
- **HandsMen_Order__c** - Order processing and fulfillment
- **HandsMen_Product__c** - Product catalog and inventory
- **Inventory__c** - Stock management and warehouse tracking
- **Marketing_Campaign__c** - Campaign management and customer targeting

### Automation
- **OrderTrigger** - Handles order-related business logic
- **OrderTriggerHandler** - Contains the trigger handler implementation
- **OrderTriggerHandlerTest** - Comprehensive test coverage

### Security & Access
- **Experience_Profile_Manager** - Portal user management
- **Inventory_Manager_Permission** - Inventory access controls
- **Marketing_Team_Permission** - Marketing team permissions
- **Permission_Platform_1** - Platform-specific permissions

## 🚀 Key Features

- **Customer Management**: Track customer information, loyalty status, and purchase history
- **Order Processing**: Complete order lifecycle with validation and automation
- **Inventory Control**: Real-time stock tracking with quantity validations
- **Marketing Automation**: Campaign management with customer segmentation
- **Data Validation**: Business rules ensuring data integrity
- **Role-Based Security**: Granular permissions for different user types

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd HandsMen_Thread
   ```

2. **Authenticate with your Salesforce org**
   ```bash
   sf org login web
   ```

3. **Deploy the metadata**
   ```bash
   sf project deploy start --source-dir force-app
   ```

## 🔧 Development

### Prerequisites
- Salesforce CLI
- VS Code with Salesforce Extension Pack
- Node.js (for testing framework)

### Running Tests
```bash
sf apex run test --test-level RunLocalTests
```

### Code Quality
- ESLint configuration for Lightning Web Components
- Prettier formatting rules
- Husky pre-commit hooks

## 📊 Data Model

```
HandsMen_Customer__c
├── FirstName__c, LastName__c, Full_Name__c
├── Email__c, Phone__c
├── Loyalty_Status__c
└── Total_Purchases__c

HandsMen_Order__c
├── Customer__c (Lookup)
├── Quantity__c, Total_Amount__c
└── Status__c

HandsMen_Product__c
├── Order__c (Lookup)
├── SKU__c, Price__c
└── Stock_Quantity__c

Inventory__c
├── Product__c (Lookup)
├── Stock_Quantity__c, Stock_Status__c
└── Warehouse__c

Marketing_Campaign__c
├── HandsMen_Customer__c (Lookup)
├── Start_Date__c, End_Date__c
└── Campaign details
```

## 🛡️ Validation Rules

- **Email Validation**: Ensures proper email format for customers
- **Total Amount Validation**: Validates order totals are positive
- **Stock Quantity Validation**: Prevents negative inventory levels

## 🔄 Continuous Integration

This project is configured for:
- Automated testing on commit
- Code quality checks
- Metadata validation

## 📖 Documentation

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Lightning Platform Development](https://developer.salesforce.com/docs/atlas.en-us.platform_dev_guide.meta/platform_dev_guide/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🏷️ Tags

`salesforce` `salesforce-dx` `crm` `inventory-management` `order-processing` `retail` `apex` `lightning`
