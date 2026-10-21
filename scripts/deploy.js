const hre = require("hardhat");
async function main() {
  const SupplyHub = await hre.ethers.getContractFactory("AuraSupplyChainHub");
  const tracker = await SupplyHub.deploy();
  await tracker.deployed();
  console.log("-> Provenance Tracker live at:", tracker.address);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
