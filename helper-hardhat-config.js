const { ethers } = require("hardhat");

const networkConfig = {
  4: {
    name: "rinkeby",
    vrfCoordinatorV2: "0x6168499c0cffcacd319c818142124b7a15e857ab", // rinkeby vrf contract address
    entranceFee: ethers.utils.parseEther("0.1"),
    gasLane:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // rinkeby key hash
    subscriptionId: "18367",
    callbackGasLimit: "500000",
    interval: "30",
    mintFee: ethers.utils.parseEther("0.01"),
    ethUsdPriceFeed: "",
  },
  31337: {
    name: "hardhat",
    entranceFee: ethers.utils.parseEther("0.1"),
    gasLane:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // Here, anything else works for local developmentChains
    callbackGasLimit: "500000",
    interval: "30",
    mintFee: ethers.utils.parseEther("0.01"),
  },
  5: {
    name: "goerli",
    entranceFee: ethers.utils.parseEther("0.1"),
    vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
    gasLane:
      "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    callbackGasLimit: "500000", // 500,000 gas
    mintFee: ethers.utils.parseEther("0.01"),
    subscriptionId: "1696",
    ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
  },
};

const developmentChains = ["hardhat", "localhost"];

module.exports = {
  networkConfig,
  developmentChains,
};
