require('dotenv').config();
const API_URL = process.env.API_URL;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(API_URL);

const contract = require("../artifacts/contracts/gemstones.sol/MyNFT.json");
console.log(JSON.stringify(contract.abi));

const contractAddress = "0x6D3bCd6C1E89956BD92bD4b679191abD7798174d";
const nftContract = new web3.eth.Contract(contract.abi, contractAddress);

async function mintNFT(tokenURI) {
    const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, 'latest'); //get latest nonce (keeps track of transaction numbers / security purposes - replay attacks)

    //transaction
    const tx = {
        'from': PUBLIC_KEY,
        'to': contractAddress,
        'none': nonce,
        'gas': 500000,
        'maxPriorityFeePerGas': 1999999987,
        'data': nftContract.methods.mint(PUBLIC_KEY, 1, tokenURI).encodeABI()
    };

    const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
    signPromise.then((signedTx) => {
        web3.eth.sendSignedTransaction(signedTx.rawTransaction, function(err, hash) {
        if (!err) {
            console.log("The hash of your transaction is: ", hash, "\nCheck Alchemy's Mempool to view the status of your transaction!"); 
        } else {
            console.log("Something went wrong when submitting your transaction:", err)
         }
        });
    }).catch((err) => {
         console.log("Promise failed:", err);
     });
}

//mint with hashcode of metadata from Pinata 
mintNFT("https://gateway.pinata.cloud/ipfs/QmYueiuRNmL4MiA2GwtVMm6ZagknXnSpQnB3z2gWbz36hP");