// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {StakingPool} from "../src/StakingPool.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MCK") {
        _mint(msg.sender, 1_000_000 * 10**18);
    }
       function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract CounterTest is Test {
    StakingPool public stakingPool;
    MockERC20 token;
    address user=address(1);
    address owner=address(2);

    function setUp() public {
        stakingPool = new StakingPool();
        token = new MockERC20();
       
       vm.prank(owner);

        
          stakingPool.transferOwnership(owner);
    }

    function test_CreatePool_Success() public {
        vm.prank(owner);

        stakingPool.createPool(
            1 , 
            10 ,
             10, 
             address(token), 
             block.timestamp +1 days
        );

        (, uint maxAmount, , , , ,)=stakingPool.stakingPools(1);

        uint totalPools=stakingPool.totalPools();
      
         assertEq(maxAmount, 10 ether, "Max amount should be 10 ether");
         assertEq(totalPools, 1, "Total number of pools should be one");
    }

    function test_CreatePool_Fail_NotOwner() public {
  
        // address nonOwner = address(0x123); 
        vm.prank(user);

        vm.expectRevert(
                abi.encodeWithSelector(
                    bytes4(keccak256("OwnableUnauthorizedAccount(address)")),
                    user
                )
            );

        
        stakingPool.createPool(
            1 ether, 10 ether, 10, address(token), block.timestamp + 1 days
        );
}

    function test_stake_toPool()public {
         vm.prank(owner);

        stakingPool.createPool(
            1 , 
            3 ,
            10, 
            address(token), 
            block.timestamp +1 days
        );

        (uint minAmount , , , , , ,) = stakingPool.stakingPools(1);
        assertEq(minAmount, 1 ether, "Pool min amount should match");
        
       
        vm.prank(user);
        
         uint256 amount = 10 * (10 ** token.decimals()); 
        token.mint(user, amount);
        assertEq(token.balanceOf(user), amount, "User should have correct token balance");

          uint256 stakeAmount = 3 * (10 ** token.decimals());
          token.approve(address(stakingPool), stakeAmount);
         assertEq(token.allowance(user, address(stakingPool)), stakeAmount, "Approval should be set");

        stakingPool.stakeToPool(1,3 * (10 ** token.decimals()), address(token));
        (uint stakedPoolID , , ,  )=stakingPool.stakes(user);
         assertEq(stakedPoolID, 1, "Staked pool ID should be 1");
    }

}
