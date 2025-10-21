// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Особенности переменных в Solidity
// Размер переменных влияет на расход газа
// Переменные состояния хранятся в storage (дорого)
// Локальные переменные хранятся в памяти (memory) или в стеке (дешевле)
// При объявлении ссылочных типов нужно указывать где хранить данные (memory, storage, calldata)

contract Learn {
    // State variables
    uint256 public counter;
    mapping(address => uint256) public balances;
    Person[] public people;

    struct Person {
        string name;
        uint256 age;
        address wallet;
    }

    function addPerson(string memory _name, uint256 _age) public {
        // Local variables
        Person memory newPerson = Person({
            name: _name,
            age: _age,
            wallet: msg.sender // Global variable
        });

        people.push(newPerson);
        balances[msg.sender] = block.timestamp; // Global variable
    }
}
