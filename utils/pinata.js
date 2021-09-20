// https://medium.com/pinata/how-to-pin-to-ipfs-effortlessly-ba3437b33885
require('dotenv').config();
const key = process.env.REACT_APP_PINATA_KEY;
const secret = process.env.REACT_APP_PINATA_SECRET;

const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

export const pinJSONToIPFS = async(JSONBody) => {
    const url = `https://api.pinata.cloud/pinning/pinJSONToIPFS`;
    //making axios POST request to Pinata ⬇️
    return axios 
        .post(url, JSONBody, {
            headers: {
                pinata_api_key: key,
                pinata_secret_api_key: secret,
            }
        })
        .then(function (response) {
           return {
               success: true,
               pinataUrl: "https://gateway.pinata.cloud/ipfs/" + response.data.IpfsHash
           };
        })
        .catch(function (error) {
            console.log(error)
            return {
                success: false,
                message: error.message,
            }
           
    });
};

export const pinFileToIPFS = (pinataApiKey, pinataSecretApiKey) => {
    const url = `https://api.pinata.cloud/pinning/pinJSONToIPFS`;//we gather a local file from the API for this example, but you can gather the file from anywhere
    let data = new FormData();
    data.append('file', fs.createReadStream('./yourfile.png'));return axios.post(url,
        data,
        {
            headers: {
                'Content-Type': `multipart/form-data; boundary= ${data._boundary}`,
                'pinata_api_key': pinataApiKey,
                'pinata_secret_api_key': pinataSecretApiKey
            }
        }
    ).then(function (response) {
        //handle response here
    }).catch(function (error) {
        //handle error here
    });
};