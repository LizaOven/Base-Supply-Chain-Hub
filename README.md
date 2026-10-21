# Aura Supply Chain Hub

A decentralized supply chain provenance tracker deployed on the Base L2 network. Designed to bring immutable transparency to enterprise logistics, this protocol allows verified manufacturers to mint digital twins of real-world products and track their lifecycle across multiple custodians.

## Core Mechanics
* **State-Driven Provenance:** Products pass through dynamic, verifiable stages (e.g., Manufactured -> In Transit -> Customs). Each stage update requires cryptographic authorization from the current custodian.
* **Chain of Custody:** The `transferProductOwnership` function strictly logs handoffs between distinct entities (manufacturers, distributors, retailers), creating an unbreakable audit trail on the ledger.
* **Automated Hub Treasury:** Integrates micro-fees for product registration, automatically aggregating network revenue into a secure platform treasury managed by the protocol administrator.

## Architecture & Security
Built with Solidity `0.8.37`. The contract completely isolates custody changes from stage updates to prevent unauthorized state manipulation by legacy owners, ensuring O(1) gas efficiency during logistics tracking.
