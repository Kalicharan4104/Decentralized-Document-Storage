
const hre = require("hardhat");
const fs = require('fs');

async function main() {
  console.log("\n" + "=".repeat(60));
  console.log("  ProofMesh - Decentralized Proof Verification Network");
  console.log("=".repeat(60) + "\n");

  console.log("📋 Deployment Configuration");
  console.log("-".repeat(60));
  
  // Get deployer information
  const [deployer] = await hre.ethers.getSigners();
  const deployerAddress = deployer.address;
  const balance = await hre.ethers.provider.getBalance(deployerAddress);
  
  console.log("Network:", hre.network.name);
  console.log("Chain ID:", (await hre.ethers.provider.getNetwork()).chainId.toString());
  console.log("Deployer Address:", deployerAddress);
  console.log("Deployer Balance:", hre.ethers.formatEther(balance), "ETH");
  console.log();

  // Check if balance is sufficient
  if (balance === 0n) {
    console.error("❌ Error: Deployer account has no funds!");
    console.log("Please fund your account with some testnet ETH first.");
    process.exit(1);
  }

  console.log("🚀 Starting Deployment...\n");

  // Deploy the contract
  console.log("📦 Deploying ProofMesh contract...");
  const Project = await hre.ethers.getContractFactory("Project");
  
  const startTime = Date.now();
  const project = await Project.deploy();
  
  console.log("⏳ Waiting for deployment confirmation...");
  await project.waitForDeployment();
  
  const deployTime = ((Date.now() - startTime) / 1000).toFixed(2);
  const contractAddress = await project.getAddress();

  console.log();
  console.log("=".repeat(60));
  console.log("✅ Deployment Successful!");
  console.log("=".repeat(60));
  console.log();
  
  console.log("📊 Deployment Summary");
  console.log("-".repeat(60));
  console.log("Contract Name:", "ProofMesh (Project.sol)");
  console.log("Contract Address:", contractAddress);
  console.log("Network:", "Core Testnet 2");
  console.log("Chain ID:", "1114");
  console.log("Deployer:", deployerAddress);
  console.log("Deployment Time:", deployTime, "seconds");
  console.log("Block Number:", await hre.ethers.provider.getBlockNumber());
  console.log("Timestamp:", new Date().toISOString());
  console.log("Gas Price:", "auto");
  console.log();

  // Get initial contract state
  console.log("📈 Initial Contract State");
  console.log("-".repeat(60));
  const totalProofs = await project.getTotalProofs();
  const owner = await project.owner();
  console.log("Owner:", owner);
  console.log("Total Proofs:", totalProofs.toString());
  console.log("Min Verifications Required:", (await project.minVerificationsRequired()).toString());
  console.log("Contract Status:", "Active");
  console.log();

  console.log("🔧 Contract Features");
  console.log("-".repeat(60));
  console.log("✓ Create decentralized proofs for documents and assets");
  console.log("✓ Multi-verifier proof verification system");
  console.log("✓ Link proofs together to create verification mesh");
  console.log("✓ Authorized verifier management");
  console.log("✓ Proof expiry and revocation mechanisms");
  console.log("✓ Reputation scoring for verifiers");
  console.log("✓ Emergency pause functionality");
  console.log("✓ Comprehensive proof tracking and statistics");
  console.log();

  console.log("📝 Next Steps");
  console.log("-".repeat(60));
  console.log("1. Save the contract address:", contractAddress);
  console.log("2. Authorize verifiers using authorizeVerifier()");
  console.log("3. Create your first proof using createProof()");
  console.log("4. Verify the contract (optional):");
  console.log(`   npx hardhat verify --network core_testnet ${contractAddress}`);
  console.log();

  console.log("📚 Useful Commands");
  console.log("-".repeat(60));
  console.log("Interact with contract:");
  console.log(`  npx hardhat console --network core_testnet`);
  console.log();
  console.log("Run tests:");
  console.log(`  npx hardhat test`);
  console.log();
  console.log("View contract on explorer:");
  console.log(`  https://scan.test2.btcs.network/address/${contractAddress}`);
  console.log();

  // Save deployment information
  const deploymentInfo = {
    contractName: "ProofMesh",
    contractAddress: contractAddress,
    network: "Core Testnet 2",
    chainId: 1114,
    deployer: deployerAddress,
    deploymentTime: new Date().toISOString(),
    blockNumber: await hre.ethers.provider.getBlockNumber(),
    deploymentDuration: deployTime + " seconds",
    features: [
      "Decentralized proof creation",
      "Multi-verifier verification",
      "Proof linking (mesh creation)",
      "Authorized verifier management",
      "Proof expiry system",
      "Reputation scoring",
      "Emergency controls"
    ]
  };

  fs.writeFileSync(
    'deployment-info.json',
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log("💾 Deployment info saved to deployment-info.json");
  console.log();
  console.log("=".repeat(60));
  console.log("🎉 ProofMesh is ready to secure your verifications!");
  console.log("=".repeat(60) + "\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment Failed!");
    console.error("=".repeat(60));
    console.error("Error:", error.message);
    if (error.error) {
      console.error("Details:", error.error);
    }
    console.error("=".repeat(60) + "\n");
    process.exit(1);
  });