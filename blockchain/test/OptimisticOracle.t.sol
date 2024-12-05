// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/OptimisticOracle.sol";

contract OptimisticOracleTest is Test {
    OptimisticOracle oracle;

    function setUp() public {
        // Deploy the OptimisticOracle contract
        oracle = new OptimisticOracle();
    }

    function testCreateRequest() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        // Create a new request
        oracle.createRequest(task, status, deadline);

        // Fetch the created request
        (uint256 id, string memory createdTask, address owner, string memory createdStatus, uint256 createdDeadline, bool resolved) = oracle.requests(1);

        // Assertions
        assertEq(id, 1, "Request ID should be 1");
        assertEq(createdTask, task, "Task should match");
        assertEq(owner, address(this), "Owner should match");
        assertEq(createdStatus, status, "Status should match");
        assertEq(createdDeadline, deadline, "Deadline should match");
        assertFalse(resolved, "Request should not be resolved initially");
    }

    function testUpdateRequest() public {
        string memory task = "Test Task";
        string memory initialStatus = "Pending";
        string memory updatedStatus = "Completed";
        uint256 deadline = block.timestamp + 1 days;

        // Create a new request
        oracle.createRequest(task, initialStatus, deadline);

        // Update the request's status
        oracle.updateRequest(1, updatedStatus);

        // Fetch the updated request
        (, , , string memory currentStatus, , ) = oracle.requests(1);

        // Assertions
        assertEq(currentStatus, updatedStatus, "Status should be updated");
    }

    function testOnlyOwnerCanUpdateRequest() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        // Create a new request
        oracle.createRequest(task, status, deadline);

        // Attempt to update the request from a different account
        vm.prank(address(0x123)); // Simulate a call from another address
        vm.expectRevert("Only owner can update");
        oracle.updateRequest(1, "Completed");
    }

    function testMarkResolved() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        // Create a new request
        oracle.createRequest(task, status, deadline);

        // Mark the request as resolved
        oracle.markResolved(1);

        // Fetch the resolved request
        (, , , , , bool resolved) = oracle.requests(1);

        // Assertions
        assertTrue(resolved, "Request should be marked as resolved");
    }

    function testOnlyOwnerCanMarkResolved() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        // Create a new request
        oracle.createRequest(task, status, deadline);

        // Attempt to mark resolved from a different account
        vm.prank(address(0x123)); // Simulate a call from another address
        vm.expectRevert("Only owner can resolve");
        oracle.markResolved(1);
    }
}
