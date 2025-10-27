// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Certificate} from "./Certificate.sol";

contract CertificateTest is Test {
    Certificate certificateInstance;

    function setUp() public {
        certificateInstance = new Certificate();
    }

    function test_issueCertificate() public {
        certificateInstance.issueCertificate(
            address(0x123),
            "Test Certificate",
            "This is a test certificate",
            block.timestamp + 30 days
        );

        Certificate.CertificateData memory certificate = certificateInstance
            .getCertificate(1);
        assertEq(certificate.owner, address(0x123));
        assertEq(certificate.title, "Test Certificate");
        assertEq(certificate.description, "This is a test certificate");
    }

    function test_verifyCertificate() public {
        certificateInstance.issueCertificate(
            address(0x123),
            "Test Certificate",
            "This is a test certificate",
            block.timestamp + 30 days
        );

        bool isValid = certificateInstance.verifyCertificate(1);
        assertEq(isValid, true);
    }

    function test_revokeCertificate() public {
        certificateInstance.issueCertificate(
            address(0x123),
            "Test Certificate",
            "This is a test certificate",
            block.timestamp + 30 days
        );

        assertTrue(certificateInstance.verifyCertificate(1));
        assertTrue(certificateInstance.isValid(1));

        certificateInstance.revokeCertificate(1);

        assertFalse(certificateInstance.isValid(1));

        vm.expectRevert("Certificate revoked");
        certificateInstance.verifyCertificate(1);
    }

    function test_unrevokeCertificate() public {
        certificateInstance.issueCertificate(
            address(0x123),
            "Test Certificate",
            "Description",
            block.timestamp + 30 days
        );

        // Отзываем
        certificateInstance.revokeCertificate(1);
        assertTrue(certificateInstance.isValid(1) == false);

        // Восстанавливаем
        certificateInstance.unrevokeCertificate(1);

        // Проверяем, что он снова валиден
        assertTrue(certificateInstance.verifyCertificate(1));
        assertTrue(certificateInstance.isValid(1));
    }
}
