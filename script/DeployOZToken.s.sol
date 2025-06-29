// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {OZToken} from "../src/OZToken.sol";

contract DeployOZToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (OZToken) {
        vm.startBroadcast();
        OZToken ozToken = new OZToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return ozToken;
    }
}
