// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.20;
pragma experimental ABIEncoderV2;

interface IPool {
    function coins(uint) external view returns (address);
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);
}