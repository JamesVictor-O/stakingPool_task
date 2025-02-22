// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {StakingPool} from "../src/StakingPool.sol";

contract CounterScript is Script {
    StakingPool public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new StakingPool();

        vm.stopBroadcast();
    }
}
