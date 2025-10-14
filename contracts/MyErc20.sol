// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StakableToken
 * @dev ERC20 токен с функционалом стейкинга, вознаграждений и истории транзакций
 */
contract StakableToken is ERC20, Ownable {
    // Структура стейка
    struct Stake {
        uint256 amount;        // Количество заблокированных токенов
        uint256 since;         // Время начала стейка
        uint256 unlockTime;    // Время разблокировки
    }
    
    // Структура транзакции для истории
    struct Transaction {
        address from;          // Отправитель
        address to;            // Получатель
        uint256 amount;        // Сумма
        uint256 timestamp;     // Время транзакции
        string transactionType; // Тип: "transfer", "stake", "unstake", "reward"
    }
    
    // Переменные для стейкинга
    uint256 public rewardRate = 5;     // Процент вознаграждения (например, 5%)
    uint256 public minStakeDuration = 7 days; // Минимальный период стейкинга
    
    // Маппинги
    mapping(address => Stake) public stakes;
    mapping(address => bool) public blockStakes;
    mapping(address => Transaction[]) public transactionHistory;
    mapping(address => uint256) public rewards;
    
    // События
    event Staked(address indexed user, uint256 amount, uint256 unlockTime);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event TransactionRecorded(address indexed user, string transactionType);
    
    constructor(string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        // Минтим начальный запас токенов создателю контракта
        _mint(msg.sender, initialSupply);
    }
    
    /**
     * @dev Переопределение функции transfer для записи истории
     */
    function transfer(address _to, uint256 _amount) public override returns (bool) {
        // TODO: Реализовать запись в историю транзакций и вызвать родительскую функцию transfer
        Transaction memory newTransaction = Transaction({
            from: msg.sender,
            to: _to,
            amount: _amount,
            timestamp: block.timestamp,
            transactionType: "transfer",
        });
        transactionHistory[msg.sender].push(newTransaction);
        emit TransactionRecorded(msg.sender, "transfer");
        return super.transfer(_to, _amount);
    }
    
    /**
     * @dev Переопределение функции transferFrom для записи истории
     */
    function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool) {
        // TODO: Реализовать запись в историю транзакций и вызвать родительскую функцию transferFrom
        Transaction memory newTransaction = Transaction({
            from: _from,
            to: _to,
            amount: _amount,
            timestamp: block.timestamp,
            transactionType: "transfer",
        });
        transactionHistory[msg.sender].push(newTransaction);
        emit TransactionRecorded(_from, "transfer");
        return super.transferFrom(_from, _to, _amount);
    }
    
    /**
     * @dev Функция стейкинга токенов
     * @param amount Количество токенов для стейкинга
     * @param duration Продолжительность стейкинга в секундах
     */
    function stake(uint256 _amount, uint256 _duration) external {
        // TODO: Проверить минимальную продолжительность
        require(_duration >= minStakeDuration, "Duration too short");
        // TODO: Проверить баланс пользователя
        require(_amount > 0, "not enought money");
        // TODO: Создать запись о стейке
        Stake memory newStake = Stake({
            amount: _amount,
            since: block.timestamp,
            unlockTime: block.timestamp + _duration,
        });
        // TODO: Заблокировать токены
        bool ok = super.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = newStake;
        blockStakes[msg.sender] = true;
        require(ok, "transferFrom failed");
        // TODO: Записать транзакцию в историю
        Transaction memory newTransaction = Transaction({
            from: msg.sender,
            to: address(this),
            amount: _amount,
            timestamp: block.timestamp,
            transactionType: "stake",
        });
        transactionHistory[msg.sender].push(newTransaction);
        // TODO: Вызвать событие
        emit Staked(msg.sender, _amount, block.timestamp + _duration);
    }
    
    /**
     * @dev Функция расчета вознаграждения
     * @param account Адрес аккаунта для расчета
     * @return Сумма вознаграждения
     */
    function calculateReward(address _account) public view returns (uint256) {
        Stake memory s = stakes[_account];
        if (s.amount == 0) return 0;

        uint256 end = block.timestamp < s.unlockTime ? block.timestamp : s.unlockTime;
        if (end <= s.since) return 0;

        uint256 elapsed = end - s.since;

        // Годовая ставка в bps, начисляем пропорционально времени:
        // reward = amount * rateBps/10000 * (elapsed / secondsPerYear)
        uint256 SECONDS_PER_YEAR = 365 days;

        // Чтобы избежать потерь при делении, умножаем по порядку и делим в конце:
        uint256 reward = (s.amount * rewardRateBps * elapsed) / (10000 * SECONDS_PER_YEAR);

        return reward;
    }
    
    /**
     * @dev Функция для снятия стейка и получения вознаграждения
     */
    function unstake() external {
        // TODO: Проверить, есть ли активный стейк
        Stake memory currentStake = stakes[msg.sender];
        require(blockStakes[msg.sender] && currentStake.amount > 0, "You already have stake");
        // TODO: Проверить, прошло ли время блокировки
        require(block.timestamp >= currentStake.unlockTime, "Unlock time hasn't passed");
        // TODO: Рассчитать вознаграждение
        uint256 reward = calculateReward(msg.sender);
        // TODO: Разблокировать токены и начислить вознаграждение
        _transfer(address(this), msg.sender, amount);
        // TODO: Очистить данные стейка
        delete stakes[msg.sender];
        delete blockStakes[msg.sender];
        // TODO: Записать транзакцию в историю
        Transaction memory newTransaction = Transaction({
            from: address(this),
            to: msg.sender,
            amount: reward,
            timestamp: block.timestamp,
            transactionType: "unstake",
        });
        transactionHistory[msg.sender].push(newTransaction);
        // TODO: Вызвать события
        emit event Unstaked(msg.sender,reward);
    }
    
    /**
     * @dev Функция для получения истории транзакций пользователя
     * @param account Адрес аккаунта
     * @return Массив транзакций пользователя
     */
    function getTransactionHistory(address _account) external view returns (Transaction[] memory) {
        // TODO: Реализовать возврат истории транзакций пользователя
        return transactionHistory[_account];
    }
    
    /**
     * @dev Функция для изменения процента вознаграждения (только владелец)
     * @param newRate Новый процент вознаграждения
     */
    function setRewardRate(uint256 newRate) external onlyOwner {
        // TODO: Обновить процент вознаграждения
    }
    
    /**
     * @dev Служебная функция для записи транзакции в историю
     */
    function _recordTransaction(
        address from, 
        address to, 
        uint256 amount, 
        string memory transactionType
    ) internal {
        // TODO: Создать новую запись о транзакции и сохранить в истории
    }
}