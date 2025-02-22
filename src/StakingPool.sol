// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.28;




import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract StakingPool is Ownable{
    

    //    createStaking pool

    //    calculate reward

    //   remove assetes and gain from staking pool
    
   
    uint public totalPools;

     
  constructor() Ownable(msg.sender) {}


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

    mapping (uint=> StakPool) public stakingPools;
    mapping (address=> Staker) public stakes;

    // mordifier

   

    modifier NotOwner(){
       require(msg.sender != owner(), "Oppps Not Here!!");
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
         ) external onlyOwner{
            require(_maxAmount > 0 && _minAmount > 0 && _rewardPercentage > 0, "OOppps No Way!!");
            require(_expirationDate > block.timestamp, "Expiration date must be in the future");
            require(_maxAmount > _minAmount, "Maximum amount must be greater than minimum amount");

              ERC20 token = ERC20(_token);
              
            uint minAmountWithDecimals = _minAmount * (10 ** token.decimals());
            uint maxAmountWithDecimals = _maxAmount * (10 ** token.decimals());

            require(_token != address(0), "Nope!!!");



            totalPools++;

            stakingPools[totalPools]=StakPool({
                amountMin:minAmountWithDecimals,                           
                amountMax:maxAmountWithDecimals,
                rewardPercentage:_rewardPercentage,
                timeStamp:block.timestamp,
                tokenType: _token,
                poolExpiration:_expirationDate,
                totalAmount:0
            });

        emit PoolCreated();

    }
    
    // staking
     function stakeToPool(uint _poolID, uint _amount, address _token) external NotOwner {
    require(_poolID <= totalPools, "Oppps Staking pool not yet Created");
    require(stakingPools[_poolID].poolExpiration > block.timestamp, "Pool has expired");
    require(_amount > 0, "Oppps Not Valid!!");
    require(_amount >= stakingPools[_poolID].amountMin, "Amount is below the minimum limit");
    require(_amount <= stakingPools[_poolID].amountMax, "Amount exceeds the maximum limit");
    require(_token != address(0), "Not Accepted Here");
    
    ERC20 token = ERC20(_token);
    

    
    uint balance = token.balanceOf(msg.sender);
    require(balance >= _amount, "Sorry!! You are Broke!!");
    require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
    
    stakes[msg.sender] = Staker({
        stakedPoolID: _poolID,
        amount: _amount,
        timeStamp: block.timestamp,
        token: _token
    });
    
    stakingPools[_poolID].totalAmount += _amount;
    emit Staked();
}

    // unstaking

    function unstakeFromPool()external NotOwner{
       require(stakes[msg.sender].amount > 0, "You do not have a stake");
       require(stakingPools[stakes[msg.sender].stakedPoolID].poolExpiration < block.timestamp, "Pool is yet to expire, you can't cash out");
       
    
        StakPool memory pool = stakingPools[stakes[msg.sender].stakedPoolID];
        uint stakingDuration = block.timestamp - stakes[msg.sender].amount;
        uint reward = (stakes[msg.sender].amount * stakingPools[stakes[msg.sender].stakedPoolID].rewardPercentage * stakingDuration) / (100 * 365 days);
        
        ERC20 token = ERC20(stakes[msg.sender].token);

        require( token.balanceOf(address(this)) >= reward, "OOPSS!! We are broke at the moment");
        token.transfer(msg.sender, reward); 

         stakes[msg.sender].amount=0;
         pool.totalAmount-= reward;

         emit Unstacked();
    }

    
}
