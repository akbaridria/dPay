import { HardhatUserConfig } from "hardhat/config";

import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from "dotenv";
dotenv.config();

import chains from "./src/data/list-chains.json";

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      blockGasLimit: 30000000,
    },
    optimism: {
      url: chains.filter((item) => item.chainName === "Optimism Goerli")[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    ethereum: {
      url: chains.filter((item) => item.chainName === "Goerli")[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    base: {
      chainId: chains.filter((item) => item.chainName === "Base Goerli")[0].chainId,
      url: chains.filter((item) => item.chainName === "Base Goerli")[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
  },
  etherscan: {
    apiKey: {
      optimisticGoerli: process.env.OPTIMISM_API_KEY as string,
      goerli: process.env.ETHERSCAN_API_KEY as string,
      baseGoerli: process.env.BASESCAN_API_KEY as string
    }
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 9999,
      },
      metadata: {
        bytecodeHash: "none",
      },
    },
  },
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },
  paths: {
    tests: "./src/test",
  },
};

export default config;
