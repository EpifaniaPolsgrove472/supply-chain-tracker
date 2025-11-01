## Description

This PR introduces the Product Registry smart contract for a transparent supply chain tracking system. The contract enables product registration, custody chain tracking, and provenance verification on the Stacks blockchain.

## Features Implemented

### Core Functionality
- **Product Registration**: Register products with unique identifiers, manufacturer details, and metadata
- **Custody Transfer**: Secure transfer mechanism with authorization checks and transfer history
- **Status Management**: Track product status throughout supply chain lifecycle (registered, in-transit, delivered, verified, retired)
- **Operator Authorization**: Delegate transfer permissions to authorized operators
- **Metadata Management**: Store and retrieve detailed product information including batch numbers, certifications, and physical properties

### Data Structures
- Product records with comprehensive tracking fields
- Custody history with sequential transfer logging
- Transfer count tracking for audit purposes
- Operator authorization mapping
- Product metadata storage for additional details

### Security Features
- Owner verification for all state-changing operations
- Authorization checks for transfers and updates
- Immutable audit trail of all custody changes
- Protection against invalid transfers (self-transfers blocked)
- Status validation to prevent invalid state transitions

## Contract Details

**Contract Name**: `product-registry`
**Lines of Code**: 309
**Language**: Clarity

### Public Functions
1. `register-product` - Register new products in the system
2. `transfer-product` - Transfer custody with location and notes
3. `update-product-status` - Update product status by owner
4. `authorize-operator` - Grant transfer permissions
5. `revoke-operator` - Remove transfer permissions
6. `set-product-metadata` - Store additional product details

### Read-Only Functions
1. `get-product` - Retrieve product information
2. `get-custody-record` - Get specific custody transfer record
3. `get-product-transfer-count` - Count total transfers
4. `is-operator-authorized` - Check operator authorization
5. `get-product-metadata` - Retrieve metadata
6. `get-current-product-id` - Get current product ID counter
7. `verify-ownership` - Verify claimed ownership
8. `get-product-status` - Get current product status
9. `get-product-owner` - Get current owner

## Testing

Contract passes `clarinet check` with no errors. All syntax is valid and ready for deployment.

## Technical Notes

- Uses `stacks-block-height` for timestamp tracking
- Implements sequential custody history with unique sequence numbers
- Employs data maps for efficient storage and retrieval
- No cross-contract calls or trait implementations (standalone contract)
- Error codes defined for clear error handling

## Use Cases

- Manufacturing supply chains
- Logistics and distribution tracking
- Retail product authentication
- Quality assurance and compliance
- Consumer provenance verification
