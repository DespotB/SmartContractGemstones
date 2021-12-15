// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//https://blog.chain.link/random-number-generation-solidity/

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";  //DEV NEEDED?=
import "@openzeppelin/contracts/access/Ownable.sol";



contract RandomNumberGenerator is VRFConsumerBase, Ownable{
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    bytes32 internal requestId;
    address LINKTokenAddress = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     * fee:     0.1 LINK
     * 
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     * fee:     0.1 LINK

     * Network: Ethereum
     * Chainlink VRF Coordinator address: 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952
     * LINK token address:                0x514910771AF9Ca656af840dff83E8264EcF986CA
     * Key Hash: 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445
     * fee:     2 LINK
     */
    constructor()
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            LINKTokenAddress // LINK Token
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; //use the keyhash which is specifici to oracle network
        fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)
    }

    function requestRandomNumber() internal returns (bytes32 _requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        randomResult = 0;
        return requestRandomness(keyHash, fee);
    }
    
    function getRandomNumber() external {
        requestId = requestRandomNumber();
    }
    
    function getLinkbalance() public view returns (uint256) {
        return LINK.balanceOf(address(this));
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override
    {
        require(requestId == _requestId, "RequestId doesnt fit");
        randomResult = _randomness;
    }
    
    function getRandomResult() public view returns (uint256) 
    {
        return randomResult;
    }
    
    //ADD Withdraw for link.
}
