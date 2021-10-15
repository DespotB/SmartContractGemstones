async function main() {
  //0x6D3bCd6C1E89956BD92bD4b679191abD7798174d
  //0xC2717d0dB33Ca0CE41f25a2E35975cb0231F1F75 -- cap of 3
  
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  const MyNFT = await ethers.getContractFactory("Gemesis"); //used to deploy new contracts
   //this is deprecated instead use below const myNFT = await MyNFT.deploy();// Instance of the contract, can acces all functions of contract over this object
  // const myNFT = await MyNFT.deploy("Gemesis", "Symbol");
    // const myNFT = await MyNFT.constructor("Gemesis", "Symbol").transact({'from': deployer, 'gas': 410000})
    
    const myNFT = await MyNFT.deploy("Gemesis", "GEM")
    console.log("Smart Contract address:", myNFT.address);
    console.log("TRX hash", myNFT.deployTransaction.hash);
    await myNFT.deployed();
 }
 
 //THIS WILL BE NEEDED TO GIVE the instance of RandomNumberGenerator to Gemesiscontract (its contract address)
 
//var RandomNumberGenerator = artifacts.require("./RandomNumberGenerator.sol");
//var Gemesis = artifacts.require("./Gemesis.sol");
//module.exports = function(deployer) {
//    deployer.deploy(RandomNumberGenerator).then(function() {
//        return deployer.deploy(Gemesis, RandomNumberGenerator.address);
//    }).then(function() { })
//};
 
 
main()
  .then(() => process.exit(0))
  .catch(error => {
   console.error(error);
    process.exit(1);
});