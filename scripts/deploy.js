// scripts/deploy-all.js
const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

const ethers = hre.ethers;

async function main() {
  try {
    const [deployer] = await ethers.getSigners();

    const Auth = await ethers.getContractFactory("Auth");
    const auth = await Auth.deploy();
    await auth.waitForDeployment();
    const authAddress = await auth.getAddress();

    const Admin = await ethers.getContractFactory("Admin");
    const admin = await Admin.deploy();
    await admin.waitForDeployment();
    const adminAddress = await admin.getAddress();

    let tx = await auth.setAdminContract(adminAddress);
    await tx.wait();

    tx = await admin.setAuthContract(authAddress);
    await tx.wait();

    const Party = await ethers.getContractFactory("Party");
    const party = await Party.deploy("Demo Party", "DP", deployer.address);
    await party.waitForDeployment();
    const partyAddress = await party.getAddress();

    const Election = await ethers.getContractFactory("ElectionContract");
    const election = await Election.deploy();
    await election.waitForDeployment();
    const electionAddress = await election.getAddress();

    const addresses = {
      Auth: authAddress,
      Admin: adminAddress,
      Party: partyAddress,
      Election: electionAddress,
    };

    // This is too write the deployed contracts in the frontend
    const outputDir = path.join(__dirname, "../../src/contracts");
    const outputPath = path.join(outputDir, "deployedAddresses.json");
    fs.mkdirSync(outputDir, { recursive: true });

    fs.writeFileSync(outputPath, JSON.stringify(addresses, null, 2));
  } catch (error) {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
