// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Certificate {
    // Структура данных сертификата
    struct CertificateData {
        uint256 id; // Уникальный ID
        address owner; // Владелец
        address issuer; // Кто выдал
        string title; // Название
        string description; // Описание
        uint256 issueDate; // Дата выдачи
        uint256 expirationDate; // Дата истечения (0 = без срока)
        bool isRevoked; // Отозван ли
    }

    // Events
    event CertificateIssued(uint256 indexed id, address indexed owner, string title);
    event CertificateRevoked(uint256 indexed id, address indexed revokedBy);
    event CertificateRestored(uint256 indexed id);
    event CertificateExpired(uint256 indexed id);

    address public owner;
    uint256 public nextId = 1;
    mapping(address => CertificateData[]) public userCertificates;
    mapping(uint256 => CertificateData) public allCertificates;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier checkCertificateExists(uint256 _id) {
        require(allCertificates[_id].id != 0, "Certificate does not exist");
        _;
    }

    modifier checkExpired(uint256 _id) {
        uint256 expiration = allCertificates[_id].expirationDate;
        if (expiration != 0) {
            require(expiration > block.timestamp, "Certificate expired");
        }
        _;
    }

    modifier checkNotRevoked(uint256 _id) {
        require(!allCertificates[_id].isRevoked, "Certificate revoked");
        _;
    }

    modifier checkIsRevoked(uint256 _id) {
        require(allCertificates[_id].isRevoked, "Certificate not revoked");
        _;
    }

    function issueCertificate(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _expirationDate
    ) public onlyOwner {
        CertificateData memory newCertificate = CertificateData({
            id: nextId,
            owner: _owner,
            issuer: owner,
            title: _title,
            description: _description,
            issueDate: block.timestamp,
            expirationDate: _expirationDate,
            isRevoked: false
        });
        
        userCertificates[_owner].push(newCertificate);
        allCertificates[nextId] = newCertificate;
        
        emit CertificateIssued(nextId, _owner, _title);
        
        nextId++;
    }

    function getCertificate(uint256 _id) public view returns (CertificateData memory) {
        return allCertificates[_id];
    }

    function getAllUserCertificates(address _owner) public view returns (CertificateData[] memory) {
        return userCertificates[_owner];
    }

    function getTotalCertificates() public view returns (uint256) {
        return nextId - 1;
    }

    function verifyCertificate(uint256 _id)
        public
        view
        checkCertificateExists(_id)
        checkExpired(_id)
        checkNotRevoked(_id)
        returns (bool)
    {
        return true;
    }

    function isValid(uint256 _id) public view returns (bool) {
        if (allCertificates[_id].id == 0) return false;
        if (allCertificates[_id].isRevoked) return false;
        
        uint256 expiration = allCertificates[_id].expirationDate;
        if (expiration != 0 && expiration <= block.timestamp) {
            return false;
        }
        
        return true;
    }

    function isExpired(uint256 _id) public view returns (bool) {
        uint256 expiration = allCertificates[_id].expirationDate;
        if (expiration == 0) return false;
        return expiration <= block.timestamp;
    }

    function revokeCertificate(uint256 _id) public onlyOwner checkCertificateExists(_id) {
        require(!allCertificates[_id].isRevoked, "Certificate already revoked");
        
        // Обновляем в основном mapping
        allCertificates[_id].isRevoked = true;
        
        // Обновляем в массиве пользователя (storage)
        address certificateOwner = allCertificates[_id].owner;
        CertificateData[] storage userCerts = userCertificates[certificateOwner];
        
        for (uint256 i = 0; i < userCerts.length; i++) {
            if (userCerts[i].id == _id) {
                userCerts[i].isRevoked = true;
                break;
            }
        }
        
        emit CertificateRevoked(_id, msg.sender);
    }

    function unrevokeCertificate(uint256 _id) public onlyOwner checkCertificateExists(_id) {
        require(allCertificates[_id].isRevoked, "Certificate not revoked");
        
        // Обновляем в основном mapping
        allCertificates[_id].isRevoked = false;
        
        // Обновляем в массиве пользователя (storage)
        address certificateOwner = allCertificates[_id].owner;
        CertificateData[] storage userCerts = userCertificates[certificateOwner];
        
        for (uint256 i = 0; i < userCerts.length; i++) {
            if (userCerts[i].id == _id) {
                userCerts[i].isRevoked = false;
                break;
            }
        }
        
        emit CertificateRestored(_id);
    }

    function getCertificateOwner(uint256 _id) public view returns (address) {
        require(allCertificates[_id].id != 0, "Certificate does not exist");
        return allCertificates[_id].owner;
    }

    function getCertificateIssuer(uint256 _id) public view returns (address) {
        require(allCertificates[_id].id != 0, "Certificate does not exist");
        return allCertificates[_id].issuer;
    }

    function getCertificateCount(address _owner) public view returns (uint256) {
        return userCertificates[_owner].length;
    }
}
