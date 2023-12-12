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
}
