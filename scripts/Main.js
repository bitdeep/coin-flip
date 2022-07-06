const hre = require("hardhat");
async function main() {
  const Main = await hre.ethers.getContractFactory("Main");
  const main = await Main.deploy();
  await main.deployed();
  console.log("main:", main.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
