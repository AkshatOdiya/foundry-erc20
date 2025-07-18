// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OZToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OZT", "1One") {
        _mint(msg.sender, initialSupply);
    }
}
