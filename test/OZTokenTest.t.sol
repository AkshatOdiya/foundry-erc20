// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {OZToken} from "../src/OZToken.sol";
import {DeployOZToken} from "../script/DeployOZToken.s.sol";

contract OZTokenTest is Test {
    OZToken public ozToken;
    DeployOZToken public deployer;

    address billionaire = makeAddr("Billionaire");
    address genius = makeAddr("Genius");
    address outsider = makeAddr("Outsider");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function setUp() public {
        deployer = new DeployOZToken();
        ozToken = deployer.run();
        vm.prank(msg.sender);
        ozToken.transfer(genius, STARTING_BALANCE);
    }

    function testBalanceAfterTransfer() public view {
        assertEq(ozToken.balanceOf(genius), STARTING_BALANCE);
    }

    function testTransferSuccess() public {
        vm.prank(genius);
        ozToken.transfer(billionaire, 20 ether);

        assertEq(ozToken.balanceOf(billionaire), 20 ether);
        assertEq(ozToken.balanceOf(genius), STARTING_BALANCE - 20 ether);
    }

    function testTransferFailsForInsufficientBalance() public {
        vm.expectRevert(); // ERC20InsufficientBalance from OZ
        vm.prank(outsider);
        ozToken.transfer(billionaire, 1 ether);
    }

    function testApproveAndAllowance() public {
        vm.prank(genius);
        ozToken.approve(billionaire, 50 ether);

        uint256 allowance = ozToken.allowance(genius, billionaire);
        assertEq(allowance, 50 ether);
    }

    function testTransferFromAfterApproval() public {
        // Genius approves billionaire
        vm.prank(genius);
        ozToken.approve(billionaire, 40 ether);

        // Billionaire transfers from genius to outsider
        vm.prank(billionaire);
        ozToken.transferFrom(genius, outsider, 40 ether);

        assertEq(ozToken.balanceOf(outsider), 40 ether);
        assertEq(ozToken.balanceOf(genius), STARTING_BALANCE - 40 ether);
        assertEq(ozToken.allowance(genius, billionaire), 0);
    }

    function testTransferFromFailsWithoutApproval() public {
        vm.expectRevert(); // ERC20InsufficientAllowance from OZ
        vm.prank(billionaire);
        ozToken.transferFrom(genius, outsider, 1 ether);
    }

    function testTransferToZeroAddressShouldRevert() public {
        vm.expectRevert(); // ERC20InvalidReceiver from OZ
        ozToken.transfer(address(0), 10 ether);
    }

    function testTransferFromZeroAddressShouldRevert() public {
        vm.expectRevert(); // ERC20InvalidSender from OZ
        ozToken.transferFrom(address(0), genius, 1 ether);
    }

    function testApproveZeroAddressShouldRevert() public {
        vm.expectRevert(); // ERC20InvalidSpender from OZ
        ozToken.approve(address(0), 1 ether);
    }

    function testEventsEmittedOnTransfer() public {
        vm.prank(genius);
        vm.expectEmit(true, true, false, true);
        emit Transfer(genius, billionaire, 1 ether);
        ozToken.transfer(billionaire, 1 ether);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
}
