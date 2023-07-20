// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive functfunctionsion (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import {Ticket} from "./Ticket.sol";
import {IERC4671} from "./eip4671/IERC4671.sol";

error NFTRaffle__NotEnoughETHSent();
error NFTRaffle__TransferFailed();

/**
 * @title An NFT Raffle Contract
 * @author Olusanya Ayodeji
 * @notice This contract is for creating a robust NFT Raffle Contract
 * @dev Implements Chainlink VRFv2 and Chainlink Automation
 */
contract NFTRaffle {
    /**State Variable */
    uint256 private immutable i_entranceFee;
    IERC4671 private immutable RaffleTicket;
    uint256 private immutable i_endingTime;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    address payable[] private s_players;

    /**Events */
    event EnteredRaffle();

    constructor(
        uint256 entranceFee,
        address raffleTicket,
        uint256 endingTime,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) {
        i_entranceFee = entranceFee;
        i_endingTime = endingTime;
        RaffleTicket = IERC4671(raffleTicket);
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert NFTRaffle__NotEnoughETHSent();
        }

        s_players.push(payable(msg.sender));
        RaffleTicket._mint(msg.sender);
        emit EnteredRaffle();
    }

    function requestRandomWords() external returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    // CEI: Checks, Effects, Interactions

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint indexOfWinner = _randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        // s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        // emit PickedWinner(winner);

        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert NFTRaffle__TransferFailed();
        }
    }
}
