// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Strings {
    mapping(uint => string) private strings;
    uint private counter = 0;

    function setString(string memory value) public {
        strings[counter] = value;
        counter += 1;
    }

    function getString(uint index) public view returns (string memory) {
        return strings[index];
    }
}

contract StringStorage {
    string private storedString;

    function set(string memory newString) public {
        storedString = newString;
    }

    function get() public view returns (string memory) {
        return storedString;
    }
}
