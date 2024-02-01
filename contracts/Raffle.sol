// Raffle

// Enter the lottery
// Pick a random winner (verifiable random)
// Winner to be solected every X minutes --> completely automate
// Chainlink Oracle -> Randomness, Automated Execution (Chainlink Keepers)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle__NotEnoughETHEntered();
error Raffle__TransferFailed();

contract Raffle is VRFConsumerBaseV2 {
    address private s_recentWinner;

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant requestConfirmations = 3;
    uint32 private constant numWords = 1;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    event RaffleEnter(address indexed player);
    event RequestRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        // msg.value > entrance fee
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
        // emit event after updating array or map
        emit RaffleEnter(msg.sender);
    }

    function requestRandomWinner() external {
        // Request the random number
        // Once we get it, do
        // 2 transaction process
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gasLane
            i_subscriptionId,
            requestConfirmations,
            i_callbackGasLimit,
            numWords
        );
        emit RequestRaffleWinner(requestId);
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }

        emit WinnerPicked(recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
