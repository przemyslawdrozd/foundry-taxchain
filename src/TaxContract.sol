// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract TaxContract {
    error TaxContract__TaxPayerExists();

    address public taxOfficeAddress;
    mapping(address taxPayer => uint256 payedTaxAmount) private s_taxPayers;
    address[] private s_taxPayerKeys;

    event TaxPaid(address indexed payer, uint256 amount);
    event AddNewTaxPayer(address indexed taxPayer);

    constructor(address _taxOfficeAddress) {
        taxOfficeAddress = _taxOfficeAddress;
    }

    function addTaxPayer() external {
        for (uint256 i = 0; i < s_taxPayerKeys.length; i++) {
            if (s_taxPayerKeys[i] == msg.sender) {
                revert TaxContract__TaxPayerExists();
            }
        }

        s_taxPayers[msg.sender] = 0;
        s_taxPayerKeys.push(msg.sender);

        emit AddNewTaxPayer(msg.sender);
    }

    function payTax(uint256 amount, address payable receiver) external payable {
        require(msg.value > 0, "Amount must be greater than 0");

        uint256 taxAmount = (msg.value * 5) / 100;
        // Calculate the net amount to be transferred to the receiver
        uint256 netAmount = amount - taxAmount;

        // Transfer the net amount to the receiver
        receiver.transfer(netAmount);

        // Transfer the tax amount to the contract itself
        payable(address(this)).transfer(taxAmount);

        s_taxPayers[msg.sender] += taxAmount;
        payable(taxOfficeAddress).transfer(taxAmount);

        // Emit an event for the tax payment
        emit TaxPaid(msg.sender, taxAmount);
    }

    function getTaxPayersLength() external view returns (uint256) {
        return s_taxPayerKeys.length;
    }

    function getTaxBalance(address taxpayer) external view returns (uint256) {
        return s_taxPayers[taxpayer];
    }

    function getTaxContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
