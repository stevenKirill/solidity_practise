
const isDoc = true;

// function имяФункции(тип параметр1, тип параметр2) видимость модификаторы returns (тип возвращаемого значения) {
//     // тело функции
//     return значение; // если функция что-то возвращает
// }

// public - доступна отовсюду (из контракта и извне)
// private - доступна только в текущем контракте
// internal - доступна в текущем контракте и его наследниках
// external - доступна только извне контракта
// view - не изменяет состояние (только чтение)
// pure - не читает и не изменяет состояние
// payable - может принимать ETH
// virtual - может быть переопределена в наследнике
// override - переопределяет функцию родительского контракта

// modifier onlyOwner() {
//     require(msg.sender == owner, "Not owner");
//     _;  // продолжение выполнения функции
// }

// function withdraw() public onlyOwner {
//     payable(owner).transfer(address(this).balance);
// }

// Специальная функция, вызываемая при создании контракта: constructor
// constructor(тип параметр1, тип параметр2) {
//     // тело конструктора
// }

// fallback - вызывается при несуществующем идентификаторе функции:
// fallback() external payable {
//     emit FallbackCalled(msg.sender, msg.value);
// }

// receive - вызывается при получении ETH без данных:

// struct Person {
//     string name;
//     uint age;
//     address wallet;
//     bool active;
// }

// // Использование структуры
// Person public owner;

// function createPerson() public {
//     // Создание экземпляра структуры
//     Person memory newPerson = Person("Alice", 30, msg.sender, true);
    
//     // Или с именованными полями
//     Person memory anotherPerson = Person({
//         name: "Bob",
//         age: 25,
//         wallet: msg.sender,
//         active: false
//     });
    
//     // Доступ к полям
//     string memory personName = newPerson.name;
//     newPerson.age = 31;
// }

// Статический массив
// uint[5] public fixedArray;

// Динамический массив
// uint[] public dynamicArray;

// // Массив структур
// Person[] public people;

// function arrayExamples() public {
//     // Заполнение статического массива
//     fixedArray[0] = 10;
    
//     // Работа с динамическим массивом
//     dynamicArray.push(100);
//     dynamicArray.push(200);
//     uint length = dynamicArray.length;
    
//     // Получение элемента
//     uint value = dynamicArray[0];
    
//     // Удаление элемента (не меняет длину массива, устанавливает значение по умолчанию)
//     delete dynamicArray[0]; // теперь dynamicArray[0] = 0
    
//     // Удаление последнего элемента (с уменьшением длины)
//     dynamicArray.pop();
    
//     // Массив в памяти (должен иметь фиксированный размер)
//     uint[] memory memoryArray = new uint[](3);
//     memoryArray[0] = 10;
    
//     // Массив структур
//     people.push(Person("Charlie", 40, msg.sender, true));
// }

// Массивы в storage могут быть динамическими
// Массивы в memory должны иметь фиксированный размер
// В функциях нельзя возвращать динамические массивы из memory
// Операция delete не меняет длину динамического массива

// enum Status { Pending, Approved, Rejected, Canceled }

// // Использование enum
// Status public currentStatus;

// function updateStatus(Status newStatus) public {
//     currentStatus = newStatus;
// }

// function isPending() public view returns (bool) {
//     return currentStatus == Status.Pending;
// }

// function getStatus() public view returns (Status) {
//     return currentStatus;
// }

// function resetStatus() public {
//     delete currentStatus; // Сбрасывает к первому значению (Pending)
// }

// Особенности enum:

// Внутренне представляются как uint
// Первое значение имеет индекс 0
// Удобны для представления состояний и флагов
// После операции delete значение сбрасывается на первый элемент

// function sumArray(uint[] memory numbers) public pure returns (uint) {
//     uint sum = 0;
//     for (uint i = 0; i < numbers.length; i++) {
//         sum += numbers[i];
//     }
//     return sum;
// }

// Особенности использования циклов в Solidity
// Контроль расхода газа
// Самая важная особенность - циклы потребляют газ, поэтому:

// Всегда избегайте бесконечных циклов - они приведут к исчерпанию газа и отмене транзакции
// Лимитируйте количество итераций:
// Используйте паттерн состояния для обработки больших массивов через несколько транзакций:

// Предпочитайте for-циклы с четким ограничением числа итераций
// Избегайте динамических условий выхода, зависящих от внешних факторов
// Используйте маппинги вместо циклов для поиска, где это возможно:


// calldata доступен только для параметров external функцийcalldata переменные только
// для чтения (read-only), их нельзя модифицироватьИспользование calldata
// вместо memory экономит газ, так как данные не копируютсяОсобенно эффективно для массивов,
//  строк и сложных структур данных