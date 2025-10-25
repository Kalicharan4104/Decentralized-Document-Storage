// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title ProofMesh
 * @dev A decentralized proof-of-authenticity and verification network
 * Creates a mesh of interconnected proofs for documents, assets, and claims
 */
contract Project is Ownable, ReentrancyGuard, Pausable {
    
    // Enum for proof status
    enum ProofStatus {
        Pending,
        Verified,
        Rejected,
        Revoked
    }
    
    // Enum for proof type
    enum ProofType {
        Document,
        Asset,
        Identity,
        Claim,
        Certificate
    }
    
    // Struct to represent a proof in the mesh
    struct Proof {
        bytes32 proofHash;
        address creator;
        ProofType proofType;
        ProofStatus status;
        uint256 createdAt;
        uint256 verifiedAt;
        uint256 expiryTime;
        string metadataURI;
        address[] verifiers;
        bytes32[] linkedProofs;
        bool isActive;
    }
    
    // Struct for verifier information
    struct Verifier {
        bool isAuthorized;
        uint256 verificationCount;
        uint256 reputationScore;
        uint256 registeredAt;
    }
    
    // Struct for proof statistics
    struct ProofStats {
        uint256 totalProofs;
        uint256 verifiedProofs;
        uint256 pendingProofs;
        uint256 revokedProofs;
    }
    
    // State variables
    mapping(bytes32 => Proof) public proofs;
    mapping(address => Verifier) public verifiers;
    mapping(address => bytes32[]) public userProofs;
    mapping(bytes32 => mapping(address => bool)) public hasVerified;
    
    bytes32[] public allProofHashes;
    address[] public authorizedVerifiers;
    
    uint256 public totalProofsCreated;
    uint256 public minVerificationsRequired;
    uint256 public verifierReputationThreshold;
    
    // Events
    event ProofCreated(
        bytes32 indexed proofHash,
        address indexed creator,
        ProofType proofType,
        string metadataURI
    );
    
    event ProofVerified(
        bytes32 indexed proofHash,
        address indexed verifier,
        uint256 timestamp
    );
    
    event ProofRevoked(
        bytes32 indexed proofHash,
        address indexed revoker,
        uint256 timestamp
    );
    
    event VerifierAuthorized(
        address indexed verifier,
        uint256 timestamp
    );
    
    event VerifierRemoved(
        address indexed verifier,
        uint256 timestamp
    );
    
    event ProofsLinked(
        bytes32 indexed proof1,
        bytes32 indexed proof2,
        uint256 timestamp
    );
    
    constructor() Ownable(msg.sender) {
        totalProofsCreated = 0;
        minVerificationsRequired = 2;
        verifierReputationThreshold = 50;
    }
    
    /**
     * @dev Creates a new proof in the mesh
     * @param _dataHash Hash of the data being proven
     * @param _proofType Type of proof being created
     * @param _metadataURI URI pointing to additional metadata
     * @param _expiryTime Expiry timestamp (0 for no expiry)
     * @return proofHash The unique hash identifier of the proof
     */
    function createProof(
        bytes32 _dataHash,
        ProofType _proofType,
        string memory _metadataURI,
        uint256 _expiryTime
    ) external whenNotPaused returns (bytes32) {
        require(_dataHash != bytes32(0), "Invalid data hash");
        require(bytes(_metadataURI).length > 0, "Metadata URI required");
        require(_expiryTime == 0 || _expiryTime > block.timestamp, "Invalid expiry time");
        
        // Generate unique proof hash
        bytes32 proofHash = keccak256(
            abi.encodePacked(
                _dataHash,
                msg.sender,
                block.timestamp,
                totalProofsCreated
            )
        );
        
        require(proofs[proofHash].creator == address(0), "Proof already exists");
        
        // Create new proof
        Proof storage newProof = proofs[proofHash];
        newProof.proofHash = proofHash;
        newProof.creator = msg.sender;
        newProof.proofType = _proofType;
        newProof.status = ProofStatus.Pending;
        newProof.createdAt = block.timestamp;
        newProof.expiryTime = _expiryTime;
        newProof.metadataURI = _metadataURI;
        newProof.isActive = true;
        
        // Track proof
        allProofHashes.push(proofHash);
        userProofs[msg.sender].push(proofHash);
        totalProofsCreated++;
        
        emit ProofCreated(proofHash, msg.sender, _proofType, _metadataURI);
        
        return proofHash;
    }
    
    /**
     * @dev Verifies a proof in the mesh
     * @param _proofHash Hash of the proof to verify
     */
    function verifyProof(bytes32 _proofHash) external nonReentrant whenNotPaused {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        require(verifiers[msg.sender].isAuthorized, "Not an authorized verifier");
        require(!hasVerified[_proofHash][msg.sender], "Already verified by you");
        require(proofs[_proofHash].isActive, "Proof is not active");
        require(proofs[_proofHash].status == ProofStatus.Pending, "Proof already processed");
        
        Proof storage proof = proofs[_proofHash];
        
        // Check if proof has expired
        if (proof.expiryTime > 0 && block.timestamp > proof.expiryTime) {
            proof.status = ProofStatus.Rejected;
            revert("Proof has expired");
        }
        
        // Add verifier
        proof.verifiers.push(msg.sender);
        hasVerified[_proofHash][msg.sender] = true;
        
        // Update verifier stats
        verifiers[msg.sender].verificationCount++;
        verifiers[msg.sender].reputationScore += 10;
        
        // Check if minimum verifications met
        if (proof.verifiers.length >= minVerificationsRequired) {
            proof.status = ProofStatus.Verified;
            proof.verifiedAt = block.timestamp;
        }
        
        emit ProofVerified(_proofHash, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Links two proofs together in the mesh
     * @param _proofHash1 First proof hash
     * @param _proofHash2 Second proof hash
     */
    function linkProofs(
        bytes32 _proofHash1,
        bytes32 _proofHash2
    ) external whenNotPaused {
        require(proofs[_proofHash1].creator != address(0), "Proof 1 does not exist");
        require(proofs[_proofHash2].creator != address(0), "Proof 2 does not exist");
        require(
            proofs[_proofHash1].creator == msg.sender || 
            proofs[_proofHash2].creator == msg.sender,
            "Must be creator of at least one proof"
        );
        require(_proofHash1 != _proofHash2, "Cannot link proof to itself");
        
        // Add bidirectional links
        proofs[_proofHash1].linkedProofs.push(_proofHash2);
        proofs[_proofHash2].linkedProofs.push(_proofHash1);
        
        emit ProofsLinked(_proofHash1, _proofHash2, block.timestamp);
    }
    
    /*
     * @dev Retrieves comprehensive proof information
     * @param _proofHash Hash of the proof
     * @return Proof details including creator, status, type, and timestamps
     */
    function getProofInfo(bytes32 _proofHash) external view returns (
        address creator,
        ProofType proofType,
        ProofStatus status,
        uint256 createdAt,
        uint256 verifiedAt,
        uint256 expiryTime,
        string memory metadataURI,
        uint256 verifierCount,
        uint256 linkedProofCount,
        bool isActive
    ) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        Proof memory proof = proofs[_proofHash];
        
        return (
            proof.creator,
            proof.proofType,
            proof.status,
            proof.createdAt,
            proof.verifiedAt,
            proof.expiryTime,
            proof.metadataURI,
            proof.verifiers.length,
            proof.linkedProofs.length,
            proof.isActive
        );
    }
    
    /**
     * @dev Gets all verifiers for a specific proof
     */
    function getProofVerifiers(bytes32 _proofHash) external view returns (address[] memory) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        return proofs[_proofHash].verifiers;
    }
    
    /**
     * @dev Gets all linked proofs for a specific proof
     */
    function getLinkedProofs(bytes32 _proofHash) external view returns (bytes32[] memory) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        return proofs[_proofHash].linkedProofs;
    }
    
    /**
     * @dev Gets all proofs created by a user
     */
    function getUserProofs(address _user) external view returns (bytes32[] memory) {
        return userProofs[_user];
    }
    
    /**
     * @dev Checks if a proof is verified
     */
    function isProofVerified(bytes32 _proofHash) external view returns (bool) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        return proofs[_proofHash].status == ProofStatus.Verified;
    }
    
    /**
     * @dev Checks if a proof is still valid (not expired)
     */
    function isProofValid(bytes32 _proofHash) external view returns (bool) {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        Proof memory proof = proofs[_proofHash];
        
        if (!proof.isActive) return false;
        if (proof.status != ProofStatus.Verified) return false;
        if (proof.expiryTime > 0 && block.timestamp > proof.expiryTime) return false;
        
        return true;
    }
    
    /**
     * @dev Revokes a proof (only creator or owner)
     */
    function revokeProof(bytes32 _proofHash) external {
        require(proofs[_proofHash].creator != address(0), "Proof does not exist");
        require(
            proofs[_proofHash].creator == msg.sender || msg.sender == owner(),
            "Not authorized to revoke"
        );
        require(proofs[_proofHash].isActive, "Proof already inactive");
        
        proofs[_proofHash].status = ProofStatus.Revoked;
        proofs[_proofHash].isActive = false;
        
        emit ProofRevoked(_proofHash, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Authorizes a new verifier
     */
    function authorizeVerifier(address _verifier) external onlyOwner {
        require(_verifier != address(0), "Invalid verifier address");
        require(!verifiers[_verifier].isAuthorized, "Already authorized");
        
        verifiers[_verifier] = Verifier({
            isAuthorized: true,
            verificationCount: 0,
            reputationScore: 100,
            registeredAt: block.timestamp
        });
        
        authorizedVerifiers.push(_verifier);
        
        emit VerifierAuthorized(_verifier, block.timestamp);
    }
    
    /**
     * @dev Removes a verifier's authorization
     */
    function removeVerifier(address _verifier) external onlyOwner {
        require(verifiers[_verifier].isAuthorized, "Not an authorized verifier");
        
        verifiers[_verifier].isAuthorized = false;
        
        emit VerifierRemoved(_verifier, block.timestamp);
    }
    
    /**
     * @dev Gets verifier information
     */
    function getVerifierInfo(address _verifier) external view returns (
        bool isAuthorized,
        uint256 verificationCount,
        uint256 reputationScore,
        uint256 registeredAt
    ) {
        Verifier memory verifier = verifiers[_verifier];
        return (
            verifier.isAuthorized,
            verifier.verificationCount,
            verifier.reputationScore,
            verifier.registeredAt
        );
    }
    
    /**
     * @dev Gets all authorized verifiers
     */
    function getAllVerifiers() external view returns (address[] memory) {
        return authorizedVerifiers;
    }
    
    /**
     * @dev Gets statistics about proofs in the system
     */
    function getProofStats() external view returns (
        uint256 totalProofs,
        uint256 verifiedProofs,
        uint256 pendingProofs,
        uint256 revokedProofs
    ) {
        uint256 verified = 0;
        uint256 pending = 0;
        uint256 revoked = 0;
        
        for (uint256 i = 0; i < allProofHashes.length; i++) {
            ProofStatus status = proofs[allProofHashes[i]].status;
            if (status == ProofStatus.Verified) verified++;
            else if (status == ProofStatus.Pending) pending++;
            else if (status == ProofStatus.Revoked) revoked++;
        }
        
        return (totalProofsCreated, verified, pending, revoked);
    }
    
    /**
     * @dev Updates minimum verifications required
     */
    function setMinVerifications(uint256 _minVerifications) external onlyOwner {
        require(_minVerifications > 0, "Must require at least 1 verification");
        minVerificationsRequired = _minVerifications;
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
     * @dev Gets total number of proofs
     */
    function getTotalProofs() external view returns (uint256) {
        return totalProofsCreated;
    }
    
    /**
     * @dev Gets all proof hashes (paginated for gas efficiency)
     */
    function getAllProofHashes(uint256 _startIndex, uint256 _count) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        require(_startIndex < allProofHashes.length, "Start index out of bounds");
        
        uint256 endIndex = _startIndex + _count;
        if (endIndex > allProofHashes.length) {
            endIndex = allProofHashes.length;
        }
        
        bytes32[] memory result = new bytes32[](endIndex - _startIndex);
        for (uint256 i = _startIndex; i < endIndex; i++) {
            result[i - _startIndex] = allProofHashes[i];
        }
        
        return result;
    }
}