//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RandomNumberGenerator.sol";


//ALOT OF INFOS: https://www.quicknode.com/guides/solidity/how-to-create-and-deploy-an-erc-721-nft
contract Gemesis is
    // ERC721,  
    ERC721Enumerable,
    Ownable //remove ownable to make it mintable for others
{
    using Strings for uint256;
    
    //For VRF
    RandomNumberGenerator randomNumberGenerator;
    address public randomNumberGeneratorAddress;
    mapping(uint256 => uint256) public randomMintOrder;     //CHANGE THIS BACK FROM PUBLIC
    mapping(uint256 => bool) internal randomNumberExists;

    //For Gemesis
    string public baseURI;
    string public baseExtension = ".json"; //OR .png?
    string public notRevealedURI;
    uint256 public maxSupply = 20;
    uint256 public maxMintAmount = 20;
    uint256 public cost = 0.0001 ether;
    uint256 public nftPerAddressLimit = 10;  //INCREASE THIS OVER TIME?
    bool public paused = false;
    bool public revealed = false;
    bool public onlyWhitelisted = true;

    mapping(address => bool) public whitelisted;
    mapping(address => uint256) private mintCooldown;
    mapping(uint256 => string) private tokenURIs; //We will need something similiar becuase we need to read the imgs randmoly not by order
    mapping(address => uint256) public addressMintedBalance;

    
    address payable public payments; //CHECK

    constructor(
        string memory _name, 
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        //setBaseURI(_initBaseURI);               //only "ipfs://"?
        //setNotRevealedURI(_initNotRevealedUri);

        //For testing
        setBaseURI("https://gateway.pinata.cloud/ipfs/QmNwbePLwNHfkTfj28yibDcpgw21gtAtjXLgr1FUf6fJ4q/");
        setNotRevealedURI("https://gateway.pinata.cloud/ipfs/QmaUw3k5G56ajTCCM73AunrSBcWNYXuzCVbjPtfxeq2gNP");
    }
    
    //VRF functions
    // call this function after transaction LINK on random contract
     function initializeRandomNumberGenerator (address _randomNumberGeneratorAddress)public onlyOwner {
        randomNumberGenerator = RandomNumberGenerator(_randomNumberGeneratorAddress);
        randomNumberGeneratorAddress = _randomNumberGeneratorAddress;
        randomNumberGenerator.getRandomNumber();
    }
    
    //call this function after random result was callbacked
    function getRandomNumber() public view onlyOwner returns (uint256){
        return randomNumberGenerator.getRandomResult();
    }
    
    function initializeRandomOrder() public onlyOwner {
        createRandomOrder(randomNumberGenerator.getRandomResult(), maxSupply);
    }

    //TEST ME
    function createRandomOrder(uint256 _randomNumber, uint256 _maxNumber)
        internal
    {
        require(_randomNumber != 0, "RandomResult hasnt arrived yet or is 0.");
        uint256 localMaxNumber = _maxNumber;
        uint256 counterNumber = 0;
        
        for (uint256 i = 0; i < localMaxNumber; i++) {
            uint256 value = uint256(keccak256(abi.encode(_randomNumber, i)));
            value = value % _maxNumber + 1;
            if(!randomNumberExists[value])
            {
                randomNumberExists[value] = true;
                randomMintOrder[i - counterNumber] = value;
            } else {
                counterNumber++;
                localMaxNumber++;
            }
        }
    }
    
      // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if(revealed == false) {
            return notRevealedURI;
        }
        
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
        //? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) 
        ? string(abi.encodePacked(currentBaseURI, randomMintOrder[tokenId].toString(), baseExtension)) //TEST THIS ONLY WITH tokenId.string
        : "";
    }

    function mint(uint256 _mintAmount) public payable {
        require(!paused, "The contract is paused");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "You cannot mint less then 1 NFT's");
        require(supply + _mintAmount < maxSupply + 1, "All NFT's have been minted");
        
        if(msg.sender != owner()) {
            uint256 ownerMintedCount = addressMintedBalance[msg.sender];
            require(ownerMintedCount + _mintAmount <= nftPerAddressLimit,  "max amount of NFTs per address exceeded");
            require(_mintAmount <= maxMintAmount, "You cannot mint that many NFT's in one mint");
            require(msg.value >= cost * _mintAmount, "insufficient funds");
            
        }
        for(uint256 i = 0; i < _mintAmount; i++){
            _safeMint(msg.sender, supply + 1);      //put here randomMintOrder[supply+1];
            addressMintedBalance[msg.sender]++;
            supply = totalSupply();
        }
        
        
        //Update timestamp and safe last updated for this address
        //mintCooldown[msg.sender] = block.timestamp;
        //require(oneHourHasPassed(mintCooldown[msg.sender]), "Your Mintcooldown has not reseted yet, it will be reset at ....")
    }
    
    function getBalanceOfAddress(address _address) public view returns (uint256){
        return addressMintedBalance[_address];
    }

    //function oneHourHasPassed(
    //    uint256 addressLastMintTimestamp
    //) public view returns (bool) {
    //    return (block.timestamp >= (addressLastMintTimestamp + 2 minutes));
    //}

    //only owner
    //function energyStonesSpecialMint() external onlyOwner{              //CHECK THIS
    //    uint256 supply = totalSupply();                  
    //    _safeMint(msg.sender, supply + 1);
    //}

    function setReveal(bool _state) public onlyOwner() {
        revealed = _state;
    } 
  
    function setNftPerAddressLimit(uint256 _limit) public onlyOwner() {
        nftPerAddressLimit = _limit;
    }

    function setCost(uint256 _newCost) public onlyOwner() {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedURI = _notRevealedURI;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhitelisted = _state;
    }

    function whitelistUser(address _user) public onlyOwner { //CHECK
        whitelisted[_user] = true;
    }
 
    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }
    
    function invest() external payable {
    
    }

    function withdraw(uint _amount) public payable onlyOwner { //TEST ME
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to send eth");
    }
}
