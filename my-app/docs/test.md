assertEq(a, b) — проверяет, что значения a и b равны (поддерживает типы: uint, int, bool, address, bytes, string).
assertNotEq(a, b) — проверяет, что значения a и b не равны.
assertTrue(condition) — проверяет, что выражение истинно (true).
assertFalse(condition) — проверяет, что выражение ложно (false).
assertGt(a, b) — проверяет, что a больше b.
assertGe(a, b) — проверяет, что a больше или равно b.
assertLt(a, b) — проверяет, что a меньше b.
assertLe(a, b) — проверяет, что a меньше или равно b.
assertApproxEqAbs(a, b, maxDelta) — проверяет, что разница между a и b не больше maxDelta.
assertApproxEqRel(a, b, maxPercentDelta) — проверяет, что относительная разница между a и b не превышает maxPercentDelta процентов.


vm.roll(uint256 newBlockNumber) — устанавливает номер текущего блока.
vm.warp(uint256 newTimestamp) — изменяет текущее время (timestamp).
vm.deal(address account, uint256 amount) — задаёт новому адресу нужный баланс ETH.
vm.prank(address sender) — заставляет следующий вызов смарт-контракта происходить от имени другого адреса.
vm.expectRevert(bytes calldata) — ожидает откат (revert) вызова, например, для проверки ошибок.
vm.startPrank(address sender) и vm.stopPrank() — все последующие вызовы будут идти от указанного адреса, пока не будет вызван stopPrank.
vm.label(address addr, string memory label) — даёт адресам удобные подписи, чтобы легче читать лог тестов.