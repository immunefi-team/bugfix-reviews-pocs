pragma solidity ^0.8.10;

interface AlchemistV2 {
    event AddUnderlyingToken(address indexed underlyingToken);
    event AddYieldToken(address indexed yieldToken);
    event AdminUpdated(address admin);
    event ApproveMint(address indexed owner, address indexed spender, uint256 amount);
    event ApproveWithdraw(address indexed owner, address indexed spender, address indexed yieldToken, uint256 amount);
    event Burn(address indexed sender, uint256 amount, address recipient);
    event CreditUnlockRateUpdated(address yieldToken, uint256 blocks);
    event Deposit(address indexed sender, address indexed yieldToken, uint256 amount, address recipient);
    event Donate(address indexed sender, address indexed yieldToken, uint256 amount);
    event Harvest(address indexed yieldToken, uint256 minimumAmountOut, uint256 totalHarvested, uint256 credit);
    event Initialized(uint8 version);
    event KeeperSet(address sentinel, bool flag);
    event Liquidate(
        address indexed owner,
        address indexed yieldToken,
        address indexed underlyingToken,
        uint256 shares,
        uint256 credit
    );
    event LiquidationLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);
    event MaximumExpectedValueUpdated(address indexed yieldToken, uint256 maximumExpectedValue);
    event MaximumLossUpdated(address indexed yieldToken, uint256 maximumLoss);
    event MinimumCollateralizationUpdated(uint256 minimumCollateralization);
    event Mint(address indexed owner, uint256 amount, address recipient);
    event MintingLimitUpdated(uint256 maximum, uint256 blocks);
    event PendingAdminUpdated(address pendingAdmin);
    event ProtocolFeeReceiverUpdated(address protocolFeeReceiver);
    event ProtocolFeeUpdated(uint256 protocolFee);
    event Repay(
        address indexed sender, address indexed underlyingToken, uint256 amount, address recipient, uint256 credit
    );
    event RepayLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);
    event SentinelSet(address sentinel, bool flag);
    event Snap(address indexed yieldToken, uint256 expectedValue);
    event SweepRewardTokens(address indexed rewardToken, uint256 amount);
    event SweepTokens(address indexed token, uint256 amount);
    event TokenAdapterUpdated(address yieldToken, address tokenAdapter);
    event TransmuterUpdated(address transmuter);
    event UnderlyingTokenEnabled(address indexed underlyingToken, bool enabled);
    event Withdraw(address indexed owner, address indexed yieldToken, uint256 shares, address recipient);
    event YieldTokenEnabled(address indexed yieldToken, bool enabled);

    struct InitializationParams {
        address admin;
        address debtToken;
        address transmuter;
        uint256 minimumCollateralization;
        uint256 protocolFee;
        address protocolFeeReceiver;
        uint256 mintingLimitMinimum;
        uint256 mintingLimitMaximum;
        uint256 mintingLimitBlocks;
        address whitelist;
    }

    struct UnderlyingTokenConfig {
        uint256 repayLimitMinimum;
        uint256 repayLimitMaximum;
        uint256 repayLimitBlocks;
        uint256 liquidationLimitMinimum;
        uint256 liquidationLimitMaximum;
        uint256 liquidationLimitBlocks;
    }

    struct YieldTokenConfig {
        address adapter;
        uint256 maximumLoss;
        uint256 maximumExpectedValue;
        uint256 creditUnlockBlocks;
    }

    struct UnderlyingTokenParams {
        uint8 decimals;
        uint256 conversionFactor;
        bool enabled;
    }

    struct YieldTokenParams {
        uint8 decimals;
        address underlyingToken;
        address adapter;
        uint256 maximumLoss;
        uint256 maximumExpectedValue;
        uint256 creditUnlockRate;
        uint256 activeBalance;
        uint256 harvestableBalance;
        uint256 totalShares;
        uint256 expectedValue;
        uint256 pendingCredit;
        uint256 distributedCredit;
        uint256 lastDistributionBlock;
        uint256 accruedWeight;
        bool enabled;
    }

    function BPS() external view returns (uint256);
    function FIXED_POINT_SCALAR() external view returns (uint256);
    function acceptAdmin() external;
    function accounts(address owner) external view returns (int256 debt, address[] memory depositedTokens);
    function addUnderlyingToken(address underlyingToken, UnderlyingTokenConfig memory config) external;
    function addYieldToken(address yieldToken, YieldTokenConfig memory config) external;
    function admin() external view returns (address);
    function approveMint(address spender, uint256 amount) external;
    function approveWithdraw(address spender, address yieldToken, uint256 shares) external;
    function burn(uint256 amount, address recipient) external returns (uint256);
    function configureCreditUnlockRate(address yieldToken, uint256 blocks) external;
    function configureLiquidationLimit(address underlyingToken, uint256 maximum, uint256 blocks) external;
    function configureMintingLimit(uint256 maximum, uint256 rate) external;
    function configureRepayLimit(address underlyingToken, uint256 maximum, uint256 blocks) external;
    function convertSharesToUnderlyingTokens(address yieldToken, uint256 shares) external view returns (uint256);
    function convertSharesToYieldTokens(address yieldToken, uint256 shares) external view returns (uint256);
    function convertUnderlyingTokensToShares(address yieldToken, uint256 amount) external view returns (uint256);
    function convertUnderlyingTokensToYield(address yieldToken, uint256 amount) external view returns (uint256);
    function convertYieldTokensToShares(address yieldToken, uint256 amount) external view returns (uint256);
    function convertYieldTokensToUnderlying(address yieldToken, uint256 amount) external view returns (uint256);
    function debtToken() external view returns (address);
    function deposit(address yieldToken, uint256 amount, address recipient) external returns (uint256);
    function depositUnderlying(address yieldToken, uint256 amount, address recipient, uint256 minimumAmountOut)
        external
        returns (uint256);
    function donate(address yieldToken, uint256 amount) external;
    function getLiquidationLimitInfo(address underlyingToken)
        external
        view
        returns (uint256 currentLimit, uint256 rate, uint256 maximum);
    function getMintLimitInfo() external view returns (uint256 currentLimit, uint256 rate, uint256 maximum);
    function getRepayLimitInfo(address underlyingToken)
        external
        view
        returns (uint256 currentLimit, uint256 rate, uint256 maximum);
    function getSupportedUnderlyingTokens() external view returns (address[] memory);
    function getSupportedYieldTokens() external view returns (address[] memory);
    function getUnderlyingTokenParameters(address underlyingToken)
        external
        view
        returns (UnderlyingTokenParams memory);
    function getUnderlyingTokensPerShare(address yieldToken) external view returns (uint256);
    function getYieldTokenParameters(address yieldToken) external view returns (YieldTokenParams memory);
    function getYieldTokensPerShare(address yieldToken) external view returns (uint256);
    function harvest(address yieldToken, uint256 minimumAmountOut) external;
    function initialize(InitializationParams memory params) external;
    function isSupportedUnderlyingToken(address underlyingToken) external view returns (bool);
    function isSupportedYieldToken(address yieldToken) external view returns (bool);
    function keepers(address) external view returns (bool);
    function liquidate(address yieldToken, uint256 shares, uint256 minimumAmountOut) external returns (uint256);
    function minimumCollateralization() external view returns (uint256);
    function mint(uint256 amount, address recipient) external;
    function mintAllowance(address owner, address spender) external view returns (uint256);
    function mintFrom(address owner, uint256 amount, address recipient) external;
    function multicall(bytes[] memory data) external payable returns (bytes[] memory results);
    function normalizeDebtTokensToUnderlying(address underlyingToken, uint256 amount) external view returns (uint256);
    function normalizeUnderlyingTokensToDebt(address underlyingToken, uint256 amount) external view returns (uint256);
    function pendingAdmin() external view returns (address);
    function poke(address owner) external;
    function positions(address owner, address yieldToken)
        external
        view
        returns (uint256 shares, uint256 lastAccruedWeight);
    function protocolFee() external view returns (uint256);
    function protocolFeeReceiver() external view returns (address);
    function repay(address underlyingToken, uint256 amount, address recipient) external returns (uint256);
    function sentinels(address) external view returns (bool);
    function setKeeper(address keeper, bool flag) external;
    function setMaximumExpectedValue(address yieldToken, uint256 value) external;
    function setMaximumLoss(address yieldToken, uint256 value) external;
    function setMinimumCollateralization(uint256 value) external;
    function setPendingAdmin(address value) external;
    function setProtocolFee(uint256 value) external;
    function setProtocolFeeReceiver(address value) external;
    function setSentinel(address sentinel, bool flag) external;
    function setTokenAdapter(address yieldToken, address adapter) external;
    function setTransferAdapterAddress(address transferAdapterAddress) external;
    function setTransmuter(address value) external;
    function setUnderlyingTokenEnabled(address underlyingToken, bool enabled) external;
    function setYieldTokenEnabled(address yieldToken, bool enabled) external;
    function snap(address yieldToken) external;
    function sweepRewardTokens(address rewardToken, address yieldToken) external;
    function totalValue(address owner) external view returns (uint256);
    function transferAdapter() external view returns (address);
    function transferDebtV1(address owner, int256 debt) external;
    function transmuter() external view returns (address);
    function version() external view returns (string memory);
    function whitelist() external view returns (address);
    function withdraw(address yieldToken, uint256 shares, address recipient) external returns (uint256);
    function withdrawAllowance(address owner, address spender, address yieldToken) external view returns (uint256);
    function withdrawFrom(address owner, address yieldToken, uint256 shares, address recipient)
        external
        returns (uint256);
    function withdrawUnderlying(address yieldToken, uint256 shares, address recipient, uint256 minimumAmountOut)
        external
        returns (uint256);
    function withdrawUnderlyingFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256);
}
