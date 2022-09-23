const { network } = require("hardhat");
const { moveBlocks } = require("../utils/move-blocks");

async function mine() {
  if (network.config.chainId == "31337") {
    await moveBlocks(1, (sleepAmount = 1000));
  }
}

mine()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
