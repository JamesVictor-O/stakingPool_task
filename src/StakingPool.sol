// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.26;


// staking pool
// owner should be able to create different staking pool
// this staking pools can receive one special token
// when creating the staking pool the creatore should include the duration and profit


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";




contract StakingPool {
    

    //    createStaking pool

    //    calculate reward

    //   remove assetes and gain from staking pool
    
    address public owner;
    uint totalPools;

     

    constructor(){
       owner=msg.sender;
    }

    // struct 

    struct StakPool{
        uint amountMin;
        uint amountMax;
        uint rewardPercentage;
        uint timeStamp;
        address tokenType;
        uint poolExpiration;
        uint totalAmount;
    }
    struct Staker{
        uint stakedPoolID;
        uint amount;
        uint timeStamp;
        address token;
    }

    mapping (uint=> StakPool) stakingPools;
    mapping (address=> Staker) public stakes;

    // mordifier

    modifier OnlyOwner(){
        require(msg.sender == owner, "Ooopps, OnlyOwner");
        _;
    }

    modifier NotOwner(){
       require(msg.sender != owner, "Oppps Not Here!!");
       _;
    }

    // events

    event PoolCreated();
    event Staked();
    event Unstacked();
  
    //   pool creation
    function createPool(
        uint _minAmount, 
        uint _maxAmount, 
        uint _rewardPercentage,
        address _token,
        uint _expirationDate
         ) external OnlyOwner returns(bool){
            require(_maxAmount > 0 && _minAmount > 0 && _rewardPercentage > 0, "OOppps No Way!!");
            require(_expirationDate > block.timestamp, "Expiration date must be in the future");
            require(_maxAmount > _minAmount, "Maximum amount must be greater than minimum amount");

              IERC20 token = IERC20(_token);
            uint minAmountWithDecimals = _minAmount * (10 ** token.decimals());
            uint maxAmountWithDecimals = _maxAmount * (10 ** token.decimals());

            require(_token != address(0), "Nope!!!");



            totalPools++;
            stakingPools[totalPools]=StakPool({
                amountMin:_minAmount,                           
                amountMax:_maxAmount,
                rewardPercentage:_rewardPercentage,
                timeStamp:block.timestamp,
                tokenType: _token,
                poolExpiration:_expirationDate,
                totalAmount:0
            });

        emit PoolCreated();

    }
    
    // staking
    function stakeToPool(uint _poolID, uint _amount, address _token ) external NotOwner {
        require(_poolID <= totalPools, "Oppps Staking pool not yet Created");
         require(stakingPools[_poolID].poolExpiration > block.timestamp, "Pool has expired");
        require(_amount >0, "Oppps Not Valid!!" );
         require(_amount >= stakingPools[_poolID].amountMin, "Amount is below the minimum limit");
        require(_amount <= stakingPools[_poolID].amountMax, "Amount exceeds the maximum limit");
        require(_token != address(0), "Not Accepted Here");
       IERC20 token = IERC20(_token);

       uint amountWithDecimals = _amount * (10 ** token.decimals());
       uint balance=  token.balanceOf(msg.sender);

       

        require(balance >= amountWithDecimals, "Sorry!! You are Broke!!");

        token.transferFrom(msg.sender, address(this), amountWithDecimals);

        


        stakes[msg.sender]=Staker({
          stakedPoolID: _poolID,
          amount:_amount,
          timeStamp:block.timestamp,
          token:_token
        });

        stakingPools[_poolID].totalAmount += _amount;
         
         emit Staked();

    }

    // unstaking

    function unstakeFromPool()external NotOwner{
       require(stakes[msg.sender] > 0, "You do not have a stake");
       require(stakingPools[stakes[msg.sender].stakedPoolID].poolExpiration < block.timestamp, "Pool is yet to expire, you can't cash out");
       
    
        StakPool memory pool = stakingPools[stakes[msg.sender].stakedPoolID];
        uint stakingDuration = block.timestamp - stakes[msg.sender].amount;
        uint reward = (stakes[msg.sender].amount * stakingPools[stakes[msg.sender].stakedPoolID].rewardPercentage * stakingDuration) / (100 * 365 days);
        
        IERC20 token = IERC20(stakes[msg.sender].token);

        require( token.balanceOf(address(this)) >= reward, "OOPSS!! We are broke at the moment");
        token.transfer(msg.sender, reward); 

         stakes[msg.sender].amount=0;

         stakingPools[stakes[msg.sender].stakedPoolID].totalAmount -= reward;

         emit Unstacked();
    }

    
}
