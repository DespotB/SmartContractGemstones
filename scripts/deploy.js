async function main() {
  // 0x3C7ccA0E449448DDf2c1d67bc2AAFFae197Ee594
  // 0x605aF9057903C91eCfFF3E7014eAaf2b1edeC0BC
  
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const MyNFT = await ethers.getContractFactory("MyNFT");//used to deploy new contracts
   //this is deprecated instead use below const myNFT = await MyNFT.deploy();// Instance of the contract, can acces all functions of contract over this object
   const myNFT = await MyNFT.deploy("Gemesis", "Symbol");
    // const myNFT = await MyNFT.constructor("Gemesis", "Symbol").transact({'from': deployer, 'gas': 410000})
    await myNFT.deployed();
    console.log("Token address:", myNFT.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });