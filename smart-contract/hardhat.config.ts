import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();
let env = process.env as any;

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
    customChains: [
      {
        network: "qitmeer",
        chainId: 223,
        urls: {
          apiURL: "https://testnet.qng.meerscan.io/api",
          browserURL: "https://testnet.qng.meerscan.io",
        },
      },
      {
        network: "elastos",
        chainId: 21,
        urls: {
          apiURL: "https://esc-testnet.elastos.io/api",
          browserURL: "https://esc-testnet.elastos.io/",
        },
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      gasPrice: 20000000000,
      accounts: [env.PRIVATEKEY],
    },
    hardhat: {},
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [env.PRIVATEKEY],
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [env.PRIVATEKEY],
    },
    goerli: {
      // url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      // url: "https://eth-goerli.g.alchemy.com/v2/demo",
      url: "https://eth-goerli.public.blastapi.io",
      // url:"https://rpc.ankr.com/eth_goerli",
      // url:"https://rpc.goerli.mudit.blog",
      chainId: 5,
      gasPrice: 20000000000,
      accounts: [env.PRIVATEKEY],
    },
    qitmeer: {
      url: "https://meer.testnet.meerfans.club",
      chainId: 223,
      gasPrice: 20000000000,
      accounts: [env.PRIVATEKEY],
    },
    elastos: {
      url: "https://api-testnet.elastos.io/eth",
      chainId: 21,
      gasPrice: 20000000000,
      accounts: [env.PRIVATEKEY],
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          // viaIR: true,
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 20000,
  },
};

export default config;
