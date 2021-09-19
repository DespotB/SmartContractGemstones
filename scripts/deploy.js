async function main() {
  //0x6D3bCd6C1E89956BD92bD4b679191abD7798174d
  
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  const MyNFT = await ethers.getContractFactory("MyNFT");//used to deploy new contracts
   //this is deprecated instead use below const myNFT = await MyNFT.deploy();// Instance of the contract, can acces all functions of contract over this object
  // const myNFT = await MyNFT.deploy("Gemesis", "Symbol");
    // const myNFT = await MyNFT.constructor("Gemesis", "Symbol").transact({'from': deployer, 'gas': 410000})
    const myNFT = await MyNFT.deploy("Gemesis", "NFT",{gasLimit: 410000})
    console.log("Token address:", myNFT.address);
    console.log(myNFT.deployTransaction.hash);
  await myNFT.deployed();
 }
 
main()
  .then(() => process.exit(0))
  .catch(error => {
   console.error(error);
    process.exit(1);
});