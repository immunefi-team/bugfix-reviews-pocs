// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../src/AstarNetwork/AttackContract.sol";

contract AttackTest is Test {
    AttackContract attackContract;

    function setUp() public {
        vm.createSelectFork(
            "https://evm.astar.network",
            4822542
        );

        deployCodeTo(
            "AttackContract.sol:USDT",
            "",
            address(0xfFFfffFF000000000000000000000001000007C0)
        );

        attackContract = new AttackContract();
    }

    function testAttack() public {
        attackContract.initiateAttack();
    }
}

