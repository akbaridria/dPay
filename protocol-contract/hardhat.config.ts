import { HardhatUserConfig } from "hardhat/config";

import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from "dotenv";
dotenv.config();

import chains from "./datas/chains.json";

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      blockGasLimit: 30000000,
    },
    optimism: {
      url: chains.filter((item: any) => item.chainId === 420)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    ethereum: {
      url: chains.filter((item: any) => item.chainId === 5)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    base: {
      chainId: chains.filter((item: any) => item.chainId === 84531)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 84531)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    moonbeam: {
      chainId: chains.filter((item: any) => item.chainId === 1287)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 1287)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    polygon: {
      chainId: chains.filter((item: any) => item.chainId === 80001)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 80001)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    avalanche: {
      chainId: chains.filter((item: any) => item.chainId === 43113)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 43113)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    binance: {
      chainId: chains.filter((item: any) => item.chainId === 97)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 97)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    fantom: {
      chainId: chains.filter((item: any) => item.chainId === 4002)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 4002)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    aurora: {
      chainId: chains.filter((item: any) => item.chainId === 1313161555)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 1313161555)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    celo: {
      chainId: chains.filter((item: any) => item.chainId === 44787)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 44787)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    arbitrum: {
      chainId: chains.filter((item: any) => item.chainId === 421613)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 421613)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
    linea: {
      chainId: chains.filter((item: any) => item.chainId === 59140)[0].chainId,
      url: chains.filter((item: any) => item.chainId === 59140)[0].rpc,
      accounts: [process.env.PRIV_KEY as string, process.env.PRIV_KEY2 as string],
    },
  },
  etherscan: {
    apiKey: {
      optimisticGoerli: process.env.OPTIMISM_API_KEY as string,
      goerli: process.env.ETHERSCAN_API_KEY as string,
      baseGoerli: process.env.BASESCAN_API_KEY as string,
      moonbaseAlpha: process.env.MOONBEAMSCAN_API_KEY as string,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY as string,
      avalancheFujiTestnet: process.env.SNOWTRACE_API_KEY as string,
      bscTestnet: process.env.BSCSCAN_API_KEY as string,
      ftmTestnet: process.env.FTMSCAN_API_KEY as string,
      linea: process.env.LINEASCAN_API_KEY as string,
      aurora: "abc",
      arbitrumGoerli: process.env.ARBISCAN_API_KEY as string,
      celo: process.env.CELOSCAN_API_KEY as string
    },
    customChains: [
      {
        network: "linea",
        chainId: 59140,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://goerli.lineascan.build/"
        }
      },
      {
        network: "aurora",
        chainId: 1313161555,
        urls: {
          apiURL: "https://explorer.testnet.aurora.dev/api",
          browserURL: "https://explorer.testnet.aurora.dev/"
        }
      },
      {
        network: "celo",
        chainId: 44787,
        urls: {
          apiURL: "https://api.celoscan.io/api",
          browserURL: "https://alfajores.celoscan.io/",
        }
      }
    ]
  },
  solidity: {
    version: "0.8.9",
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
