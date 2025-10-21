// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint private counter;

    function increment() public {
        counter += 1;
    }

    function decrement() public {
        require(counter > 0, "Counter cannot be less than zero");
        counter -= 1;
    }

    function getCount() public view returns (uint) {
        return counter;
    }
}