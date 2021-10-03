// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//https://blog.chain.link/random-number-generation-solidity/

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract RandomNumberConsumer is VRFConsumerBase {
    bytes32 internal _keyHash;
    uint256 internal _fee;
    uint256 public _randomResult;
    uint256 public _maxMintableTokens = 10000;

    struct randomNumber {
        uint256 value;
        bool hasValue;
    }

    mapping(uint256 => randomNumber) _randomMintOrder;

    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4

     * Network: Ethereum
     * Chainlink VRF Coordinator address: 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952
     * LINK token address:                0x514910771AF9Ca656af840dff83E8264EcF986CA
     * Key Hash: 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445
     */
    constructor()
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088 // LINK Token
        )
    {
        _keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4; //use the keyhash which is specifici to oracle network
        _fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= _fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(_keyHash, _fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        _randomResult = randomness;
    }

    //Test me
    function createRandomOrder(uint256 randomValue, uint256 maxNumber)
        public
        pure
        returns (uint256[] memory expandedValues)
    {
        for (uint256 i = 0; i < maxNumber; i++) {
            if (!_randomMintOrder[i].hasValue) {
                randomNumber rng = data();
                rng.value = uint256(keccak256(abi.encode(randomValue, i))).mod(maxNumber).add(1);
                rng.hasValue = true;
                _randomMintOrder[i] = rng;
            } else {
                i--;
            }
        }
        return expandedValues;
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
