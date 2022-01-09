// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(
        address indexed from,
        uint256 timestamp,
        string message,
        uint256 prizeWon
    );

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
        uint256 prizeWon;
    }

    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
    }

    function wave(string memory _message) public payable {
        /* 
        // Optional feature: add cooldown of 2 mins to prevent spammers & bots
        require(
            lastWavedAt[msg.sender] + 2 minutes < block.timestamp,
            "Wait 2m"
        );
        */

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        uint256 randomNumber = (block.difficulty + block.timestamp + seed) %
            100;
        console.log("Random # generated: %s", randomNumber);

        seed = randomNumber;

        uint256 prizeAmount = 0 ether;
        if (randomNumber < 65) {
            if (randomNumber < 5) {
                prizeAmount = 0.0005 ether;
            } else if (randomNumber < 15) {
                prizeAmount = 0.0004 ether;
            } else if (randomNumber < 30) {
                prizeAmount = 0.0003 ether;
            } else if (randomNumber < 45) {
                prizeAmount = 0.0002 ether;
            } else {
                prizeAmount = 0.0001 ether;
            }
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than they contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        waves.push(Wave(msg.sender, _message, block.timestamp, prizeAmount));

        emit NewWave(msg.sender, block.timestamp, _message, prizeAmount);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}