"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
require("@nomicfoundation/hardhat-toolbox");
const dotenv = __importStar(require("dotenv"));
dotenv.config();
let env = process.env;
const config = {
    defaultNetwork: "hardhat",
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
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
exports.default = config;
