// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Lending} from "../src/Lending.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LendingTest is Test {
    Lending public lending;

    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("Bob");

    function setUp() public {
        vm.createSelectFork("wss://arbitrum-one-rpc.publicnode.com", 335104585);
        lending = new Lending();
    }

    function test_supplyAndBorrow() public {
        deal(weth, address(this), 1e18); // deal(set balance) 1 WETH to the contract
        IERC20(weth).approve(address(lending), 1e18); // approve 1 WETH to the lending contract

        lending.supplyAndBorrow(1e18, 100e6); // supply 1 WETH and borrow 100 USDC

        assertEq(IERC20(usdc).balanceOf(address(this)), 100e6); // check if 100 USDC is received
        console.log("USDC BALANCE IS: ", IERC20(usdc).balanceOf(address(this))); // check if 100 USDC is received
    }
}
