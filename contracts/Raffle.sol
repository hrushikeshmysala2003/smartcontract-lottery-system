// Raffle

// Enter the lottery
// Pick a random winner (verifiable random)
// Winner to be solected every X minutes --> completely automate
// Chainlink Oracle -> Randomness, Automated Execution (Chainlink Keepers)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

error Raffle__NotEnoughETHEntered();

contract Raffle {
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    constructor(uint256 entranceFee) {
        i_entranceFee=entranceFee;
    }
    function enterRaffle() public payable {
        // msg.value > entrance fee
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
    }

    function getEntranceFee() {
        return i_entranceFee;
    }

    function
}