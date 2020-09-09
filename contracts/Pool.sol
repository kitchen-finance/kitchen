pragma solidity =0.5.4;

import "SafeMath.sol";
import "ITRC20.sol";
import "remedy.sol";

contract Pool is AdminRemedy {
    using SafeMath for uint256;

    ITRC20 public lptokenContract;
    ITRC20 public liquorContract = ITRC20(0x41686BE6A3F355A670104EF0DBAE00A90A03FE5288); // TKVLY6e6VVKhnHSXJwuwn54vvmL6KLi6V4

    uint256 private _totalSupply = 0;                               // current total supply
    mapping(address => uint256) private _balances;                  // user's balance
    mapping(address => uint256) public userDebt;                    // user's debt
    mapping(address => uint256) private paidReward;                 // user earned and harvested

    uint256 public startTime;
    uint256 public period;
    uint256 public totalPeriod;
    uint256 public decimals;
    uint256 public rewardPerPeriod;                                 // reward of some period
    uint256 public accRewardPerUnit;                                // acc reward
    uint256 public lastRewardPeriod;                                // last reward period
    bool public transferNoReturn;

    constructor(address contractAddr, uint256 _rewardPerPeriod, bool _transferNoReturn, uint256 _startTime, uint256 _decimals, uint256 _period, uint256 _totalPeriod) public {
        accRewardPerUnit = 0;
        lptokenContract = ITRC20(contractAddr);
        rewardPerPeriod = _rewardPerPeriod;
        transferNoReturn = _transferNoReturn;
        startTime = _startTime;
        decimals = _decimals;
        period = _period;
        totalPeriod = _totalPeriod;
    }

    function updateRewardPerPeriod(uint256 _rewardPerPeriod) external onlyOwner returns (bool) {
        rewardPerPeriod = _rewardPerPeriod;
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function paidRewardOf(address account) public view returns (uint256) {
        return paidReward[account];
    }

    function getUserEarned(address account) public view returns (uint256) {
        uint256 lastP = currentPeriod();
        if(balanceOf(account) == 0 || lastP == 0) {
            return 0;
        }
        uint256 periods = lastP - lastRewardPeriod;
        uint256 reward = periods.mul(rewardPerPeriod);
        uint256 perReward = accRewardPerUnit.add(reward.mul(decimals).div(_totalSupply));
        uint256 debt = userDebt[account];
        uint256 balance = balanceOf(account);
        return balance.mul(perReward).div(decimals).sub(debt);
    }

    function rewardOf(address account) public view returns (uint256) {
        return paidRewardOf(account).add(getUserEarned(account));
    }

    function stake(uint256 amount) public returns (bool) {
        address user = msg.sender;
        
        if (balanceOf(user) > 0) {
            harvest();   
        }

        _totalSupply = _totalSupply.add(amount);
        _balances[user] = _balances[user].add(amount);
        require(lptokenContract.transferFrom(user, address(this), amount), "stake failed");

        return updateUserDebt();
    }

    function withdraw(uint256 amount) public returns (bool) {
        harvest();

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        if (transferNoReturn && lptokenContract.balanceOf(address(this)) >= amount) {
            lptokenContract.transfer(msg.sender, amount);
        } else {
            require(lptokenContract.transfer(msg.sender, amount), "withdraw failed");
        }

        return updateUserDebt();
    }

    function updateUserDebt() private returns (bool) {
        updatePool();
        userDebt[msg.sender] = balanceOf(msg.sender).mul(accRewardPerUnit).div(decimals);
        return true;
    }

    function harvest() public returns (bool) {
        updatePool();
        uint256 reward = getUserEarned(msg.sender);
        require(liquorContract.transfer(msg.sender, reward), "harvest failed");
        paidReward[msg.sender] = paidReward[msg.sender].add(reward);
        return updateUserDebt();
    }

    function exit() public returns (bool) {
        uint256 amount = balanceOf(msg.sender);
        withdraw(amount);
        return true;
    }

    function currentPeriod() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return 0;
        }
        uint256 time = block.timestamp - startTime;
        uint256 mod = time % period;
        time = time - mod;
        uint256 _period = time / period;
        if (_period > totalPeriod) {
            _period = totalPeriod;
        }
        return _period;
    }

    function updatePool() private returns (bool) {
        if (_totalSupply == 0 || block.timestamp <= startTime) {
            return false;
        }
        uint256 lastP = currentPeriod();
        uint256 periods = lastP - lastRewardPeriod;
        uint256 reward = periods.mul(rewardPerPeriod);
        accRewardPerUnit = accRewardPerUnit.add(reward.mul(decimals).div(_totalSupply));
        lastRewardPeriod = lastP;
        return true;
    }
}
