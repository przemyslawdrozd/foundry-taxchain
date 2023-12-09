// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract TaxContract {
    address public taxOfficeAddress;
    mapping(address => uint256) public taxPayers;

    event TaxPaid(address indexed payer, uint256 amount);

    constructor(address _taxOfficeAddress) {
        taxOfficeAddress = _taxOfficeAddress;
    }

    function payTax() external payable {
        require(msg.value > 0, "Amount must be greater than 0");

        uint256 taxAmount = (msg.value * 5) / 100;
        uint256 remainingAmount = msg.value - taxAmount;

        taxPayers[msg.sender] += remainingAmount;
        payable(taxOfficeAddress).transfer(taxAmount);

        emit TaxPaid(msg.sender, remainingAmount);
    }

    function getTaxBalance(address taxpayer) external view returns (uint256) {
        return taxPayers[taxpayer];
    }

    function getTaxContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
