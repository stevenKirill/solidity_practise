// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Используйте кастомные ошибки вместо сообщений в require (экономит газ)
// error ProductNotFound(uint256 productId);
// error EmptyName();
// error InvalidPrice();

contract Inventory {
    struct Product {
        string name;
        uint256 id;
        uint256 quantity;
        uint256 price;
    }
    address public owner;
    Product[] public products;
    // Маппинг от ID продукта к его индексу в массиве products
    // маппинг это ассоциативный массив (KeyType => ValueType)
    mapping(uint256 => uint256) private productIdToIndex;
    // Маппинг для проверки существования продукта
    // доступ к элементам осуществляется через синтаксис mappingName[key]
    mapping(uint256 => bool) private productExists;
    uint256 public counter;

    event ProductAdded(
        uint256 id,
        string name,
        uint256 quantity,
        uint256 price
    );
    event ProductDeleted(uint256 id);
    event ProductChanged(
        uint256 id,
        string name,
        uint256 quantity,
        uint256 price
    );
    error ProductNotFound(uint256 productId);
    error EmptyName();
    error InvalidPrice();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function addProduct(
        string calldata _name,
        uint256 _quantity,
        uint256 _price
    ) external onlyOwner {
        counter++;
        Product memory newProduct = Product({
            id: counter,
            name: _name,
            quantity: _quantity,
            price: _price
        });
        products.push(newProduct);

        uint256 newIndex = products.length - 1;
        productIdToIndex[counter] = newIndex;
        productExists[counter] = true;

        emit ProductAdded(counter, _name, _quantity, _price);
    }

    function getProductById(
        uint256 _productId
    ) public view returns (Product memory) {
        require(
            productExists[_productId],
            "This product with this id doedn't exist"
        );
        uint256 index = productIdToIndex[_productId];
        return products[index];
    }

    function updateProduct(
        uint256 _productId,
        string memory _name,
        uint256 _quantity,
        uint256 _price
    ) external {
        require(
            productExists[_productId],
            "This product with this id doesn't exist"
        );
        uint256 index = productIdToIndex[_productId];
        products[index].name = _name;
        products[index].quantity = _quantity;
        products[index].price = _price;

        emit ProductChanged(_productId, _name, _quantity, _price);
    }

    function deleteProduct(uint256 _productId) external {
        require(
            productExists[_productId],
            "This product with this id doesn't exist"
        );
        uint256 lastIndex = products.length - 1;
        uint256 index = productIdToIndex[_productId];

        if (index != lastIndex) {
            Product memory lastItem = products[lastIndex];
            products[index] = lastItem;
            // Обновляем маппинг для перемещенного элемента
            productIdToIndex[lastItem.id] = index;
        }

        products.pop();
        // Очищаем маппинги для удаленного продукта
        delete productExists[_productId];
        delete productIdToIndex[_productId];

        emit ProductDeleted(_productId);
    }

    function updateQuantity(uint256 _productId, uint256 newQuantity) public {
        require(
            productExists[_productId],
            "This product with this id doesn't exist"
        );
        uint256 index = productIdToIndex[_productId];
        products[index].quantity = newQuantity;
    }

    function getAllProducts() external view returns (Product[] memory) {
        return products;
    }

    function getProductCount() external view returns (uint256) {
        return products.length;
    }
}
