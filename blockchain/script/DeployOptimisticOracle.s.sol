// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/OptimisticOracle.sol";

contract DeployOptimisticOracle is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the OptimisticOracle contract
        OptimisticOracle oracle = new OptimisticOracle();

        console.log("OptimisticOracle deployed to:", address(oracle));

        vm.stopBroadcast();
    }
}