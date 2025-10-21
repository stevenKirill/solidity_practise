// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Fundme {
    uint256 public MINIMUM_USD = 50;

    function fund() public payable {
        require(msg.value > 1e18, "You need to send at least 1 ETH");
    }

    // function withdraw() {}
}
