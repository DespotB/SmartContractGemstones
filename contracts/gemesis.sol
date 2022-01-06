//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RandomNumberGenerator.sol";


//some OF INFOS: https://www.quicknode.com/guides/solidity/how-to-create-and-deploy-an-erc-721-nft
contract Gemesis is
    // ERC721,  
    ERC721Enumerable,
    Ownable //remove ownable to make it mintable for others
{
    using Strings for uint256;
    
    //For VRF
    RandomNumberGenerator randomNumberGenerator;
    address public randomNumberGeneratorAddress;
    mapping(uint256 => uint256) public randomMintOrder;    //CHECK IF NOW WORKS
    mapping(uint256 => bool) internal randomNumberExists;

    //For Gemesis
    string public baseURI;
    string public baseExtension = ".json"; //OR .png?
    string public notRevealedURI;
    uint256 public maxSupply = 9669;
    uint256 public currentMintSupply = 0;
    uint256 public maxMintAmount = 20;
    uint256 public cost = 0.00001 ether;
    //uint256 public nftPerAddressLimit = 10;  //INCREASE THIS OVER TIME?
    bool public paused = false;
    bool public revealed = false;
    bool public onlyWhitelisted = true;

    mapping(address => bool) public whitelisted;
    mapping(address => uint256) private mintCooldown;
    mapping(uint256 => string) private tokenURIs; 
    mapping(address => uint256) public addressMintedBalance;
    
    //BAYC COntract adress: 0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
    //MAYC COntract adress: 0x60e4d786628fea6478f785a6d7e704777c86a7c6
    //Cool Cats Contract address: 0x1a92f7381b9f03921564a437210bb9396471050c
    //Pedgy Penguins Contract address: 0xbd3531da5cf5857e7cfaa92426877b022e612cf8
    //TestGemesis Contract Rinkeby: 

    address payable public payments; //CHECK

    constructor(
        string memory _name, 
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri,
        uint256 _currentMintSupply
    ) ERC721(_name, _symbol) {
        //setBaseURI(_initBaseURI);               //only "ipfs://"?
        //setNotRevealedURI(_initNotRevealedUri);

        //For testing
        setCurrentMintSupply(_currentMintSupply);
        setBaseURI("ipfs://Qmd6dZtxs41qtyFyxaW5rG5MYQFYeESs7rpC5XwhNwqAzy/");
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
        require(supply + _mintAmount <= currentMintSupply, "The amount of Gemesis you are trying to mint is not available in this mint cycle.");
        require(supply + _mintAmount <= maxSupply, "The amount of Gemesis you are trying to mint is not available");
        
        if(msg.sender != owner()) {
            require(_mintAmount <= maxMintAmount, "You cannot mint that many NFT's in one mint");
            require(msg.value >= cost * _mintAmount, "insufficient funds");
            
        }
        for(uint256 i = 0; i < _mintAmount; i++){
            _safeMint(msg.sender, randomMintOrder[supply + 1]);
            addressMintedBalance[msg.sender]++;
            supply = totalSupply();
        }
        
    }
    
    function getBalanceOfAddress(address _address) public view returns (uint256){
        return addressMintedBalance[_address];
    }

    function setReveal(bool _state) public onlyOwner() {
        revealed = _state;
    } 

    function setCost(uint256 _newCost) public onlyOwner() {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
        maxMintAmount = _newmaxMintAmount;
    } 

    function setCurrentMintSupply(uint256 _newCurrentMintSupply) public onlyOwner() {
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

    function whitelistUser(address _user) public onlyOwner { //CHECK
        whitelisted[_user] = true;
    }
 
    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function withdraw(uint _amount) public payable onlyOwner { //TEST ME
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to send eth");
    }
}
