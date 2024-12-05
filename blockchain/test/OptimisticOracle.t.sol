// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/OptimisticOracle.sol";

contract OptimisticOracleTest is Test {
    OptimisticOracle oracle;

    function setUp() public {
        oracle = new OptimisticOracle();
    }

    function testCreateRequest() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        oracle.createRequest(task, status, deadline);

        (uint256 id, string memory createdTask, address owner, string memory createdStatus, uint256 createdDeadline, bool resolved) = oracle.requests(1);

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

        oracle.createRequest(task, initialStatus, deadline);

        oracle.updateRequest(1, updatedStatus);

        (, , , string memory currentStatus, , ) = oracle.requests(1);

        assertEq(currentStatus, updatedStatus, "Status should be updated");
    }

    function testOnlyOwnerCanUpdateRequest() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        oracle.createRequest(task, status, deadline);

        vm.prank(address(0x123)); 
        vm.expectRevert("Only owner can update");
        oracle.updateRequest(1, "Completed");
    }

    function testMarkResolved() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        oracle.createRequest(task, status, deadline);

        oracle.markResolved(1);

        (, , , , , bool resolved) = oracle.requests(1);

        assertTrue(resolved, "Request should be marked as resolved");
    }

    function testOnlyOwnerCanMarkResolved() public {
        string memory task = "Test Task";
        string memory status = "Pending";
        uint256 deadline = block.timestamp + 1 days;

        oracle.createRequest(task, status, deadline);

        vm.prank(address(0x123));
        vm.expectRevert("Only owner can resolve");
        oracle.markResolved(1);
    }
}
