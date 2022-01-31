// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RandomNumberGenerator.sol";

contract Gemesis is
    ERC721Enumerable,
    Ownable
{
    using Strings for uint256;
    
    //For VRF
    RandomNumberGenerator randomNumberGenerator;
    address public randomNumberGeneratorAddress;
  
    //For Gemesis
    string private baseURI;
    string private baseExtension = ".json";
    string private notRevealedURI;
    uint16 public maxSupply = 9669;
    uint16 public currentMintSupply = 0;
    uint8 public maxMintAmount = 20;
    uint8 public maxMintAmountWhitelisted = 10;

    uint64 public cost = 0.00001 ether;
    bool public paused = false;
    bool public revealed = false;
    bool public onlyWhitelisted = true;

    uint256[] randomMintOrder = new uint256[](9669);
    address[] public whitelistAddresses;
    mapping(address => uint16) public addressMintedBalance;
    
    /**  TEST WHITELIST ADDRESSLIST
    ["0xd01aeC3a14207BB1a084806c25Aa3FfaD9fA2D34",
    "0xd7aeD87680b74499458fBb406A6c56BF3dF762b7"]
    **/

    constructor(
        string memory _name, 
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri,
        uint16 _currentMintSupply
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);        
        setNotRevealedURI(_initNotRevealedUri);
        setCurrentMintSupply(_currentMintSupply);
        
        //For testing
        //setBaseURI("ipfs://Qmd6dZtxs41qtyFyxaW5rG5MYQFYeESs7rpC5XwhNwqAzy/");
        //setNotRevealedURI("https://gateway.pinata.cloud/ipfs/QmaUw3k5G56ajTCCM73AunrSBcWNYXuzCVbjPtfxeq2gNP");
    }
    
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
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) 
        : "";
    }

    function mint(uint16 _mintAmount) public payable {
        require(!paused, "The contract is paused!");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "You cannot mint less then 1 NFT's");
        require(supply + _mintAmount <= currentMintSupply, "The amount of Gemesis you are trying to mint is not available in this mint cycle.");
        require(supply + _mintAmount <= maxSupply, "The amount of Gemesis you are trying to mint is not available");
        
        if(msg.sender != owner()) {
            if(onlyWhitelisted == true) {
                require(isWhiteListed(msg.sender),"User is not Whitelisted!");
                uint256 ownerTokenCount = balanceOf(msg.sender);
                require(ownerTokenCount < maxMintAmountWhitelisted); 
            } else {   
                require(_mintAmount <= maxMintAmount, "You cannot mint that many NFT's in one mint");
            }
            require(msg.value >= cost * _mintAmount, "Insufficient funds");
        }
        
        for(uint16 i = 0; i < _mintAmount; i++){
            _safeMint(msg.sender, getRandomId(supply));
            addressMintedBalance[msg.sender]++;
            supply = totalSupply();
        }
        
    }

    function isWhiteListed(address _user)public view returns (bool) {
        for(uint16 i = 0; i < whitelistAddresses.length; i++){
            if(whitelistAddresses[i] == _user){
                return true;
            }
        }
        return false;
    }
    
    function initializeRandomNumber (address _randomNumberGeneratorAddress) public onlyOwner {
        randomNumberGenerator = RandomNumberGenerator(_randomNumberGeneratorAddress);
        randomNumberGeneratorAddress = _randomNumberGeneratorAddress;
        randomNumberGenerator.getRandomNumber();
    }

    function getRandomNumber() public view onlyOwner returns (uint256){
        return randomNumberGenerator.getRandomResult();
    }


    function getRandomId(uint256 mintIndex)
        private returns (uint256)
    {
        require(randomNumberGenerator.getRandomResult() != 0, "RandomResult hasnt arrived yet or is 0.");
        uint256 id;
        uint256 randomIndex = uint256(keccak256(abi.encode(randomNumberGenerator.getRandomResult(), mintIndex)));
        randomIndex = randomIndex % (randomMintOrder.length);
        
        if (randomMintOrder[randomIndex] == 0)
        {
            id = randomIndex;
        } else 
        {
            id = randomMintOrder[randomIndex];
        }
        randomMintOrder.pop();
        if (randomIndex > randomMintOrder.length - 1)
        {
            randomIndex = randomMintOrder.length;
        }
        randomMintOrder[randomIndex] = randomMintOrder.length - 1;
        return (id + 1); 
    }
    

    function getBalanceOfAddress(address _address) public view returns (uint16){
        return addressMintedBalance[_address];
    }

    function setReveal(bool _state) public onlyOwner() {
        revealed = _state;
    } 

    function setCost(uint64 _newCost) public onlyOwner() {
        cost = _newCost;
    }

    function setMaxMintAmount(uint8 _newMaxMintAmount) public onlyOwner() {
        maxMintAmount = _newMaxMintAmount;
    } 

    function setMaxMintAmountWhitelisted(uint8 _newMaxMintAmountWhitelisted) public onlyOwner() {
        maxMintAmountWhitelisted = _newMaxMintAmountWhitelisted;
    }

    function setCurrentMintSupply(uint16 _newCurrentMintSupply) public onlyOwner() {
        currentMintSupply = _newCurrentMintSupply;
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

    function setOnlyWhitelisted(bool  _state) public onlyOwner {
        onlyWhitelisted = _state;
    }


    function whitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistAddresses;
        whitelistAddresses = _users;
    }

    function withdraw(uint256 _amount) public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to send eth");
    }
}
