// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC4671} from "./eip4671/ERC4671";

error NFTRaffle_NotEnoughETHSent();


/**
 * @title An NFT Raffle Contract
 * @author Olusanya Ayodeji
 * @notice This contract is for creating a robust NFT Raffle Contract
 * @dev Implements Chainlink VRFv2 and Chainlink Automation
 */
contract NFTRaffle {

    /**State Variable */
    uint256 immutable i_entranceFee;
    constructor (uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }
    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert NFTRaffle_NotEnoughETHSent();
        }
    }
}
