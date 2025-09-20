# EquityVote

A blockchain-based system for shareholder proposals and board member nominations built on the Stacks blockchain using Clarity smart contracts.

## Description

EquityVote enables shareholders to create proposals, nominate board members, and vote on various corporate governance matters in a transparent and immutable way. The system provides a decentralized platform for corporate decision-making, ensuring transparency, security, and fair representation based on shareholding.

## Features

- **Shareholder Management**: Register and track shareholder ownership
- **Proposal Creation**: Create corporate governance proposals with different types (general, financial, governance)
- **Voting System**: Weighted voting based on shareholding with time-bound voting periods
- **Board Nominations**: Nominate and vote for board members with qualification tracking
- **Transparency**: All votes and proposals are recorded immutably on the blockchain
- **Access Control**: Share-based voting rights and minimum share requirements for proposals
- **Time-bound Voting**: Automatic voting period enforcement

## Technical Specifications

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity
- **Clarity Version**: 2
- **Epoch**: 2.5
- **Test Framework**: Vitest with Clarinet SDK

### Key Parameters

- **Proposal Voting Period**: 1,440 blocks (~10 days)
- **Nomination Voting Period**: 2,160 blocks (~15 days)
- **Minimum Shares for Proposal**: 1,000 shares
- **Block Time**: ~10 minutes (Stacks network)

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v14 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd EquityVote
```

2. Install dependencies:
```bash
cd EquityVote_contract
npm install
```

3. Check contract syntax:
```bash
clarinet check
```

4. Run tests:
```bash
npm test
```

## Usage Examples

### Deploying the Contract

```bash
clarinet deploy --testnet
```

### Interacting with the Contract

#### Register a Shareholder (Contract Owner Only)

```clarity
(contract-call? .EquityVote register-shareholder 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u5000)
```

#### Create a Proposal

```clarity
(contract-call? .EquityVote create-proposal
    "Annual Budget Approval"
    "Proposal to approve the annual budget of $10M for fiscal year 2024"
    "financial")
```

#### Vote on a Proposal

```clarity
;; Vote FOR proposal ID 0
(contract-call? .EquityVote vote-on-proposal u0 true)

;; Vote AGAINST proposal ID 0
(contract-call? .EquityVote vote-on-proposal u0 false)
```

#### Nominate a Board Member

```clarity
(contract-call? .EquityVote nominate-board-member
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7
    "Chief Technology Officer"
    "20 years experience in blockchain technology and corporate governance")
```

#### Vote for a Board Nomination

```clarity
(contract-call? .EquityVote vote-for-nomination u0)
```

## Contract Functions Documentation

### Public Functions

#### `register-shareholder`
- **Description**: Register shares for a shareholder (contract owner only)
- **Parameters**:
  - `shareholder` (principal): Address of the shareholder
  - `shares` (uint): Number of shares to register
- **Access**: Contract owner only
- **Returns**: `(response bool uint)`

#### `create-proposal`
- **Description**: Create a new governance proposal
- **Parameters**:
  - `title` (string-ascii 100): Proposal title
  - `description` (string-ascii 500): Detailed description
  - `proposal-type` (string-ascii 20): Type ("general", "financial", "governance")
- **Requirements**: Minimum 1,000 shares
- **Returns**: `(response uint uint)` - Proposal ID

#### `vote-on-proposal`
- **Description**: Vote on an existing proposal
- **Parameters**:
  - `proposal-id` (uint): ID of the proposal
  - `vote-for` (bool): true for YES, false for NO
- **Requirements**: Must be a registered shareholder, voting period active, hasn't voted before
- **Returns**: `(response bool uint)`

#### `nominate-board-member`
- **Description**: Nominate someone for a board position
- **Parameters**:
  - `nominee` (principal): Address of the nominee
  - `position` (string-ascii 50): Position title
  - `qualifications` (string-ascii 300): Nominee qualifications
- **Requirements**: Minimum 1,000 shares
- **Returns**: `(response uint uint)` - Nomination ID

#### `vote-for-nomination`
- **Description**: Vote for a board nomination
- **Parameters**:
  - `nomination-id` (uint): ID of the nomination
- **Requirements**: Must be a registered shareholder, voting period active, hasn't voted before
- **Returns**: `(response bool uint)`

### Read-Only Functions

#### `get-shareholder-shares`
- **Description**: Get number of shares for a shareholder
- **Parameters**: `shareholder` (principal)
- **Returns**: `(optional uint)`

#### `get-proposal`
- **Description**: Get proposal details
- **Parameters**: `proposal-id` (uint)
- **Returns**: Proposal object with voting results

#### `get-nomination`
- **Description**: Get nomination details
- **Parameters**: `nomination-id` (uint)
- **Returns**: Nomination object with vote count

#### `has-voted-on-proposal`
- **Description**: Check if user has voted on a proposal
- **Parameters**: `proposal-id` (uint), `voter` (principal)
- **Returns**: `bool`

#### `has-voted-on-nomination`
- **Description**: Check if user has voted on a nomination
- **Parameters**: `nomination-id` (uint), `voter` (principal)
- **Returns**: `bool`

#### `get-proposal-count`
- **Description**: Get total number of proposals created
- **Returns**: `uint`

#### `get-nomination-count`
- **Description**: Get total number of nominations created
- **Returns**: `uint`

#### `is-proposal-voting-active`
- **Description**: Check if proposal voting is still active
- **Parameters**: `proposal-id` (uint)
- **Returns**: `bool`

#### `is-nomination-voting-active`
- **Description**: Check if nomination voting is still active
- **Parameters**: `nomination-id` (uint)
- **Returns**: `bool`

#### `get-proposal-result`
- **Description**: Get proposal voting result
- **Parameters**: `proposal-id` (uint)
- **Returns**: "passed", "failed", or "not-found"

## Deployment Guide

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deploy --testnet
```

### Mainnet Deployment

1. Configure your mainnet settings in `settings/Mainnet.toml`
2. Ensure thorough testing on testnet
3. Deploy using Clarinet:
```bash
clarinet deploy --mainnet
```

### Post-Deployment Steps

1. Register initial shareholders using the contract owner account
2. Set up proper access controls
3. Communicate contract address to stakeholders
4. Monitor contract interactions and voting activities

## Development

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

### Contract Structure

```
EquityVote_contract/
├── contracts/
│   └── EquityVote.clar          # Main contract
├── settings/
│   ├── Devnet.toml              # Development settings
│   ├── Testnet.toml             # Testnet settings
│   └── Mainnet.toml             # Mainnet settings
├── tests/                       # Test files
├── Clarinet.toml               # Project configuration
└── package.json                # Dependencies and scripts
```

## Security Considerations

### Access Control
- Only contract owner can register shareholders
- Minimum share requirements prevent spam proposals
- One-vote-per-address prevents double voting

### Time-based Security
- Voting periods are enforced at the blockchain level
- No retroactive voting allowed
- Clear voting deadlines prevent manipulation

### Data Integrity
- All votes are immutably recorded on-chain
- Proposal and nomination data cannot be modified after creation
- Transparent vote counting with public verification

### Best Practices
- Verify shareholder registrations carefully
- Monitor proposal creation for appropriate content
- Regular auditing of voting patterns
- Implement governance procedures for contract upgrades

## Error Codes

- `u100`: ERR-OWNER-ONLY - Only contract owner can perform this action
- `u101`: ERR-NOT-SHAREHOLDER - Address is not a registered shareholder
- `u102`: ERR-PROPOSAL-NOT-FOUND - Proposal ID does not exist
- `u103`: ERR-VOTING-ENDED - Voting period has expired
- `u104`: ERR-ALREADY-VOTED - Address has already voted
- `u105`: ERR-INSUFFICIENT-SHARES - Not enough shares to perform action
- `u106`: ERR-INVALID-NOMINEE - Invalid nominee address
- `u107`: ERR-NOMINATION-NOT-FOUND - Nomination ID does not exist

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

[Add your license information here]

## Support

For questions, issues, or contributions, please [create an issue](link-to-issues) or contact the development team.