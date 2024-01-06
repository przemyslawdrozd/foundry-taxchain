// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {console} from "forge-std/Test.sol";

contract TaxContract {
    error TaxContract__TaxPayerExists();
    error TaxContract__NotEnoughAmount();
    error TaxContract__NotTaxOfficeAddress();

    address public immutable i_taxOfficeAddress;
    mapping(address taxPayer => uint256 payedTaxAmount) private s_taxPayers;
    address payable[] private s_taxPayerAddresses;

    event TaxPaid(address indexed payer, uint256 amount);
    event AddNewTaxPayer(address indexed taxPayer);

    constructor() {
        i_taxOfficeAddress = msg.sender;
    }

    function addTaxPayer() external {
        for (uint256 i = 0; i < s_taxPayerAddresses.length; i++) {
            if (s_taxPayerAddresses[i] == msg.sender) {
                revert TaxContract__TaxPayerExists();
            }
        }

        s_taxPayers[msg.sender] = 0;
        s_taxPayerAddresses.push(payable(msg.sender));

        emit AddNewTaxPayer(msg.sender);
    }

    function payTax(address payable receiver) external payable {
        if (msg.value <= 0) {
            revert TaxContract__NotEnoughAmount();
        }
        console.log("msg.value", msg.value);

        uint256 taxAmount = _calculateTaxAmount(msg.value);
        console.log("taxAmount", taxAmount);

        uint256 netAmount = msg.value - taxAmount;
        console.log("netAmount", netAmount);

        receiver.transfer(netAmount);

        s_taxPayers[msg.sender] += taxAmount;
        emit TaxPaid(msg.sender, taxAmount);
    }

    modifier isOwner() {
        if (msg.sender != i_taxOfficeAddress) {
            revert TaxContract__NotTaxOfficeAddress();
        }
        _;
    }

    function withdraw() public isOwner {
        uint256 taxPayersLength = s_taxPayerAddresses.length;
        for (uint256 taxPayersIndex = 0; taxPayersIndex < taxPayersLength; taxPayersIndex++) {
            address taxPayer = s_taxPayerAddresses[taxPayersIndex];
            s_taxPayers[taxPayer] = 0;
        }
        s_taxPayerAddresses = new address payable[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function _calculateTaxAmount(uint256 amount) public pure returns (uint256) {
        return (amount * 5) / 100;
    }

    function getTaxPayersLength() external view returns (uint256) {
        return s_taxPayerAddresses.length;
    }

    function getTaxPayerByIndex(uint256 indexOfTaxPayer) external view returns (address) {
        return s_taxPayerAddresses[indexOfTaxPayer];
    }

    function getTaxPayerBalance(address taxPayer) external view returns (uint256) {
        return s_taxPayers[taxPayer];
    }

    function getTaxContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
