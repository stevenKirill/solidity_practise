// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Создать контракт для хранения пары ключ-значение (mapping address => uint):
// запись, чтение, удаление ключа.

contract KeyValue {
    mapping(address => uint) public numbers;

    function addValue(address _key, uint _value) public {
        numbers[_key] = _value;
    }

    function addMy(uint _value) public {
        numbers[msg.sender] = _value;
    }

    function getMy() public view returns (uint) {
        return numbers[msg.sender];
    }

    function getValue(address _key) public view returns (uint) {
        return numbers[_key];
    }

    function deleteValue() public returns (uint) {
        uint deleted = numbers[msg.sender];
        delete numbers[msg.sender];
        return deleted;
    }
}
