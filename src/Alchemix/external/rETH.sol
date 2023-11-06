pragma solidity ^0.8.10;

interface RocketTokenRETH {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event EtherDeposited(address indexed from, uint256 amount, uint256 time);
    event TokensBurned(address indexed from, uint256 amount, uint256 ethAmount, uint256 time);
    event TokensMinted(address indexed to, uint256 amount, uint256 ethAmount, uint256 time);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 _rethAmount) external;
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function depositExcess() external payable;
    function depositExcessCollateral() external;
    function getCollateralRate() external view returns (uint256);
    function getEthValue(uint256 _rethAmount) external view returns (uint256);
    function getExchangeRate() external view returns (uint256);
    function getRethValue(uint256 _ethAmount) external view returns (uint256);
    function getTotalCollateral() external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function mint(uint256 _ethAmount, address _to) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function version() external view returns (uint8);
}
