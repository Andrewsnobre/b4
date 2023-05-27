require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-solhint");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.17",
  networks: {
    polygon: {
      url: process.env.POLYGON_URL,
      accounts: [process.env.OWNER_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    currency: "USD",
    gasPrice: 21,
    enabled: true,
    coinmarketcap: process.env.COIN_MARKETCAP_API_KEY || "",
    token: "MATIC",
  },
  gasReporter: {
    enabled: true,
    coinmarketcap: process.env.COIN_MARKETCAP_API_KEY || "",
    token: "MATIC",
  },
};
