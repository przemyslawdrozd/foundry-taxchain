// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TaxContract} from "../src/TaxContract.sol";

contract DeployTaxContract is Script {
    function run() external returns (TaxContract) {
        vm.startBroadcast();
        TaxContract taxContract = new TaxContract();
        vm.stopBroadcast();
        return taxContract;
    }
}
