// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../src/DFXFinance/AttackContract.sol";

contract AttackTest is Test {
    AttackContract attackContract;

    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/polygon", 42064500);

        attackContract = new AttackContract();
    }

    function testAttack() public {
        attackContract.initiateAttack();
    }
}

