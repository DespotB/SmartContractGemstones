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
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    Counters.Counter private _tokenIds;

    string public baseURI;
    string public baseExtension = ".json"; //OR .png?
    string public notRevealedURI;
    string private baseURIextended;
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
        setBaseURI("https://gateway.pinata.cloud/ipfs/");
        setNotRevealedURI("https://gateway.pinata.cloud/ipfs/QmTGT8dpjYcKHaZrMoB9MuMrr6qYmzbK1uytDVzm66UC2E");
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
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) //IS THIS OUR URI?
        : "";
        
        /*string memory _tokenURI = tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
        */
    }

    function mint(uint256 _mintAmount) public payable {
        require(!paused, "The contract is paused");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "You cannot mint less then 1 NFT's");
        require(_mintAmount <= maxMintAmount, "You cannot mint that many NFT's in one mint");
        require(supply + _mintAmount < maxSupply, "All NFT's have been minted");
        
        if(msg.sender != owner()) {
            uint256 ownerMintedCount = addressMintedBalance[msg.sender];
            require(ownerMintedCount + _mintAmount <= nftPerAddressLimit,  "max amount of NFTs per address exceeded");
            require(msg.value >= cost * _mintAmount, "insufficient funds");
            
        }
        for(uint256 i = 0; i < _mintAmount; i++){
            _safeMint(msg.sender, supply + 1);
            addressMintedBalance[msg.sender]++;
        }
        
        
        //Update timestamp and safe last updated for this address
        //mintCooldown[msg.sender] = block.timestamp;
        //require(oneHourHasPassed(mintCooldown[msg.sender]), "Your Mintcooldown has not reseted yet, it will be reset at ....")
    }
    
    function getBalanceOfAddress(address _address) public view returns (uint256){
        return addressMintedBalance[_address];
    }

    function oneHourHasPassed(
        uint256 addressLastMintTimestamp
    ) public view returns (bool) {
        return (block.timestamp >= (addressLastMintTimestamp + 2 minutes));
    }

    //only owner
    function energyStonesSpecialMint() external onlyOwner{              //CHECK THIS
        _tokenIds.increment();                  
        _safeMint(msg.sender, _tokenIds.current());
    }

    function reveal() public onlyOwner() {
        revealed = true;
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

    function withdraw(uint _amount) public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to send eth");
    }
}
