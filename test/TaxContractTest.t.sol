// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TaxContract} from "../src/TaxContract.sol";
import {DeployTaxContract} from "../script/DeployTaxContract.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract TaxContractTest is Test {
    TaxContract taxContract;

    address public TAX_PAYER_1 = makeAddr("TAX_PAYER_1");
    address public TAX_PAYER_2 = makeAddr("TAX_PAYER_2");

    uint256 public constant INIT_AMOUNT = 1 ether;

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

    function testshouldAddMultipleTaxPayers() public {
        // Arrange - Add the first taxpayer
        vm.prank(TAX_PAYER_1);
        taxContract.addTaxPayer();

        // Act - Add a second, different taxpayer
        vm.prank(TAX_PAYER_2);

        // This should go through the loop without finding TAX_PAYER_2
        taxContract.addTaxPayer();

        // Assert - Check that both taxpayers are added
        assertEq(taxContract.getTaxPayersLength(), 2, "There should be two tax payers");
    }

    function testShouldPayTax() public {
        // Arrange - Add the first taxpayer
        vm.deal(TAX_PAYER_1, INIT_AMOUNT);
        vm.prank(TAX_PAYER_1);
        taxContract.addTaxPayer();

        // Arrange - Add the second taxpayer
        vm.deal(TAX_PAYER_2, INIT_AMOUNT);
        vm.prank(TAX_PAYER_2);
        taxContract.addTaxPayer();

        uint256 transferAmount = 0.5 ether;

        // Act - Call testing function
        vm.prank(TAX_PAYER_1);
        taxContract.payTax{value: 0.5 ether}(payable(TAX_PAYER_2));

        // Assert
        uint256 givenBalanceOfPayer1 = taxContract.getTaxPayerBalance(TAX_PAYER_1);
        uint256 givenBalanceOfPayer2 = taxContract.getTaxPayerBalance(TAX_PAYER_2);

        uint256 taxAmount = 0.025 ether;
        uint256 expectedPayer2Balance = INIT_AMOUNT + transferAmount - taxAmount;

        assertEq(TAX_PAYER_1.balance, 0.5 ether);
        assertEq(TAX_PAYER_2.balance, expectedPayer2Balance);

        assertEq(givenBalanceOfPayer1, taxAmount);
        assertEq(givenBalanceOfPayer2, 0);

        assertEq(taxContract.getTaxContractBalance(), taxAmount);
    }

    function testShouldRevertPayTaxWhenNotEnoughAmount() public {
        // Arrange - Add the first taxpayer
        vm.deal(TAX_PAYER_1, INIT_AMOUNT);
        vm.prank(TAX_PAYER_1);
        taxContract.addTaxPayer();

        // Arrange - Add the second taxpayer
        vm.deal(TAX_PAYER_2, INIT_AMOUNT);
        vm.prank(TAX_PAYER_2);
        taxContract.addTaxPayer();

        // Act - Call testing function
        vm.prank(TAX_PAYER_1);
        vm.expectRevert(TaxContract.TaxContract__NotEnoughAmount.selector);
        taxContract.payTax{value: 0}(payable(TAX_PAYER_2));
    }

    function testShouldCalculateTaxAmount() public {
        // Arrange
        uint256 givenAmount = 100;
        uint256 expectedTaxAmount = 5;

        // Act
        uint256 calculatedTaxAmount = taxContract._calculateTaxAmount(givenAmount);

        // Assert
        assertEq(calculatedTaxAmount, expectedTaxAmount);
    }

    function testShouldWithdrawSuccessfullyByOwner() public {
        // Arrange
        address taxOfficeaddress = taxContract.i_taxOfficeAddress();
        uint256 initialContractBalance = address(taxContract).balance;
        uint256 initialOwnerBalance = taxOfficeaddress.balance;

        // Act
        vm.prank(taxOfficeaddress); // Simulating call by the owner
        taxContract.withdraw();

        // Assert
        assertEq(address(taxContract).balance, 0, "Contract balance should be zero after withdrawal");
        assertEq(
            taxOfficeaddress.balance,
            initialOwnerBalance + initialContractBalance,
            "Owner should receive contract balance"
        );
    }

    function testShouldRevertWithdrawByNonOwner() public {
        // Arrange
        address nonOwner = makeAddr("NON_OWNER");

        // Act & Assert
        vm.prank(nonOwner); // Simulating call by a non-owner
        vm.expectRevert(TaxContract.TaxContract__NotTaxOfficeAddress.selector);
        taxContract.withdraw();
    }

    function testShouldResetTaxPayersDataOnWithdraw() public {
        // Arrange
        address taxOfficeaddress = taxContract.i_taxOfficeAddress();

        // Add a taxpayer and simulate a tax payment
        vm.deal(TAX_PAYER_1, INIT_AMOUNT);
        vm.prank(TAX_PAYER_1);
        taxContract.addTaxPayer();

        vm.prank(TAX_PAYER_2);
        taxContract.addTaxPayer();

        vm.prank(TAX_PAYER_1);
        taxContract.payTax{value: 100}(payable(TAX_PAYER_1));

        // Act
        vm.prank(taxOfficeaddress); // Simulating call by the owner
        taxContract.withdraw();

        // Assert
        assertEq(taxContract.getTaxPayerBalance(TAX_PAYER_2), 0, "Taxpayer's balance should be reset to zero");
        assertEq(taxContract.getTaxPayersLength(), 0, "Taxpayer list should be empty");
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
