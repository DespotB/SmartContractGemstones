//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


//ALOT OF INFOS: https://www.quicknode.com/guides/solidity/how-to-create-and-deploy-an-erc-721-nft
contract Gemesis is
    // ERC721,  
    ERC721Enumerable,
    Ownable //remove ownable to make it mintable for others
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    Counters.Counter private _tokenIds;

    //THIS CAN BE USEFULL FOR ANTI GAS WAR MECHANICS only x amount mintable by addres per hour
    uint256 lastUpdated;
    // total supply
    uint256 private maxSupply = 3;
    uint256 public cost = 0.0001 ether;
    mapping(address => uint256) private _mintCooldown;

      // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    // Base URI
    string private _baseURIextended;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
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

        string memory _tokenURI = _tokenURIs[tokenId];
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
    }

    function mint(
        address _to,
        string memory tokenURI_
    ) external virtual payable {
        uint256 supply = totalSupply();

        require(supply < maxSupply, "All NFT's have been minted");
        require(oneHourHasPassed(_mintCooldown[_to]), "Your Mintcooldown has not reseted yet, it will be reset at ....");
        require(msg.value >= cost, "Not enough ETH sent; check price!");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, tokenURI_);

        //Update timestamp and safe last updated for this address
        _mintCooldown[_to] = block.timestamp;
    }

    function eternalMint(
        address _to,
        string memory tokenURI_
    ) external onlyOwner{
        _tokenIds.increment();
        _safeMint(_to, _tokenIds.current());
        _setTokenURI(_tokenIds.current(), tokenURI_);  
    }


    function updateTimestamp() public {
        lastUpdated = block.timestamp;
    }

    function oneHourHasPassed(
        uint256 addressLastMintTimestamp
    ) public view returns (bool) {
        return (block.timestamp >= (addressLastMintTimestamp + 2 minutes));
    }
}
