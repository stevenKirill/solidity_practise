// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Техническое задание на разработку смарт-контракта "Система голосования"
// Назначение
// Разработка смарт-контракта на языке Solidity для организации и проведения простого голосования в блокчейн-сети Ethereum.
// Функциональные требования
// 1. Управление кандидатами

// Функция добавления кандидата (только владельцем контракта)
// Хранение имени и уникального идентификатора кандидата
// Возможность просмотра списка кандидатов

// 2. Регистрация избирателей

// Функция регистрации нового избирателя
// Проверка на уникальность избирателя (один адрес - один избиратель)
// Хранение статуса регистрации для каждого адреса

// 3. Процесс голосования

// Проверка права голосования перед принятием голоса
// Учет голоса избирателя за выбранного кандидата
// Предотвращение повторного голосования
// Ограничение времени голосования (начало и окончание)

// 4. Подсчет результатов

// Функция получения текущего количества голосов за каждого кандидата
// Определение победителя по окончании голосования

// 5. Временные ограничения

// Установка временных рамок для голосования
// Автоматическое закрытие голосования по истечении срока
// Блокировка функций голосования вне установленного периода

// Технические требования

// Язык реализации: Solidity (версия ^0.8.0)
// Совместимость с EVM
// Оптимизация расхода газа
// Безопасность и защита от типовых уязвимостей

// Интерфейс контракта
// // Основные функции, которые должны быть реализованы:
// function addCandidate(string memory _name) external;
// function registerVoter(address _voter) external;
// function vote(uint _candidateId) external;
// function getCandidateVotes(uint _candidateId) external view returns (uint);
// function getWinner() external view returns (uint candidateId, string memory name, uint votes);
// function setVotingPeriod(uint _startTime, uint _endTime) external;

// Дополнительно

// Добавить события (events) для отслеживания основных действий
// Реализовать механизм экстренной остановки в случае обнаружения уязвимостей
// Предусмотреть возможность масштабирования контракта в будущем

contract Voting {
    struct Candidate {
        string name;
        uint256 votes;
        uint256 id;
        bool isActive;
    }
    Candidate[] public candidates;

    struct Voter {
        string name;
        bool hasVoted;
        bool exists;
    }

    mapping(address => Voter) public voters;

    address public owner;
    uint256 public votingStartTime;
    uint256 public votingEndTime;

    constructor() {
        owner = msg.sender;
        votingStartTime = 0;
        votingEndTime = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can add candidate");
        _;
    }

    modifier registered() {
        require(!voters[msg.sender].exists, "Has already registred");
        _;
    }

    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "Has already voted");
        _;
    }

    modifier isActiveCandidate(uint256 _candidateId) {
        require(candidates[_candidateId].isActive, "Has already voted");
        _;
    }

        modifier votingIsActive() {
        require(votingStartTime > 0 && votingEndTime > 0, "Voting period not set");
        require(block.timestamp >= votingStartTime, "Voting has not started yet");
        require(block.timestamp <= votingEndTime, "Voting has ended");
        _;
    }
    

    event AddedCandidate(string name, uint256 votes, uint256 id);
    event RemoveCandidate(uint256 id);
    event RegisterVoter(address voterAddress, string name);
    event VotingPeriodSet(uint256 startTime, uint256 endTime);

    function addCandidate(string memory _name) public onlyOwner {
        Candidate memory newCandidate = Candidate({
            name: _name,
            votes: 0,
            id: candidates.length,
            isActive: true
        });
        candidates.push(newCandidate);

        emit AddedCandidate(_name, 0, candidates.length);
    }

    function getCandidates() external view returns (Candidate[] memory) {
        return candidates;
    }

    function removeCandidate(uint256 _id) public onlyOwner {
        candidates[_id].isActive = false;
        emit RemoveCandidate(_id);
    }

    function registerVoter(string calldata _name) public registered {
        voters[msg.sender] = Voter({ name: _name, hasVoted: false, exists: true });
        emit RegisterVoter(msg.sender, _name);
    }

    function vote(uint _candidateId) public hasNotVoted isActiveCandidate(_candidateId) {
        candidates[_candidateId].votes += 1;
        voters[msg.sender].hasVoted = true;
    }

    function getCandidateVotes(uint256 _id) public view returns(uint256) {
        return candidates[_id].votes;
    }

    function getWinners() public onlyOwner view returns(uint256[] memory) {
        uint max = 0;
        uint winnerCount = 0;
        for(uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].votes > max) {
                max = candidates[i].votes;
                winnerCount = 1;
            } else if (candidates[i].votes == max) {
                winnerCount++;
            }
        }

        uint256[] memory winners = new uint256[](winnerCount);
        uint256 winnerIndex = 0;
        for(uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].votes == max) {
                winners[winnerIndex] = candidates[i].id;
                winnerIndex++;
            }
        }
        return winners;
    }

        // Функция для установки временного периода голосования
    function setVotingPeriod(uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_endTime > _startTime, "End time must be after start time");
        
        // Если голосование уже началось, мы не можем его изменить
        if (votingStartTime > 0 && block.timestamp >= votingStartTime) {
            require(block.timestamp < votingEndTime, "Cannot modify active or completed voting");
        }
        
        // Если _startTime в прошлом, устанавливаем текущее время
        if (_startTime < block.timestamp) {
            votingStartTime = block.timestamp;
        } else {
            votingStartTime = _startTime;
        }
        
        votingEndTime = _endTime;
        
        emit VotingPeriodSet(votingStartTime, votingEndTime);
    }

    // Функция для проверки статуса голосования
    function getVotingStatus() public view returns (string memory) {
        if (votingStartTime == 0 || votingEndTime == 0) {
            return "Not scheduled";
        } else if (block.timestamp < votingStartTime) {
            return "Scheduled but not started";
        } else if (block.timestamp >= votingStartTime && block.timestamp <= votingEndTime) {
            return "Active";
        } else {
            return "Completed";
        }
    }

    // Функция для получения оставшегося времени голосования (в секундах)
    function getRemainingVotingTime() public view returns (uint256) {
        if (block.timestamp >= votingEndTime || votingEndTime == 0) {
            return 0;
        } else if (block.timestamp < votingStartTime) {
            return votingEndTime - votingStartTime;
        } else {
            return votingEndTime - block.timestamp;
        }
    }
}
