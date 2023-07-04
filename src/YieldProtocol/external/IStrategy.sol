// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

interface IStrategy {
    enum State {DEPLOYED, DIVESTED, INVESTED, EJECTED, DRAINED}

    function state() external view returns(State);                          // The state determines which functions are available
    function base() external view returns(address);                          // Base token for this strategy (inherited from StrategyMigrator)
    function fyToken() external view returns(address);                     // Current fyToken for this strategy (inherited from StrategyMigrator)
    function pool() external view returns(address);                           // Current pool that this strategy invests in
    function cached() external view returns(uint256);                       // Base tokens owned by the strategy after the last operation
    function fyTokenCached() external view returns(uint256);                // In emergencies, the strategy can keep fyToken of one series

    /// @dev Mint the first strategy tokens, without investing
    function init(address to)
        external
        returns (uint256 baseIn, uint256 fyTokenIn, uint256 minted);

    /// @dev Start the strategy investments in the next pool
    /// @notice When calling this function for the first pool, some underlying needs to be transferred to the strategy first, using a batchable router.
    function invest(address pool_)
        external
        returns (uint256 poolTokensObtained);


    /// @dev Divest out of a pool once it has matured
    function divest()
        external
        returns (uint256 baseObtained);

    /// @dev Divest out of a pool at any time. If possible the pool tokens will be burnt for base and fyToken, the latter of which
    /// must be sold to return the strategy to a functional state. If the pool token burn reverts, the pool tokens will be transferred
    /// to the caller as a last resort.
    /// @notice The caller must take care of slippage when selling fyToken, if relevant.
    function eject()
        external
        returns (uint256 baseObtained, uint256 fyTokenObtained);

    /// @dev Buy ejected fyToken in the strategy at face value
    /// @param fyTokenTo Address to send the purchased fyToken to.
    /// @param baseTo Address to send any remaining base to.
    /// @return soldFYToken Amount of fyToken sold.
    /// @return returnedBase Amount of base unused and returned.
    function buyFYToken(address fyTokenTo, address baseTo)
        external
        returns (uint256 soldFYToken, uint256 returnedBase);

    /// @dev If we ejected the pool tokens, we can recapitalize the strategy to avoid a forced migration
    function restart()
        external
        returns (uint256 baseIn);

    /// @dev Mint strategy tokens with pool tokens. It can be called only when invested.
    /// @notice The pool tokens that the user contributes need to have been transferred previously, using a batchable router.
    function mint(address to)
        external
        returns (uint256 minted);

    /// @dev Burn strategy tokens to withdraw pool tokens. It can be called only when invested.
    /// @notice The strategy tokens that the user burns need to have been transferred previously, using a batchable router.
    function burn(address to)
        external
        returns (uint256 poolTokensObtained);

    /// @dev Mint strategy tokens with base tokens. It can be called only when not invested and not ejected.
    /// @notice The base tokens that the user invests need to have been transferred previously, using a batchable router.
    function mintDivested(address to)
        external
        returns (uint256 minted);

    /// @dev Burn strategy tokens to withdraw base tokens. It can be called when not invested and not ejected.
    /// @notice The strategy tokens that the user burns need to have been transferred previously, using a batchable router.
    function burnDivested(address baseTo)
        external
        returns (uint256 baseObtained);

    /// @dev Token used as rewards
    function rewardsToken() external view returns(address);

    /// @dev Rewards schedule
    function rewardsPeriod() external view returns(uint32 start, uint32 end);

    /// @dev Rewards per token
    function rewardsPerToken() external view returns(uint128 accumulated, uint32 lastUpdated, uint96 rate);

    /// @dev Rewards accumulated by users
    function rewards(address user) external view returns(uint128 accumulatedUserStart, uint128 accumulatedCheckpoint);

    /// @dev Set the rewards token
    function setRewardsToken(address rewardsToken_)
        external;

    /// @dev Set a rewards schedule
    function setRewards(uint32 start, uint32 end, uint96 rate)
        external;

    /// @dev Claim all rewards from caller into a given address
    function claim(address to)
        external
        returns (uint256 claiming);

    /// @dev Trigger a claim for any user
    function remit(address user)
        external
        returns (uint256 claiming);
}