async function main() {
  
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const MyNFT = await ethers.getContractFactory("MyNFT");//used to deploy new contracts
   //this is deprecated instead use below const myNFT = await MyNFT.deploy();// Instance of the contract, can acces all functions of contract over this object
    const myNFT = await MyNFT.constructor("Gemesis", "-.-").transact({'from': deployer, 'gas': 410000})
    console.log("Token address:", myNFT.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });