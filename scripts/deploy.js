const hre = require("hardhat");
const fs = require('fs');

async function main() {
  console.log("\n" + "=".repeat(70));
  console.log(" ".repeat(10) + "Decentralized Document Storage System");
  console.log("=".repeat(70) + "\n");

  // Display deployment information
  console.log("📋 Pre-Deployment Information");
  console.log("-".repeat(70));
  
  const [deployer] = await hre.ethers.getSigners();
  const deployerAddress = deployer.address;
  const balance = await hre.ethers.provider.getBalance(deployerAddress);
  const network = await hre.ethers.provider.getNetwork();
  
  console.log("Network Name:", hre.network.name);
  console.log("Chain ID:", network.chainId.toString());
  console.log("RPC URL:", hre.network.config.url || "localhost");
  console.log("Deployer Address:", deployerAddress);
  console.log("Deployer Balance:", hre.ethers.formatEther(balance), "ETH");
  console.log("Timestamp:", new Date().toISOString());
  console.log();

  // Check balance
  if (balance === 0n) {
    console.error("❌ Error: Deployer account has insufficient funds!");
    console.log("Please fund your account with testnet ETH.");
    console.log("Get testnet tokens from: https://faucet.test2.btcs.network");
    process.exit(1);
  }

  console.log("🚀 Initiating Smart Contract Deployment...\n");
  console.log("-".repeat(70));

  // Deploy the contract
  console.log("📦 Compiling and deploying contract...");
  const startTime = Date.now();
  
  const Project = await hre.ethers.getContractFactory("Project");
  console.log("✓ Contract factory created");
  
  console.log("⏳ Deploying to blockchain...");
  const project = await Project.deploy();
  
  console.log("⏳ Waiting for deployment confirmation...");
  await project.waitForDeployment();
  
  const deployTime = ((Date.now() - startTime) / 1000).toFixed(2);
  const contractAddress = await project.getAddress();
  const deploymentTx = project.deploymentTransaction();

  console.log("✓ Contract deployed successfully!\n");

  // Display deployment results
  console.log("=".repeat(70));
  console.log("✅ DEPLOYMENT SUCCESSFUL");
  console.log("=".repeat(70) + "\n");
  
  console.log("📊 Deployment Details");
  console.log("-".repeat(70));
  console.log("Contract Name:        Decentralized Document Storage");
  console.log("Contract Address:    ", contractAddress);
  console.log("Network:             ", "Core Testnet 2");
  console.log("Chain ID:            ", "1114");
  console.log("Deployer:            ", deployerAddress);
  console.log("Transaction Hash:    ", deploymentTx.hash);
  console.log("Block Number:        ", await hre.ethers.provider.getBlockNumber());
  console.log("Deployment Time:     ", deployTime, "seconds");
  console.log("Gas Price:           ", "auto");
  console.log("Timestamp:           ", new Date().toISOString());
  console.log("-".repeat(70) + "\n");

  // Get contract initial state
  console.log("📈 Initial Contract State");
  console.log("-".repeat(70));
  try {
    const owner = await project.owner();
    const totalDocs = await project.getTotalDocuments();
    const totalStorage = await project.getTotalStorageUsed();
    const maxDocSize = await project.maxDocumentSize();
    
    console.log("Contract Owner:         ", owner);
    console.log("Total Documents:        ", totalDocs.toString());
    console.log("Total Storage Used:     ", totalStorage.toString(), "bytes");
    console.log("Max Document Size:      ", (Number(maxDocSize) / (1024 * 1024)).toFixed(2), "MB");
    console.log("Contract Status:        ", "Active & Ready");
  } catch (error) {
    console.log("⚠ Could not fetch initial state:", error.message);
  }
  console.log();

  // Display features
  console.log("🎯 Contract Features");
  console.log("-".repeat(70));
  console.log("✓ Secure document upload with encryption");
  console.log("✓ Granular access control (None, View, Edit, Admin)");
  console.log("✓ Document sharing with expiration support");
  console.log("✓ Versioning system for document updates");
  console.log("✓ Document archiving and deletion");
  console.log("✓ Access revocation mechanism");
  console.log("✓ Comprehensive statistics and tracking");
  console.log("✓ Emergency pause functionality");
  console.log("✓ IPFS integration ready");
  console.log();

  // Display next steps
  console.log("📝 Next Steps");
  console.log("-".repeat(70));
  console.log("1. Save the contract address for future interactions");
  console.log("2. Upload your first document using uploadDocument()");
  console.log("3. Share documents with others using shareDocument()");
  console.log("4. Track your documents using getUserDocuments()");
  console.log();
  console.log("5. Verify contract (optional):");
  console.log(`   npx hardhat verify --network core_testnet ${contractAddress}`);
  console.log();

  // Display useful commands
  console.log("💻 Useful Commands");
  console.log("-".repeat(70));
  console.log("Interact via Hardhat console:");
  console.log(`  npx hardhat console --network core_testnet`);
  console.log();
  console.log("Run tests:");
  console.log(`  npx hardhat test`);
  console.log();
  console.log("View on block explorer:");
  console.log(`  https://scan.test2.btcs.network/address/${contractAddress}`);
  console.log();

  // Display example usage
  console.log("📚 Example Usage");
  console.log("-".repeat(70));
  console.log("Upload a document:");
  console.log(`  await project.uploadDocument(`);
  console.log(`    "QmHash...",           // IPFS hash`);
  console.log(`    "encryptedKey",        // Encrypted key`);
  console.log(`    1024000,               // Size in bytes`);
  console.log(`    "application/pdf",     // MIME type`);
  console.log(`    '{"title":"My Doc"}'   // Metadata`);
  console.log(`  )`);
  console.log();
  console.log("Share a document:");
  console.log(`  await project.shareDocument(`);
  console.log(`    documentId,            // Document ID`);
  console.log(`    userAddress,           // User to share with`);
  console.log(`    1,                     // AccessLevel.View`);
  console.log(`    0                      // No expiration`);
  console.log(`  )`);
  console.log();

  // Save deployment information
  const deploymentInfo = {
    contractName: "Decentralized Document Storage",
    contractAddress: contractAddress,
    network: "Core Testnet 2",
    networkName: hre.network.name,
    chainId: 1114,
    deployer: deployerAddress,
    transactionHash: deploymentTx.hash,
    blockNumber: await hre.ethers.provider.getBlockNumber(),
    deploymentTime: new Date().toISOString(),
    deploymentDuration: deployTime + " seconds",
    gasUsed: "auto",
    contractFeatures: [
      "Document upload with encryption",
      "Multi-level access control",
      "Document sharing with expiration",
      "Version control system",
      "Document archiving",
      "Access revocation",
      "Statistics tracking",
      "Pausable for emergencies"
    ],
    maxDocumentSize: "100 MB",
    accessLevels: ["None", "View", "Edit", "Admin"],
    documentStatuses: ["Active", "Archived", "Deleted"]
  };

  try {
    fs.writeFileSync(
      'deployment-info.json',
      JSON.stringify(deploymentInfo, null, 2)
    );
    console.log("💾 Deployment Information Saved");
    console.log("-".repeat(70));
    console.log("File: deployment-info.json");
    console.log("Location: ./deployment-info.json");
    console.log();
  } catch (error) {
    console.log("⚠ Could not save deployment info:", error.message);
  }

  // Display security reminders
  console.log("🔒 Security Reminders");
  console.log("-".repeat(70));
  console.log("• Never share your private key");
  console.log("• Always encrypt documents before uploading");
  console.log("• Use IPFS or decentralized storage for document files");
  console.log("• Only store document hashes and encrypted keys on-chain");
  console.log("• Regularly review document access permissions");
  console.log("• Use access expiration for temporary sharing");
  console.log();

  console.log("=".repeat(70));
  console.log("🎉 Decentralized Document Storage is now live and ready!");
  console.log("=".repeat(70) + "\n");

  console.log("🌐 Additional Resources");
  console.log("-".repeat(70));
  console.log("Core Testnet Explorer: https://scan.test2.btcs.network");
  console.log("Core Testnet Faucet:   https://faucet.test2.btcs.network");
  console.log("Hardhat Documentation: https://hardhat.org/docs");
  console.log("IPFS Documentation:    https://docs.ipfs.tech");
  console.log();
  
  console.log("Thank you for using Decentralized Document Storage! 📄✨\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n" + "=".repeat(70));
    console.error("❌ DEPLOYMENT FAILED");
    console.error("=".repeat(70));
    console.error("\nError Details:");
    console.error("-".repeat(70));
    console.error("Message:", error.message);
    
    if (error.error) {
      console.error("Reason:", error.error.message || error.error);
    }
    
    if (error.transaction) {
      console.error("Transaction:", error.transaction);
    }
    
    console.error("-".repeat(70));
    console.error("\n💡 Troubleshooting Tips:");
    console.error("1. Ensure your account has sufficient testnet ETH");
    console.error("2. Check if the RPC URL is accessible");
    console.error("3. Verify your private key is correct in .env");
    console.error("4. Try increasing gas limit if out of gas");
    console.error("5. Check network connectivity");
    console.error("\n" + "=".repeat(70) + "\n");
    
    process.exit(1);
  });
