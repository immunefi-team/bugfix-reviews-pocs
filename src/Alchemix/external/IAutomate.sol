// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IAutomate {
    type Module is uint8;

    struct ModuleData {
        Module[] modules;
        bytes[] args;
    }

    fallback() external;

    function cancelTask(bytes32 _taskId) external;
    function createTask(
        address _execAddress,
        bytes memory _execDataOrSelector,
        ModuleData memory _moduleData,
        address _feeToken
    ) external returns (bytes32 taskId);
    function exec(
        address _taskCreator,
        address _execAddress,
        bytes memory _execData,
        ModuleData memory _moduleData,
        uint256 _txFee,
        address _feeToken,
        bool _useTaskTreasuryFunds,
        bool _revertOnFailure
    ) external;
    function execAddresses(bytes32) external view returns (address);
    function fee() external view returns (uint256);
    function feeToken() external view returns (address);
    function gelato() external view returns (address payable);
    function getFeeDetails() external view returns (uint256, address);
    function getTaskId(
        address taskCreator,
        address execAddress,
        bytes4 execSelector,
        ModuleData memory moduleData,
        address feeToken
    ) external pure returns (bytes32 taskId);
    function getTaskId(
        address taskCreator,
        address execAddress,
        bytes4 execSelector,
        bool useTaskTreasuryFunds,
        address feeToken,
        bytes32 resolverHash
    ) external pure returns (bytes32 taskId);
    function getTaskIdsByUser(address _taskCreator) external view returns (bytes32[] memory);
    function setModule(Module[] memory _modules, address[] memory _moduleAddresses) external;
    function taskCreator(bytes32) external view returns (address);
    function taskModuleAddresses(Module) external view returns (address);
    function taskTreasury() external view returns (address);
    function timedTask(bytes32) external view returns (uint128 nextExec, uint128 interval);
    function version() external view returns (string memory);
}
