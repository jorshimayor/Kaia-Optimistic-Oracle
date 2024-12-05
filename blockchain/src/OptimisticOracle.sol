// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OptimisticOracle {
    struct Request {
        uint256 id;
        string task;
        address owner;
        string status;
        uint256 deadline;
        bool resolved;
    }

    uint256 public requestCounter;
    mapping(uint256 => Request) public requests;

    event RequestCreated(uint256 id, string task, address owner, string status, uint256 deadline);
    event RequestUpdated(uint256 id, string status);

    function createRequest(
        string memory task,
        string memory status,
        uint256 deadline
    ) external {
        requestCounter++;
        requests[requestCounter] = Request({
            id: requestCounter,
            task: task,
            owner: msg.sender,
            status: status,
            deadline: deadline,
            resolved: false
        });

        emit RequestCreated(requestCounter, task, msg.sender, status, deadline);
    }

    function updateRequest(
        uint256 id,
        string memory status
    ) external {
        Request storage request = requests[id];
        require(msg.sender == request.owner, "Only owner can update");
        require(!request.resolved, "Request already resolved");

        request.status = status;

        emit RequestUpdated(id, status);
    }

    function markResolved(uint256 id) external {
        Request storage request = requests[id];
        require(msg.sender == request.owner, "Only owner can resolve");
        request.resolved = true;
    }
}
