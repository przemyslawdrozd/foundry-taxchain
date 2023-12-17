# TaxContract
TaxContract is a Solidity smart contract developed for managing tax payments within a decentralized environment, specifically tailored for the Ethereum blockchain.

Key Features
Tax Office Address Management: The contract initializes with a specific tax office address, setting the tax authority within the contract.

Tax Payer Registration: Allows new tax payers to register themselves. It checks for duplicates to prevent double registration.

Tax Payment System: Facilitates tax payments from registered tax payers. The contract calculates the tax amount, ensures that the payment is above a minimum threshold, and transfers the net amount to the receiver.

Tax Calculation: Implements a simple tax calculation logic, deducting a fixed percentage (5%) from the transaction value as tax.

# Deploy on sepolia
make deploy ARGS="--network sepolia"