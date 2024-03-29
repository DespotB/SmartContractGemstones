/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 require('dotenv').config();
 require("@nomiclabs/hardhat-ethers");
 const { API_URL, PRIVATE_KEY } = process.env;
 module.exports = {
    solidity: "0.8.0",
    defaultNetwork: "ropsten",
    networks: {
       hardhat: {},
       ropsten: {
          url: API_URL,
          accounts: [`0x${PRIVATE_KEY}`],
          chainId: 3,
       }
    },
   // networks: {
   //    forking: {
   //       url: "https://eth-ropsten.alchemyapi.io/v2/h5x3NCmpC9vOdUgVaKNtGvkMWsr4afhq"
   //    }
   // }
 }
