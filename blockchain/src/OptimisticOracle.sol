// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract OptimisticOracle {
    struct Data {
        string data;
        uint256 timestamp;
        bool finalized;
    }

    mapping(bytes32 => Data) public oracleData;
    mapping(bytes32 => uint256) public challenges;
    uint256 public challengePeriod = 1 days;

    event DataProposed(bytes32 indexed dataId, string data, uint256 timestamp);
    event DataChallenged(bytes32 indexed dataId, uint256 challengeTimestamp);
    event DataFinalized(bytes32 indexed dataId);

    // Submit data to the oracle
    function proposeData(bytes32 dataId, string calldata data) external {
        require(oracleData[dataId].timestamp == 0, "Data already proposed");

        oracleData[dataId] = Data({
            data: data,
            timestamp: block.timestamp,
            finalized: false
        });

        emit DataProposed(dataId, data, block.timestamp);
    }

    // Challenge the proposed data within the challenge period
    function challengeData(bytes32 dataId) external {
        require(oracleData[dataId].timestamp != 0, "No data to challenge");
        require(oracleData[dataId].finalized == false, "Data already finalized");
        require(block.timestamp - oracleData[dataId].timestamp < challengePeriod, "Challenge period expired");

        challenges[dataId] = block.timestamp;
        emit DataChallenged(dataId, block.timestamp);
    }

    // Finalize the data if no challenge occurs within the challenge period
    function finalizeData(bytes32 dataId) external {
        require(oracleData[dataId].timestamp != 0, "No data to finalize");
        require(oracleData[dataId].finalized == false, "Data already finalized");

        if (block.timestamp - oracleData[dataId].timestamp >= challengePeriod) {
            oracleData[dataId].finalized = true;
            emit DataFinalized(dataId);
        } else {
            revert("Challenge period still active");
        }
    }

    // Retrieve data
    function getData(bytes32 dataId) external view returns (string memory, bool) {
        return (oracleData[dataId].data, oracleData[dataId].finalized);
    }
}