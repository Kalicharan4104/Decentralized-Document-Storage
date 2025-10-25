// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Decentralized Document Storage
 * @dev A secure, decentralized document storage system with encryption and access control
 * Supports document versioning, sharing, and collaborative access management
 */
contract Project is Ownable, ReentrancyGuard, Pausable {
    
    // Enum for access levels
    enum AccessLevel {
        None,
        View,
        Edit,
        Admin
    }
    
    // Enum for document status
    enum DocumentStatus {
        Active,
        Archived,
        Deleted
    }
    
    // Struct to represent a document
    struct Document {
        bytes32 documentId;
        string documentHash; // IPFS hash or encrypted storage hash
        string encryptedKey; // Encrypted symmetric key for document
        address owner;
        uint256 createdAt;
        uint256 updatedAt;
        uint256 size; // Document size in bytes
        string documentType; // MIME type or file extension
        string metadata; // JSON metadata
        DocumentStatus status;
        uint256 version;
        bytes32 previousVersionId;
    }
    
    // Struct for access control
    struct AccessControl {
        address user;
        AccessLevel level;
        uint256 grantedAt;
        uint256 expiresAt; // 0 for no expiration
        address grantedBy;
    }
    
    // Struct for document statistics
    struct DocumentStats {
        uint256 totalDocuments;
        uint256 activeDocuments;
        uint256 archivedDocuments;
        uint256 deletedDocuments;
        uint256 totalSize;
    }
    
    // State variables
    mapping(bytes32 => Document) public documents;
    mapping(bytes32 => mapping(address => AccessControl)) public documentAccess;
    mapping(bytes32 => address[]) public documentAccessList;
    mapping(address => bytes32[]) public userDocuments;
    mapping(address => bytes32[]) public sharedWithUser;
    
    bytes32[] public allDocumentIds;
    
    uint256 public totalDocumentsCreated;
    uint256 public totalStorageUsed;
    uint256 public maxDocumentSize;
    
    // Events
    event DocumentUploaded(
        bytes32 indexed documentId,
        address indexed owner,
        string documentHash,
        uint256 size,
        uint256 timestamp
    );
    
    event DocumentUpdated(
        bytes32 indexed documentId,
        bytes32 indexed newVersionId,
        address indexed updatedBy,
        uint256 timestamp
    );
    
    event DocumentShared(
        bytes32 indexed documentId,
        address indexed owner,
        address indexed sharedWith,
        AccessLevel accessLevel,
        uint256 timestamp
    );
    
    event AccessRevoked(
        bytes32 indexed documentId,
        address indexed user,
        address indexed revokedBy,
        uint256 timestamp
    );
    
    event DocumentDeleted(
        bytes32 indexed documentId,
        address indexed deletedBy,
        uint256 timestamp
    );
    
    event DocumentArchived(
        bytes32 indexed documentId,
        address indexed archivedBy,
        uint256 timestamp
    );
    
    constructor() Ownable(msg.sender) {
        totalDocumentsCreated = 0;
        totalStorageUsed = 0;
        maxDocumentSize = 100 * 1024 * 1024; // 100 MB default
    }
    
    /**
     * @dev Uploads a new document to the decentralized storage
     * @param _documentHash IPFS hash or storage identifier
     * @param _encryptedKey Encrypted symmetric key for document decryption
     * @param _size Document size in bytes
     * @param _documentType MIME type or file extension
     * @param _metadata JSON metadata string
     * @return documentId Unique identifier for the document
     */
    function uploadDocument(
        string memory _documentHash,
        string memory _encryptedKey,
        uint256 _size,
        string memory _documentType,
        string memory _metadata
    ) external whenNotPaused returns (bytes32) {
        require(bytes(_documentHash).length > 0, "Document hash required");
        require(_size > 0 && _size <= maxDocumentSize, "Invalid document size");
        require(bytes(_documentType).length > 0, "Document type required");
        
        // Generate unique document ID
        bytes32 documentId = keccak256(
            abi.encodePacked(
                _documentHash,
                msg.sender,
                block.timestamp,
                totalDocumentsCreated
            )
        );
        
        require(documents[documentId].owner == address(0), "Document ID collision");
        
        // Create new document
        documents[documentId] = Document({
            documentId: documentId,
            documentHash: _documentHash,
            encryptedKey: _encryptedKey,
            owner: msg.sender,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            size: _size,
            documentType: _documentType,
            metadata: _metadata,
            status: DocumentStatus.Active,
            version: 1,
            previousVersionId: bytes32(0)
        });
        
        // Grant owner admin access
        documentAccess[documentId][msg.sender] = AccessControl({
            user: msg.sender,
            level: AccessLevel.Admin,
            grantedAt: block.timestamp,
            expiresAt: 0,
            grantedBy: msg.sender
        });
        
        documentAccessList[documentId].push(msg.sender);
        
        // Track document
        allDocumentIds.push(documentId);
        userDocuments[msg.sender].push(documentId);
        totalDocumentsCreated++;
        totalStorageUsed += _size;
        
        emit DocumentUploaded(documentId, msg.sender, _documentHash, _size, block.timestamp);
        
        return documentId;
    }
    
    /**
     * @dev Shares a document with another user
     * @param _documentId ID of the document to share
     * @param _user Address of the user to share with
     * @param _accessLevel Access level to grant
     * @param _expiresAt Expiration timestamp (0 for no expiration)
     */
    function shareDocument(
        bytes32 _documentId,
        address _user,
        AccessLevel _accessLevel,
        uint256 _expiresAt
    ) external nonReentrant whenNotPaused {
        require(documents[_documentId].owner != address(0), "Document does not exist");
        require(_user != address(0), "Invalid user address");
        require(_user != msg.sender, "Cannot share with yourself");
        require(_accessLevel != AccessLevel.None, "Invalid access level");
        require(
            _expiresAt == 0 || _expiresAt > block.timestamp,
            "Invalid expiration time"
        );
        
        // Check if sender has admin access
        require(
            _hasAccess(_documentId, msg.sender, AccessLevel.Admin),
            "Only admin can share documents"
        );
        
        require(documents[_documentId].status == DocumentStatus.Active, "Document not active");
        
        // Grant or update access
        bool isNewAccess = documentAccess[_documentId][_user].user == address(0);
        
        documentAccess[_documentId][_user] = AccessControl({
            user: _user,
            level: _accessLevel,
            grantedAt: block.timestamp,
            expiresAt: _expiresAt,
            grantedBy: msg.sender
        });
        
        if (isNewAccess) {
            documentAccessList[_documentId].push(_user);
            sharedWithUser[_user].push(_documentId);
        }
        
        emit DocumentShared(_documentId, documents[_documentId].owner, _user, _accessLevel, block.timestamp);
    }
    
    /**
     * @dev Updates an existing document (creates new version)
     * @param _documentId ID of the document to update
     * @param _newDocumentHash New IPFS hash or storage identifier
     * @param _newEncryptedKey New encrypted symmetric key
     * @param _newSize New document size
     * @param _newMetadata Updated metadata
     * @return newVersionId ID of the new version
     */
    function updateDocument(
        bytes32 _documentId,
        string memory _newDocumentHash,
        string memory _newEncryptedKey,
        uint256 _newSize,
        string memory _newMetadata
    ) external nonReentrant whenNotPaused returns (bytes32) {
        require(documents[_documentId].owner != address(0), "Document does not exist");
        require(bytes(_newDocumentHash).length > 0, "Document hash required");
        require(_newSize > 0 && _newSize <= maxDocumentSize, "Invalid document size");
        
        // Check if sender has edit access
        require(
            _hasAccess(_documentId, msg.sender, AccessLevel.Edit),
            "Insufficient permissions"
        );
        
        require(documents[_documentId].status == DocumentStatus.Active, "Document not active");
        
        Document memory oldDoc = documents[_documentId];
        
        // Generate new version ID
        bytes32 newVersionId = keccak256(
            abi.encodePacked(
                _newDocumentHash,
                msg.sender,
                block.timestamp,
                oldDoc.version + 1
            )
        );
        
        // Create new version
        documents[newVersionId] = Document({
            documentId: newVersionId,
            documentHash: _newDocumentHash,
            encryptedKey: _newEncryptedKey,
            owner: oldDoc.owner,
            createdAt: oldDoc.createdAt,
            updatedAt: block.timestamp,
            size: _newSize,
            documentType: oldDoc.documentType,
            metadata: _newMetadata,
            status: DocumentStatus.Active,
            version: oldDoc.version + 1,
            previousVersionId: _documentId
        });
        
        // Copy access controls to new version
        address[] memory accessUsers = documentAccessList[_documentId];
        for (uint256 i = 0; i < accessUsers.length; i++) {
            address user = accessUsers[i];
            documentAccess[newVersionId][user] = documentAccess[_documentId][user];
            documentAccessList[newVersionId].push(user);
        }
        
        // Archive old version
        documents[_documentId].status = DocumentStatus.Archived;
        
        // Update tracking
        allDocumentIds.push(newVersionId);
        userDocuments[oldDoc.owner].push(newVersionId);
        totalStorageUsed = totalStorageUsed - oldDoc.size + _newSize;
        
        emit DocumentUpdated(_documentId, newVersionId, msg.sender, block.timestamp);
        
        return newVersionId;
    }
    
    /*
     * @dev Retrieves document information
     * @param _documentId ID of the document
     * @return Document details
     */
    function getDocument(bytes32 _documentId) external view returns (
        string memory documentHash,
        string memory encryptedKey,
        address owner,
        uint256 createdAt,
        uint256 updatedAt,
        uint256 size,
        string memory documentType,
        string memory metadata,
        DocumentStatus status,
        uint256 version,
        bytes32 previousVersionId
    ) {
        require(documents[_documentId].owner != address(0), "Document does not exist");
        
        // Check if user has access
        require(
            _hasAccess(_documentId, msg.sender, AccessLevel.View) || msg.sender == owner,
            "Access denied"
        );
        
        Document memory doc = documents[_documentId];
        
        return (
            doc.documentHash,
            doc.encryptedKey,
            doc.owner,
            doc.createdAt,
            doc.updatedAt,
            doc.size,
            doc.documentType,
            doc.metadata,
            doc.status,
            doc.version,
            doc.previousVersionId
        );
    }
    
    /*
     * @dev Checks if a user has specific access level to a document
     */
    function hasAccess(
        bytes32 _documentId,
        address _user,
        AccessLevel _requiredLevel
    ) external view returns (bool) {
        return _hasAccess(_documentId, _user, _requiredLevel);
    }
    
    /**
     * @dev Internal function to check access
     */
    function _hasAccess(
        bytes32 _documentId,
        address _user,
        AccessLevel _requiredLevel
    ) internal view returns (bool) {
        AccessControl memory access = documentAccess[_documentId][_user];
        
        if (access.user == address(0)) return false;
        if (access.expiresAt > 0 && block.timestamp > access.expiresAt) return false;
        
        return uint8(access.level) >= uint8(_requiredLevel);
    }
    
    /**
     * @dev Gets all users with access to a document
     */
    function getDocumentAccessList(bytes32 _documentId) external view returns (
        address[] memory users,
        AccessLevel[] memory levels
    ) {
        require(documents[_documentId].owner != address(0), "Document does not exist");
        require(
            _hasAccess(_documentId, msg.sender, AccessLevel.View) || msg.sender == owner(),
            "Access denied"
        );
        
        address[] memory accessUsers = documentAccessList[_documentId];
        AccessLevel[] memory accessLevels = new AccessLevel[](accessUsers.length);
        
        for (uint256 i = 0; i < accessUsers.length; i++) {
            accessLevels[i] = documentAccess[_documentId][accessUsers[i]].level;
        }
        
        return (accessUsers, accessLevels);
    }
    
    /**
     * @dev Gets all documents owned by a user
     */
    function getUserDocuments(address _user) external view returns (bytes32[] memory) {
        return userDocuments[_user];
    }
    
    /**
     * @dev Gets all documents shared with a user
     */
    function getSharedDocuments(address _user) external view returns (bytes32[] memory) {
        return sharedWithUser[_user];
    }
    
    /**
     * @dev Revokes access to a document
     */
    function revokeAccess(bytes32 _documentId, address _user) external nonReentrant {
        require(documents[_documentId].owner != address(0), "Document does not exist");
        require(_user != documents[_documentId].owner, "Cannot revoke owner access");
        require(
            _hasAccess(_documentId, msg.sender, AccessLevel.Admin),
            "Only admin can revoke access"
        );
        
        delete documentAccess[_documentId][_user];
        
        emit AccessRevoked(_documentId, _user, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Deletes a document (only owner)
     */
    function deleteDocument(bytes32 _documentId) external {
        require(documents[_documentId].owner != address(0), "Document does not exist");
        require(documents[_documentId].owner == msg.sender, "Only owner can delete");
        require(documents[_documentId].status != DocumentStatus.Deleted, "Already deleted");
        
        documents[_documentId].status = DocumentStatus.Deleted;
        totalStorageUsed -= documents[_documentId].size;
        
        emit DocumentDeleted(_documentId, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Archives a document
     */
    function archiveDocument(bytes32 _documentId) external {
        require(documents[_documentId].owner != address(0), "Document does not exist");
        require(
            _hasAccess(_documentId, msg.sender, AccessLevel.Admin),
            "Only admin can archive"
        );
        require(documents[_documentId].status == DocumentStatus.Active, "Document not active");
        
        documents[_documentId].status = DocumentStatus.Archived;
        
        emit DocumentArchived(_documentId, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Gets statistics about the document storage system
     */
    function getSystemStats() external view returns (
        uint256 totalDocuments,
        uint256 activeDocuments,
        uint256 archivedDocuments,
        uint256 deletedDocuments,
        uint256 totalSize
    ) {
        uint256 active = 0;
        uint256 archived = 0;
        uint256 deleted = 0;
        
        for (uint256 i = 0; i < allDocumentIds.length; i++) {
            DocumentStatus status = documents[allDocumentIds[i]].status;
            if (status == DocumentStatus.Active) active++;
            else if (status == DocumentStatus.Archived) archived++;
            else if (status == DocumentStatus.Deleted) deleted++;
        }
        
        return (totalDocumentsCreated, active, archived, deleted, totalStorageUsed);
    }
    
    /**
     * @dev Sets maximum document size (owner only)
     */
    function setMaxDocumentSize(uint256 _maxSize) external onlyOwner {
        require(_maxSize > 0, "Invalid max size");
        maxDocumentSize = _maxSize;
    }
    
    /**
     * @dev Pauses the contract
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpauses the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Gets total number of documents
     */
    function getTotalDocuments() external view returns (uint256) {
        return totalDocumentsCreated;
    }
    
    /**
     * @dev Gets total storage used
     */
    function getTotalStorageUsed() external view returns (uint256) {
        return totalStorageUsed;
    }
}
