// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/OptimisticOracle.sol";

contract OptimisticOracleTest is Test {
    OptimisticOracle oracle;

    function setUp() public {
        oracle = new OptimisticOracle();
    }

    function testProposeData() public {
        bytes32 dataId = keccak256(abi.encodePacked("data1"));
        oracle.proposeData(dataId, "Data 1");

        (string memory data, bool finalized) = oracle.getData(dataId);
        assertEq(data, "Data 1");
        assertEq(finalized, false);
    }

    function testChallengeData() public {
        bytes32 dataId = keccak256(abi.encodePacked("data1"));
        oracle.proposeData(dataId, "Data 1");

        oracle.challengeData(dataId);

        // Validate challenge
        uint256 challengeTime = oracle.challenges(dataId);
        assertTrue(challengeTime > 0);
    }

    function testFinalizeData() public {
        bytes32 dataId = keccak256(abi.encodePacked("data1"));
        oracle.proposeData(dataId, "Data 1");

        // Fast forward time to simulate challenge period expiry
        vm.warp(block.timestamp + 2 days);

        oracle.finalizeData(dataId);
        (string memory data, bool finalized) = oracle.getData(dataId);
        assertEq(data, "Data 1");
        assertEq(finalized, true);
    }
}
