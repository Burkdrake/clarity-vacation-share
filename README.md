# Vacation Share Smart Contract

A blockchain-based smart contract for managing shared vacation package bookings on the Stacks network.

## Features
- Create vacation packages with customizable shares and pricing
- Book shares in available vacation packages 
- Cancel bookings with configurable refund policies
- Track bookings and availability
- Secure payments and refunds handled through smart contract

## Use Cases
- Timeshare management
- Group vacation bookings
- Resort share ownership
- Vacation club memberships

The contract allows property owners to create vacation packages by specifying details like location, number of shares, price per share, and cancellation fee percentage. Users can purchase shares in these packages and cancel their bookings with automated refund processing. All transactions and ownership records are stored securely on the blockchain.

## Cancellation Policy
Each vacation package can have its own cancellation fee percentage set by the owner. When a booking is cancelled:
- The shares are returned to the available pool
- A refund is processed automatically minus the cancellation fee
- The booking record is removed from the system
