// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    // интерфейс структура для задачи
    struct Task {
        string content;
        bool isCompleted;
        uint256 createdAt;
    }

    // маппинг адрес пользователя и его задачи
    mapping(address => Task[]) private userTasks;

    event TaskAdded(address user, uint256 taskId, string content);
    event TaskDeleted(address user, uint256 taskId, string content);
    event TaskToggled(address user, uint256 taskId, bool isCompleted);

    modifier taskExists(uint256 _taskId) {
        require(_taskId < userTasks[msg.sender].length, "Task does not exist");
        _;
    }

    // добавление задачи
    function addTask(string calldata _content) external {
        Task memory newTask = Task({
            content: _content,
            isCompleted: false,
            createdAt: block.timestamp
        });

        userTasks[msg.sender].push(newTask);

        emit TaskAdded(msg.sender, block.timestamp, _content);
    }

    // удаление задачи
    //     1. Мы берём последний элемент массива
    // 2. Перемещаем его на место удаляемого элемента (если удаляемый элемент не последний)
    // 3. Удаляем последний элемент с помощью `.pop()`
    function removeTask(uint256 _taskId) external {
        uint lastIndex = userTasks[msg.sender].length - 1;
        if (_taskId != lastIndex) {
            userTasks[msg.sender][_taskId] = userTasks[msg.sender][lastIndex];
        }
        userTasks[msg.sender].pop();

        emit TaskDeleted(
            msg.sender,
            _taskId,
            userTasks[msg.sender][_taskId].content
        );
    }

    // тоггл задачи
    function toggleTask(uint256 _taskId) external taskExists(_taskId) {
        Task storage currentTask = userTasks[msg.sender][_taskId];
        currentTask.isCompleted = !currentTask.isCompleted;

        emit TaskToggled(msg.sender, _taskId, currentTask.isCompleted);
    }

    function getTasks() external view returns (Task[] memory) {
        return userTasks[msg.sender];
    }

    function getTaskById(
        uint256 _taskId
    )
        external
        view
        returns (string memory content, bool completed, uint256 createdAt)
    {
        Task storage task = userTasks[msg.sender][_taskId];
        return (task.content, task.isCompleted, task.createdAt);
    }

    function getTasksLenght() external view returns (uint256) {
        return userTasks[msg.sender].length;
    }

    function updateTaskContent(
        uint256 _taskId,
        string calldata _newContent
    ) external taskExists(_taskId) {
        userTasks[msg.sender][_taskId].content = _newContent;
    }
}
