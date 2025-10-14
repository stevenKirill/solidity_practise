// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// функции доступные только владельцы
contract OnlyOwner {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwnerModifier() {
        require(msg.sender == owner, "Not owner of contract!");
        _;
    }
// require(newOwner != address(0), "Invalid address") - проверка, что новый адрес не является нулевым адресом.
// address(0) - это нулевой адрес в Ethereum (0x0000000000000000000000000000000000000000). Он используется для обозначения "пустого" адреса.
// owner = newOwner - присваивание новому адресу статуса владельца контракта.
// Эта проверка на нулевой адрес важна, потому что если владельцем станет address(0):

// Никто не сможет вызывать функции с модификатором onlyOwner
// Права на управление контрактом будут утеряны навсегда
// Контракт может стать "заблокированным" для некоторых операций
// Поэтому это базовая защита от случайной передачи прав на пустой адрес.
    function changeOwner(address newOwner) external OnlyOwnerModifier {
        require(newOwner != address(0), "Address cannot be 0");
        owner = newOwner;
    }

    function onlyOwnerFunction() public view OnlyOwnerModifier returns (string memory) {
        return "Secret message for contract owner";
    }
}