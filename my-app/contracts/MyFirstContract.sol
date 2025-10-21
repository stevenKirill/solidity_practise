// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MyFirstContract {
    // Переменная состояния
    string public message;
    address public owner;
    
    // Событие для логирования
    event MessageUpdated(string newMessage, address updatedBy);
    
    // Конструктор - выполняется один раз при деплое
    constructor(string memory _initialMessage) {
        message = _initialMessage;
        owner = msg.sender;
    }
    
    // Функция для изменения сообщения
    function updateMessage(string memory _newMessage) public {
        message = _newMessage;
        emit MessageUpdated(_newMessage, msg.sender);
    }
    
    // Функция только для владельца
    function ownerOnlyUpdate(string memory _newMessage) public {
        require(msg.sender == owner, "Only owner can call this function");
        message = _newMessage;
        emit MessageUpdated(_newMessage, msg.sender);
    }
    
    // Функция для получения сообщения (view - не изменяет состояние)
    function getMessage() public view returns (string memory) {
        return message;
    }
}
