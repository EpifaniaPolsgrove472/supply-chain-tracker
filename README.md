# Supply Chain Tracker

A transparent blockchain-based supply chain tracking system with provenance verification built on Stacks using Clarity smart contracts.

## Overview

Supply Chain Tracker provides an immutable and transparent solution for tracking products throughout their entire lifecycle. From manufacturing to final delivery, every step in the supply chain is recorded on the blockchain, ensuring authenticity, accountability, and traceability.

## Features

- **Product Registration**: Register products with unique identifiers and detailed metadata
- **Custody Chain Tracking**: Track every transfer of ownership with timestamped records
- **Provenance Verification**: Verify the complete history and authenticity of any product
- **Ownership Management**: Secure transfer of product custody between authorized parties
- **Transparent History**: Immutable audit trail of all product movements and status changes
- **Status Updates**: Real-time status tracking throughout the supply chain journey

## Core Components

### Product Registry Contract

The `product-registry` contract is the backbone of the system, providing:

- Unique product identification and registration
- Custody chain management
- Transfer authorization and verification
- Product status tracking
- Historical record maintenance
- Owner verification mechanisms

## Use Cases

- **Manufacturing**: Track raw materials and components from source to production
- **Logistics**: Monitor product movement through distribution networks
- **Retail**: Verify product authenticity and origin before sale
- **Quality Assurance**: Maintain detailed records for compliance and auditing
- **Consumer Transparency**: Enable end customers to verify product provenance

## Technology Stack

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity
- **Development Framework**: Clarinet

## Getting Started

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) installed
- Node.js and npm

### Installation

```bash
# Clone the repository
git clone <repository-url>

# Navigate to project directory
cd supply-chain-tracker

# Install dependencies
npm install
```

### Development

```bash
# Check contract syntax
clarinet check

# Run tests
npm test

# Start local development environment
clarinet integrate
```

## Contract Architecture

The system uses a modular architecture where the Product Registry contract manages all product-related operations:

- **Registration**: Products are registered with unique IDs and initial custody information
- **Transfer Protocol**: Secure transfer mechanism requiring authorization from current owner
- **State Management**: Comprehensive tracking of product status and location
- **Query Interface**: Functions to retrieve product information and custody history

## Security Features

- **Authorization Checks**: Only authorized parties can perform operations
- **Immutable Records**: All transactions are permanently recorded on the blockchain
- **Validation Logic**: Strict validation prevents invalid state changes
- **Owner Verification**: Multi-level verification ensures custody transfer security

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License

## Contact

For questions and support, please open an issue in the repository.
