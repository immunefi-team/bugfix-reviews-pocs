// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IAlchemixHarvester {
    error TheGasIsTooDamnHigh();
    error Unauthorized();

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetMaxGasPrice(uint256 newMaxGasPrice);
    event SetPoker(address newPoker);

    function gelatoPoker() external view returns (address);
    function harvest(address alchemist, address yieldToken, uint256 minimumAmountOut) external;
    function maxGasPrice() external view returns (uint256);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function resolver() external view returns (address);
    function setMaxGasPrice(uint256 newGasPrice) external;
    function setPoker(address newPoker) external;
    function setResolver(address _resolver) external;
    function transferOwnership(address newOwner) external;
}
