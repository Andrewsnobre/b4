// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  //const Lock = await hre.ethers.getContractFactory("B3");
  // const lock = await Lock.deploy();

  //await lock.deployed();
  //console.log(`Contract deployed to address: ${lock.address}`);

  const B3Sec = await hre.ethers.getContractFactory("B3sec");
  const B3sec = await B3Sec.deploy();

  await B3sec.deployed();
  console.log(`Contract deployed to address: ${B3sec.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
