// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {StakingPool} from "../src/StakingPool.sol";

contract StakingPoolScript is Script {
    StakingPool public stakingPool;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        stakingPool = new StakingPool();

        vm.stopBroadcast();
    }
}
