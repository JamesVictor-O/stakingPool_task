// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {StakingPool} from "../src/StakingPool.sol";

contract CounterTest is Test {
    StakingPool public counter;

    function setUp() public {
        counter = new StakingPool();
    }

}
