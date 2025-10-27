// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {KeyValue} from "./KeyValue.sol";

contract KeyValueTest is Test {
    KeyValue keyValueInstance;

    function setUp() public {
        keyValueInstance = new KeyValue();
    }

    function test_AddValue() public {
        address user = address(0x123);
        keyValueInstance.addValue(user, 42);
        uint number = keyValueInstance.numbers(user);
        assertEq(number, 42);
    }

    function test_AddMy() public {
        keyValueInstance.addMy(5);
        uint myNumber = keyValueInstance.getMy();
        assertEq(myNumber, 5);
    }

    function test_getValue() public {
        address user = address(0x123);
        keyValueInstance.addValue(user, 42);
        uint currentNumber = keyValueInstance.getValue(user);
        assertEq(currentNumber, 42);
    }

    function test_deleteValue() public {
        keyValueInstance.addMy(10);
        uint removed = keyValueInstance.deleteValue();
        assertEq(removed, 10);
        assertEq(keyValueInstance.getMy(), 0);
    }
}