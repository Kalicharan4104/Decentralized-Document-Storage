# Decentralized Document Storage

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Solidity](https://img.shields.io/badge/Solidity-0.8.20-363636?logo=solidity)
![Hardhat](https://img.shields.io/badge/Hardhat-2.19.0-FFF100?logo=hardhat)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📋 Project Description

**Decentralized Document Storage** is a cutting-edge blockchain-based document management system that revolutionizes how we store, share, and control access to digital documents. Built on the Core blockchain and designed for integration with IPFS (InterPlanetary File System), this platform provides enterprise-grade security, immutable audit trails, and granular access control—all without relying on centralized servers.

### The Problem We Solve

Traditional document storage solutions suffer from:
- **Single points of failure**: Centralized servers can be compromised or go offline
- **Privacy concerns**: Third parties have access to your sensitive documents
- **Limited control**: Difficult to manage granular permissions and sharing
- **No audit trails**: Hard to track who accessed what and when
- **Vendor lock-in**: Documents trapped in proprietary systems
- **High costs**: Expensive storage fees and subscription models

### Our Solution

Decentralized Document Storage leverages blockchain technology to provide:

✅ **True Ownership**: You own your documents, stored on decentralized infrastructure  
✅ **End-to-End Encryption**: Documents are encrypted client-side before upload  
✅ **Granular Access Control**: Four-tier permission system (None, View, Edit, Admin)  
✅ **Immutable Audit Trails**: Every action recorded on the blockchain  
✅ **Version Control**: Complete document history with rollback capability  
✅ **Time-Limited Sharing**: Set expiration dates for temporary access  
✅ **Zero Downtime**: Distributed architecture ensures 24/7 availability  
✅ **Cost-Effective**: Pay only for blockchain transactions, not storage fees  

### How It Works

1. **Upload**: User encrypts document locally and uploads to IPFS
2. **Store**: Document hash and encrypted key stored on blockchain
3. **Share**: Grant access to specific users with defined permissions
4. **Access**: Authorized users retrieve document hash and decrypt
5. **Track**: All actions logged immutably on the blockchain

## 🎯 Project Vision

Our vision is to create a **global, censorship-resistant document infrastructure** that puts users in complete control of their digital assets. We envision a future where:

### Short-Term Vision (2025)
- Become the go-to platform for decentralized document management
- Reach 100,000+ active users storing sensitive documents securely
- Integrate with major IPFS providers and decentralized storage networks
- Partner with enterprises requiring compliant document management
- Launch mobile applications for iOS and Android

### Mid-Term Vision (2026-2027)
- Expand to multi-chain support (Ethereum, Polygon, Avalanche, BSC)
- Implement advanced features like smart contracts for document workflows
- Build a marketplace for document verification services
- Enable DAO governance for protocol upgrades
- Integrate with popular productivity tools (Google Docs, Microsoft Office)

### Long-Term Vision (2028+)
- Establish as the standard for legal document authentication
- Serve governments, healthcare, education, and finance sectors
- Process millions of documents daily across the globe
- Achieve full decentralization with community governance
- Pioneer new use cases in AI, IoT, and Web3 ecosystems

### Impact Goals

🌍 **Global Accessibility**: Make secure document storage available to everyone  
🏥 **Healthcare**: Enable portable, patient-controlled medical records  
🎓 **Education**: Verifiable academic credentials across institutions  
⚖️ **Legal**: Tamper-proof legal documents and contracts  
🏢 **Enterprise**: Compliant document management for businesses  
🔐 **Privacy**: Protect whistleblowers, journalists, and activists  

## 🚀 Key Features

### 1. **Secure Document Upload** 🔐
```solidity
function uploadDocument(
    string documentHash,
    string encryptedKey,
    uint256 size,
    string documentType,
    string metadata
)
```

**Features:**
- Upload encrypted documents to decentralized storage
- Store document hash and encrypted symmetric key on-chain
- Support for any file type (PDF, DOCX, images, videos, etc.)
- Metadata storage in JSON format
- Automatic size validation (configurable max: 100MB default)
- Unique document ID generation using cryptographic hashing
- Owner automatically granted admin access
- Event emission for transparent tracking

**Security:**
- Client-side encryption before upload
- Only document hash stored on-chain (not actual content)
- Encrypted key ensures only authorized users can decrypt
- Immutable record of document creation

**Use Cases:**
- Store sensitive business documents
- Archive legal contracts and agreements
- Manage personal identification documents
- Preserve academic transcripts and certificates
- Backup important photos and videos

### 2. **Granular Access Control & Sharing** 👥
```solidity
function shareDocument(
    bytes32 documentId,
    address user,
    AccessLevel accessLevel,
    uint256 expiresAt
)
```

**Four-Tier Access System:**

| Level | Permissions | Use Case |
|-------|-------------|----------|
| **None** (0) | No access | Revoked users |
| **View** (1) | Read-only | Viewers, auditors |
| **Edit** (2) | Modify documents | Collaborators, editors |
| **Admin** (3) | Full control | Co-owners, managers |

**Advanced Features:**
- **Time-Limited Access**: Set expiration timestamps for temporary sharing
- **Multiple Sharing**: Share with unlimited users simultaneously
- **Access Updates**: Modify permissions for existing users
- **Hierarchical Control**: Only admins can grant/revoke access
- **Automatic Expiration**: Access automatically revoked after expiry
- **Audit Trail**: Track who granted access and when

**Sharing Scenarios:**
- Share tax documents with accountant (View, 30-day expiry)
- Collaborate on project proposals (Edit, permanent)
- Grant lawyer admin access to legal documents
- Temporary access for auditors during review period
- Family access to shared photo albums

### 3. **Document Version Control** 📝
```solidity
function updateDocument(
    bytes32 documentId,
    string newDocumentHash,
    string newEncryptedKey,
    uint256 newSize,
    string newMetadata
)
```

**Versioning Features:**
- **Complete History**: Every version preserved permanently
- **Automatic Archiving**: Old versions marked as archived
- **Version Linking**: Chain of custody via previousVersionId
- **Access Inheritance**: New versions inherit access permissions
- **Rollback Capability**: Access any previous version
- **Incremental Versioning**: Automatic version numbering
- **Update Tracking**: Timestamp and updater recorded

**Version Metadata:**
- Version number (auto-incremented)
- Link to previous version
- Creator and updater information
- Creation and update timestamps
- Document size tracking

**Use Cases:**
- Track contract amendments and revisions
- Maintain document edit history for compliance
- Rollback to previous versions if needed
- Audit changes over time
- Collaborative document editing

### 4. **Comprehensive Query System** 🔍

**Get Document Information:**
```solidity
function getDocument(bytes32 documentId)
```
Returns: Hash, owner, timestamps, size, type, metadata, status, version

**Access Control Queries:**
```solidity
function hasAccess(bytes32 documentId, address user, AccessLevel level)
function getDocumentAccessList(bytes32 documentId)
```

**User Document Management:**
```solidity
function getUserDocuments(address user)  // Documents you own
function getSharedDocuments(address user)  // Documents shared with you
```

**System Statistics:**
```solidity
function getSystemStats()
```
Returns: Total documents, active, archived, deleted, total storage

### 5. **Document Lifecycle Management** 🗂️

**Archive Documents:**
```solidity
function archiveDocument(bytes32 documentId)
```
- Move inactive documents to archived status
- Preserve access permissions
- Maintain in version history
- Free up active document space

**Delete Documents:**
```solidity
function deleteDocument(bytes32 documentId)
```
- Soft delete (data remains on-chain)
- Only owner can delete
- Updates storage statistics
- Maintains audit trail

**Revoke Access:**
```solidity
function revokeAccess(bytes32 documentId, address user)
```
- Remove user permissions
- Admin-only operation
- Cannot revoke owner access
- Event emission for transparency

### 6. **Security & Emergency Controls** 🛡️

**Pausable Contract:**
- Owner can pause all operations in emergencies
- Protects against attacks or vulnerabilities
- Can be unpaused when safe

**Access Validation:**
- Every operation checks permissions
- Automatic expiration enforcement
- Reentrancy protection on all state changes
- Owner-only administrative functions

**Event Logging:**
- DocumentUploaded
- DocumentShared
- DocumentUpdated
- AccessRevoked
- DocumentDeleted
- DocumentArchived

### 7. **Statistics & Analytics** 📊

Track system-wide metrics:
- Total documents created
- Active vs archived vs deleted counts
- Total storage utilization
- Per-user document counts
- Access grant history
- Version control statistics

## 💡 Future Scope

### Phase 1: Enhanced Core Features (Q1-Q2 2025)

#### IPFS Integration
- **Automatic Upload**: Direct IPFS upload from interface
- **Pinning Services**: Integration with Pinata, Infura, Web3.Storage
- **Content Addressing**: Automatic CID generation
- **Redundancy**: Multi-node pinning for reliability
- **Gateway Selection**: Choose preferred IPFS gateways

#### Advanced Encryption
- **Multiple Algorithms**: Support AES-256, ChaCha20, RSA
- **Key Management**: Integrated key derivation and storage
- **Public Key Encryption**: Asymmetric encryption for sharing
- **Zero-Knowledge Proofs**: Prove document ownership without revealing content
- **Quantum-Resistant**: Prepare for post-quantum cryptography

#### Enhanced Access Control
- **Role-Based Access**: Define custom roles (Reviewer, Approver, etc.)
- **Conditional Access**: Time-based, location-based restrictions
- **Multi-Signature**: Require multiple approvals for sensitive actions
- **Delegation**: Allow users to delegate permissions temporarily
- **Access Requests**: Users can request access from owners

### Phase 2: User Experience & Integration (Q3-Q4 2025)

#### Web & Mobile Applications
- **Progressive Web App**: Cross-platform web application
- **Native Mobile Apps**: iOS and Android applications
- **Desktop Applications**: Electron-based desktop clients
- **Browser Extensions**: Chrome, Firefox, Edge plugins
- **Mobile SDKs**: Easy integration for developers

#### Productivity Integrations
- **Google Drive**: Import/export documents
- **Microsoft Office**: OneDrive integration
- **Dropbox**: Migration and sync tools
- **Notion**: Embed decentralized documents
- **Slack/Discord**: Share documents in team chats

#### User Interface Features
- **Drag-and-Drop Upload**: Simple file upload
- **Folder Organization**: Create folder structures
- **Search & Filter**: Full-text search across documents
- **Thumbnails & Previews**: Visual document browsing
- **Batch Operations**: Bulk upload, share, delete

### Phase 3: Enterprise & Compliance (2026)

#### Enterprise Features
- **Team Workspaces**: Shared team document repositories
- **Admin Dashboard**: Comprehensive management interface
- **Billing & Quotas**: Usage-based pricing models
- **SSO Integration**: SAML, OAuth, Active Directory
- **Audit Logs**: Detailed compliance reporting
- **White-Label**: Custom branding for enterprises

#### Compliance & Certifications
- **GDPR Compliance**: Right to deletion, data portability
- **HIPAA Ready**: Healthcare document management
- **SOC 2**: Security and availability controls
- **ISO 27001**: Information security standards
- **FINRA**: Financial industry compliance
- **Legal Hold**: E-discovery and litigation support

#### Advanced Security
- **Multi-Factor Authentication**: 2FA, biometric authentication
- **Hardware Wallet Support**: Ledger, Trezor integration
- **Encrypted Backup**: Automated encrypted backups
- **Intrusion Detection**: Monitor for suspicious activity
- **Penetration Testing**: Regular security audits
- **Bug Bounty Program**: Community security testing

### Phase 4: Blockchain & Decentralization (2027)

#### Multi-Chain Support
- **EVM Chains**: Ethereum, Polygon, Avalanche, BSC, Arbitrum
- **Non-EVM**: Solana, Cardano, Polkadot
- **Layer 2**: Optimism, zkSync, StarkNet
- **Cross-Chain Bridge**: Transfer documents between chains
- **Chain Selection**: Users choose preferred blockchain

#### Decentralized Governance
- **DAO Formation**: Community-driven development
- **Governance Token**: DDS token for voting rights
- **Proposal System**: On-chain governance proposals
- **Treasury Management**: Community fund allocation
- **Protocol Upgrades**: Decentralized upgrade mechanism

#### Token Economics
- **Storage Rewards**: Earn tokens for providing storage
- **Verification Rewards**: Reward document verifiers
- **Staking**: Stake tokens for premium features
- **Fee Distribution**: Share protocol fees with token holders
- **Liquidity Mining**: Bootstrap initial adoption

### Phase 5: Advanced Technology (2028+)

#### AI & Machine Learning
- **OCR**: Extract text from images and PDFs
- **Classification**: Auto-categorize documents
- **Summarization**: Generate document summaries
- **Translation**: Multi-language support
- **Anomaly Detection**: Identify unusual access patterns
- **Smart Search**: Natural language document search

#### Smart Contract Workflows
- **Document Approval Flows**: Multi-stage approval processes
- **Conditional Actions**: Trigger actions based on conditions
- **Escrow Integration**: Trustless document exchanges
- **Time-Locked Documents**: Automatic reveal at specific times
- **Oracle Integration**: External data triggers

#### Decentralized Identity
- **DID Integration**: W3C Decentralized Identifiers
- **Verifiable Credentials**: Issue and verify credentials
- **Self-Sovereign Identity**: User-controlled identity
- **Reputation Systems**: Build trust through verification
- **Sybil Resistance**: Prevent fake accounts

### Phase 6: Industry-Specific Solutions

#### Healthcare
- **Medical Records**: Patient-controlled health data
- **Prescription Management**: Secure prescription storage
- **Insurance Claims**: Streamlined claim processing
- **Clinical Trials**: Secure research data management
- **Telemedicine**: Encrypted consultation records

#### Education
- **Digital Diplomas**: Blockchain-verified degrees
- **Transcript Management**: Portable academic records
- **Certificate Issuance**: Automated certification
- **Learning Portfolios**: Student work collection
- **Accreditation**: Institution verification

#### Legal & Government
- **Smart Contracts**: Self-executing agreements
- **Notarization**: Blockchain-based notary services
- **Property Records**: Title and deed management
- **Court Documents**: Secure filing and access
- **Identity Documents**: Government-issued IDs

#### Supply Chain
- **Product Certificates**: Authenticity verification
- **Shipping Documents**: Bill of lading, invoices
- **Compliance Certificates**: ISO, FDA, CE documents
- **Customs Documentation**: Import/export paperwork
- **Quality Assurance**: Test results and certifications

## 🛠️ Technical Architecture

### System Components

```
┌─────────────────────────────────────────────────────────┐
│                   User Interface Layer                   │
│  (Web App, Mobile App, Browser Extension, Desktop)      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                  Application Layer                       │
│  (Client-side Encryption, IPFS Upload, Wallet Connect)  │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                 Blockchain Layer                         │
│        (Smart Contract - Document Storage)               │
│  • Upload Documents    • Share Documents                 │
│  • Access Control      • Version Control                 │
│  • Statistics          • Emergency Controls              │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                  Storage Layer                           │
│  (IPFS, Arweave, Filecoin, or other decentralized)     │
└─────────────────────────────────────────────────────────┘
```

### Smart Contract Architecture

```
Project.sol (Decentralized Document Storage)
│
├── Data Structures
│   ├── Document (struct)
│   ├── AccessControl (struct)
│   ├── DocumentStats (struct)
│   ├── AccessLevel (enum)
│   └── DocumentStatus (enum)
│
├── Core Functions
│   ├── uploadDocument()
│   ├── shareDocument()
│   └── updateDocument()
│
├── Query Functions
│   ├── getDocument()
│   ├── hasAccess()
│   ├── getDocumentAccessList()
│   ├── getUserDocuments()
│   ├── getSharedDocuments()
│   └── getSystemStats()
│
├── Management Functions
│   ├── revokeAccess()
│   ├── deleteDocument()
│   ├── archiveDocument()
│   ├── setMaxDocumentSize()
│   ├── pause()
│   └── unpause()
│
└── Security
    ├── ReentrancyGuard
    ├── Ownable
    ├── Pausable
    └── Access validation
```

### Data Flow

**Document Upload:**
```
1. User selects file → 2. Client encrypts → 3. Upload to IPFS
4. Get CID → 5. Call uploadDocument() → 6. Store on blockchain
7. Return document ID → 8. User can share
```

**Document Access:**
```
1. User requests document → 2. Check permissions on-chain
3. If authorized → 4. Retrieve encrypted key and IPFS hash
5. Fetch from IPFS → 6. Decrypt client-side → 7. Display
```

### Security Model

**Multi-Layer Security:**
1. **Client-Side Encryption**: Documents encrypted before leaving user's device
2. **Blockchain Access Control**: Permissions enforced by smart contract
3. **Decentralized Storage**: No single point of failure
4. **Immutable Audit**: All actions recorded permanently
5. **Time-Locks**: Automatic access expiration
6. **Emergency Pause**: Quick response to threats

## 📦 Installation & Setup

### Prerequisites

```bash
Node.js >= 16.0.0
npm >= 7.0.0
Git
Hardhat
MetaMask or compatible Web3 wallet
```

### Quick Start

```bash
# 1. Clone the repository
git clone 
cd Decentralized-Document-Storage

# 2. Install dependencies
npm install

# 3. Create environment file
cp .env.example .env

# 4. Configure .env with your private key
# PRIVATE_KEY=your_private_key_without_0x_prefix

# 5. Compile smart contracts
npm run compile

# 6. Run tests (optional but recommended)
npm test

# 7. Deploy to Core Testnet 2
npm run deploy
```

### Environment Configuration

Edit `.env` file:

```bash
PRIVATE_KEY=your_private_key_here
CORE_TESTNET_RPC=https://rpc.test2.btcs.network
GAS_PRICE=auto
GAS_LIMIT=8000000
```

### Get Testnet Tokens

1. Visit Core Testnet Faucet: https://faucet.test2.btcs.network
2. Enter your wallet address
3. Request testnet tokens
4. Wait for confirmation

## 📖 Usage Guide

### Uploading a Document

```javascript
const { ethers } = require("hardhat");

// Connect to deployed contract
const contractAddress = "0x...";
const Project = await ethers.getContractFactory("Project");
const project = Project.attach(contractAddress);

// Upload document
const tx = await project.uploadDocument(
  "QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",  // IPFS hash (CID)
  "encryptedSymmetricKey123",            // Encrypted key
  1024000,                                // Size in bytes (1MB)
  "application/pdf",                      // MIME type
  '{"title":"My Document","tags":["important"]}'  // Metadata JSON
);

const receipt = await tx.wait();
console.log("Document uploaded!", receipt);
```

### Sharing a Document

```javascript
// Share with another user
const documentId = "0x..."; // From upload receipt
const userAddress = "0x..."; // Address to share with

await project.shareDocument(
  documentId,
  userAddress,
  2,  // AccessLevel.Edit
  0   // No expiration (or timestamp for expiry)
);

console.log("Document shared successfully!");
```

### Retrieving a Document

```javascript
// Get document information
const docInfo = await project.getDocument(documentId);

console.log("Document Hash:", docInfo.documentHash);
console.log("Encrypted Key:", docInfo.encryptedKey);
console.log("Owner:", docInfo.owner);
console.log("Size:", docInfo.size.toString(), "bytes");
console.log("Type:", docInfo.documentType);
console.log("Metadata:", docInfo.metadata);
console.log("Status:", docInfo.status);
console.log("Version:", docInfo.version.toString());
```

### Updating a Document

```javascript
// Create new version
const newVersionTx = await project.updateDocument(
  documentId,
  "QmYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",  // New IPFS hash
  "newEncryptedKey456",                   // New encrypted key
  2048000,                                // New size
  '{"title":"My Document v2"}'            // Updated metadata
);

const receipt = await newVersionTx.wait();
console.log("New version created!");
```

### Checking Access

```javascript
// Check if user has access
const hasViewAccess = await project.hasAccess(
  documentId,
  userAddress,
  1  // AccessLevel.View
);

console.log("Has view access:", hasViewAccess);
```

### Getting User Documents

```javascript
// Get all documents owned by user
const myDocs = await project.getUserDocuments(myAddress);
console.log("My documents:", myDocs);

// Get documents shared with user
const sharedDocs = await project.getSharedDocuments(myAddress);
console.log("Shared with me:", sharedDocs);
```

### Revoking Access

```javascript
// Revoke user's access
await project.revokeAccess(documentId, userAddress);
console.log("Access revoked");
```

### System Statistics

```javascript
// Get overall system stats
const stats = await project.getSystemStats();

console.log("Total Documents:", stats.totalDocuments.toString());
console.log("Active:", stats.activeDocuments.toString());
console.log("Archived:", stats.archivedDocuments.toString());
console.log("Deleted:", stats.deletedDocuments.toString());
console.log("Total Storage:", stats.totalSize.toString(), "bytes");
```

## 🧪 Testing

### Run All Tests

```bash
npm test
```

### Run with Coverage

```bash
npm run coverage
```

### Run Specific Test

```bash
npx hardhat test test/DocumentStorage.test.js
```

### Local Testing

```bash
# Terminal 1: Start local node
npx hardhat node

# Terminal 2: Run tests on local node
npx hardhat test --network localhost
```

## 🚀 Deployment

### Deploy to Core Testnet 2

```bash
npm run deploy
```

### Deploy to Other Networks

```bash
# Local network
npm run deploy:local

# Custom network (configure in hardhat.config.js)
npx hardhat run scripts/deploy.js --network 
```

### Verify Contract

```bash
npx hardhat verify --network core_testnet 
```

## 📚 API Reference

### Enums

```solidity
enum AccessLevel {
    None,     // 0 - No access
    View,     // 1 - Read-only
    Edit,     // 2 - Can modify
    Admin     // 3 - Full control
}

enum DocumentStatus {
    Active,    // 0 - Currently active
    Archived,  // 1 - Archived version
    Deleted    // 2 - Soft deleted
}
```

### Core Functions

#### `uploadDocument()`
```solidity
function uploadDocument(
    string memory _documentHash,
    string memory _encryptedKey,
    uint256 _size,
    string memory _documentType,
    string memory _metadata
) external returns (bytes32 documentId)
```

**Parameters:**
- `_documentHash`: IPFS CID or storage identifier
- `_encryptedKey`: Encrypted symmetric key for document
- `_size`: Document size in bytes
- `_documentType`: MIME type (e.g., "application/pdf")
- `_metadata`: JSON string with additional info

**Returns:** Unique document ID

**Events:** `DocumentUploaded`

#### `shareDocument()`
```solidity
function shareDocument(
    bytes32 _documentId,
    address _user,
    AccessLevel _accessLevel,
    uint256 _expiresAt
) external
```

**Parameters:**
- `_documentId`: Document to share
- `_user`: Address to grant access
- `_accessLevel`: Permission level (1-3)
- `_expiresAt`: Unix timestamp for expiration (0 = never)

**Events:** `DocumentShared`

#### `updateDocument()`
```solidity
function updateDocument(
    bytes32 _documentId,
    string memory _newDocumentHash,
    string memory _newEncryptedKey,
    uint256 _newSize,
    string memory _newMetadata
) external returns (bytes32 newVersionId)
```

**Returns:** New version document ID

**Events:** `DocumentUpdated`

### Query Functions

All view functions (no gas cost):

- `getDocument(bytes32)` - Complete document information
- `hasAccess(bytes32, address, AccessLevel)` - Check user permissions
- `getDocumentAccessList(bytes32)` - List all users with access
- `getUserDocuments(address)` - User's owned documents
- `getSharedDocuments(address)` - Documents shared with user
- `getSystemStats()` - Platform statistics
- `getTotalDocuments()` - Total document count
- `getTotalStorageUsed()` - Total storage in bytes

### Management Functions

- `revokeAccess(bytes32, address)` - Remove user access
- `deleteDocument(bytes32)` - Soft delete document
- `archiveDocument(bytes32)` - Archive document
- `setMaxDocumentSize(uint256)` - Update size limit (owner only)
- `pause()` - Pause contract (owner only)
- `unpause()` - Unpause contract (owner only)

## 🔒 Security Best Practices

### For Users

✅ **Always encrypt documents client-side** before uploading  
✅ **Use strong, unique encryption keys** for each document  
✅ **Store encryption keys securely** (password manager, hardware wallet)  
✅ **Regularly review access permissions** for your documents  
✅ **Use access expiration** for temporary sharing  
✅ **Keep private keys secure** - never share them  
✅ **Verify contract address** before interacting  
✅ **Test with small files first** before uploading important documents

### For Developers

✅ **Validate all inputs** thoroughly  
✅ **Use reentrancy guards** on state-changing functions  
✅ **Implement access control** on sensitive operations  
✅ **Emit events** for all important actions  
✅ **Test extensively** before mainnet deployment  
✅ **Conduct security audits** for production use  
✅ **Monitor for anomalies** in production  
✅ **Have emergency response plan** ready


Address: 0xf42ab90876e4b6def95823d7549a082a50c194be
<img width="943" height="442" alt="image" src="https://github.com/user-attachments/assets/3689749c-d68d-4603-baf0-8824d351e2e1" />
