// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "./SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank simpleBankInstance;
    address user = address(0xABCD);

    function setUp() public {
        simpleBankInstance = new SimpleBank();
        // Выделяем 10 ether тестовому пользователю
        vm.deal(user, 10 ether);
    }

    function test_Deposit() public {
        // Переключаемся на пользователя
        vm.startPrank(user);

        // Депозит 5 ether
        simpleBankInstance.deposit{value: 5 ether}();

        // Проверяем баланс через функцию getBalance
        uint balance = simpleBankInstance.getBalance();
        assertEq(balance, 5 ether, "Balance should be 5 ether");

        vm.stopPrank();
    }

    function test_DepositTwice() public {
        vm.startPrank(user);

        // Первый депозит
        simpleBankInstance.deposit{value: 2 ether}();
        assertEq(simpleBankInstance.getBalance(), 2 ether);

        // Второй депозит
        simpleBankInstance.deposit{value: 3 ether}();
        assertEq(
            simpleBankInstance.getBalance(),
            5 ether,
            "Balance should accumulate"
        );

        vm.stopPrank();
    }

    function test_Withdraw() public {
        vm.startPrank(user);

        // Сначала депозит
        simpleBankInstance.deposit{value: 5 ether}();

        // Запоминаем баланс до вывода
        uint balanceBefore = address(user).balance;

        // Выводим 2 ether
        simpleBankInstance.withdraw(2 ether);

        // Проверяем, что баланс контракта уменьшился
        assertEq(
            simpleBankInstance.getBalance(),
            3 ether,
            "Contract balance should be 3 ether"
        );

        // Проверяем, что пользователь получил ETH
        uint balanceAfter = address(user).balance;
        assertEq(
            balanceAfter,
            balanceBefore + 2 ether,
            "User should receive 2 ether"
        );

        vm.stopPrank();
    }

    function test_WithdrawTooMuch() public {
        vm.startPrank(user);

        // Депозит только 3 ether
        simpleBankInstance.deposit{value: 3 ether}();

        // Пытаемся вывести больше
        vm.expectRevert("Not enougth money");
        simpleBankInstance.withdraw(5 ether);

        vm.stopPrank();
    }

    function test_GetBalance() public {
        vm.startPrank(user);

        // Начальный баланс должен быть 0
        assertEq(
            simpleBankInstance.getBalance(),
            0,
            "Initial balance should be 0"
        );

        // Делаем депозит
        simpleBankInstance.deposit{value: 100 wei}();

        // Проверяем баланс
        assertEq(
            simpleBankInstance.getBalance(),
            100 wei,
            "Balance should be 100 wei"
        );

        vm.stopPrank();
    }

    function test_MultipleUsers() public {
        // Первый пользователь
        vm.startPrank(user);
        simpleBankInstance.deposit{value: 5 ether}();
        assertEq(simpleBankInstance.getBalance(), 5 ether);
        vm.stopPrank();

        // Второй пользователь
        address user2 = address(0x1234);
        vm.deal(user2, 10 ether);
        vm.startPrank(user2);
        simpleBankInstance.deposit{value: 3 ether}();
        assertEq(
            simpleBankInstance.getBalance(),
            3 ether,
            "User2 balance should be 3 ether"
        );
        vm.stopPrank();

        // Снова проверяем первого пользователя
        vm.startPrank(user);
        assertEq(
            simpleBankInstance.getBalance(),
            5 ether,
            "User balance should remain 5 ether"
        );
        vm.stopPrank();
    }
}
