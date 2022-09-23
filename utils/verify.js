const { run } = require("hardhat");

/********* Programmatic Verification *********/
const verify = async (contractAddress, args) => {
  console.log("Verifying contract address...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (error) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log("Already verified");
    } else {
      console.log(error);
    }
  }
};

module.exports = { verify };

// Deploy Addresses on  GOERLI Chain:

// BasicNft : Successfully verified contract BasicNft on Etherscan.
// https://goerli.etherscan.io/address/0x57D660E5510Df0de450d7A1f71cF3F694Fa1eD23#code

// BasicNft : Successfully verified contract BasicNft on Etherscan.
// https://goerli.etherscan.io/address/0x8421C580FC6abE4018F19Bcc2F79F0dD93d3eC13#code
