const { ethers, network } = require("hardhat");
const fs = require("fs");

const frontEndContractsFile =
  "../11. NextJS NFT MarketPlace - Moralis/constants/networkMapping.json";
const frontEndAbiLocation =
  "../11. NextJS NFT MarketPlace - Moralis/constants/";

module.exports = async function () {
  if (process.env.UPDATE_FRONT_END) {
    console.log("updating front end...");
    await updateContractAddress();
    await updateAbi();
  }
};

async function updateAbi() {
  const nftMarketPlace = await ethers.getContract("NftMarketPlace");
  const basicNft = await ethers.getContract("BasicNft");
  fs.writeFileSync(
    frontEndAbiLocation + "NftMarketPlaceAbi.json",
    nftMarketPlace.interface.format(ethers.utils.FormatTypes.json)
  );
  fs.writeFileSync(
    frontEndAbiLocation + "BasicNftAbi.json",
    basicNft.interface.format(ethers.utils.FormatTypes.json)
  );
}

async function updateContractAddress() {
  const nftMarketPlace = await ethers.getContract("NftMarketPlace");
  const chainId = network.config.chainId.toString();
  const contractAddresses = JSON.parse(
    fs.readFileSync(frontEndContractsFile, "utf8")
  );
  if (chainId in contractAddresses) {
    if (
      !contractAddresses[chainId]["NftMarketPlace"].includes(
        nftMarketPlace.address
      )
    ) {
      contractAddresses[chainId]["NftMarketPlace"].push(nftMarketPlace.address);
    }
  } else {
    contractAddresses[chainId] = { NftMarketPlace: [nftMarketPlace.address] };
  }
  fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses));
}

module.exports.tags = ["all", "frontend"];
