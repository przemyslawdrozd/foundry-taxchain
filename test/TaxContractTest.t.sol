// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TaxContract} from "../src/TaxContract.sol";
import {DeployTaxContract} from "../script/DeployTaxContract.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract TaxContractTest is Test {
    TaxContract taxContract;

    address public TAX_PAYER_1 = makeAddr("TAX_PAYER_1");
    address public TAX_PAYER_2 = makeAddr("TAX_PAYER_2");

    function setUp() external {
        DeployTaxContract deployer = new DeployTaxContract();
        taxContract = deployer.run();
    }

    function testShouldAddTaxPayerIfNotExists() public {
        // Arrange
        vm.prank(TAX_PAYER_1);

        // Act
        taxContract.addTaxPayer();
        address taxPayer = taxContract.getTaxPayerByIndex(0);

        // Assert
        assert(TAX_PAYER_1 == taxPayer);
    }

    function testShouldRevertIfUserExists() public {
        // Arrange
        address existingUser = address(1);
        vm.prank(existingUser);

        // First addition should succeed
        taxContract.addTaxPayer();

        // Act & Assert
        vm.expectRevert(TaxContract.TaxContract__TaxPayerExists.selector);
        vm.prank(existingUser);
        taxContract.addTaxPayer();
    }

    function testAddMultipleTaxPayers() public {
        // Arrange - Add the first taxpayer
        vm.prank(TAX_PAYER_1);
        taxContract.addTaxPayer();

        // Act - Add a second, different taxpayer
        vm.prank(TAX_PAYER_2);

        // This should go through the loop without finding TAX_PAYER_2
        taxContract.addTaxPayer();

        // Assert - Check that both taxpayers are added
        assertEq(taxContract.getTaxPayersLength(), 2, "There should be two taxpayers");
    }

    function testShouldReturnsForGetterFunctions() public {
        // Arrange
        address testTaxPayer = address(1);

        vm.prank(testTaxPayer);
        taxContract.addTaxPayer();

        // Act and Assert
        uint256 taxpayersLength = taxContract.getTaxPayersLength();
        assertEq(taxpayersLength, 1, "Incorrect number of taxpayers");

        address taxpayerAtIndex = taxContract.getTaxPayerByIndex(0);
        assertEq(taxpayerAtIndex, testTaxPayer, "Incorrect taxpayer at index");

        uint256 taxpayerBalance = taxContract.getTaxPayerBalance(testTaxPayer);
        assertEq(taxpayerBalance, 0, "Incorrect taxpayer balance");

        uint256 contractBalance = taxContract.getTaxContractBalance();
        assertEq(contractBalance, address(taxContract).balance, "Incorrect contract balance");
    }
}
