// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**IERC20 是一个代币合约接口，它声明了一些基本的代币操作函数，
 * 例如 balanceOf 用于查询账户余额， 
 * transfer 用于转移代币， 
 * approve 用于授权地址可以操作代币， 
 * transferFrom 用于代币从授权的账户转移。
 */ 
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract VCTLiquidityMining {
    IERC20 public vctToken; // 声明代币合约地址

    mapping(address => uint256) public stakingBalance; // 用户质押的代币数量
    mapping(address => uint256) public lastStakeTime; // 上一次质押时间
    mapping(address => uint256) public rewards; // 用户已经获得的奖励

    uint256 public totalStaked; // 总共质押的代币数量
    uint256 public startTime; // 挖矿开始时间
    uint256 public endTime; // 挖矿结束时间
    uint256 public rewardRate; // 奖励速率
    uint256 public totalRewards; // 总共的奖励数量

    //在合约的构造函数中，我们初始化了奖励代币合约地址（_vctToken）、挖矿开始时间和结束时间（_startTime 和 _endTime）、奖励速率（_rewardRate）和总奖励数量（_totalRewards）
    constructor(IERC20 _vctToken, uint256 _startTime, uint256 _endTime, uint256 _rewardRate, uint256 _totalRewards) {
        vctToken = _vctToken;
        startTime = _startTime;
        endTime = _endTime;
        rewardRate = _rewardRate;
        totalRewards = _totalRewards;
    }

    /**
     * stake 函数允许用户将代币质押到合约中，并计算用户当前可以获得的奖励数量。如果代币质押成功，则更新用户的质押代币数量、总共质押的代币数量和上一次质押时间
     */
    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(block.timestamp >= startTime && block.timestamp < endTime, "Staking is not available");
        require(vctToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        uint256 currentReward = calculateReward(msg.sender);
        rewards[msg.sender] += currentReward;
        stakingBalance[msg.sender] += amount;
        totalStaked += amount;
        lastStakeTime[msg.sender] = block.timestamp;
    }

    /**
     * withdraw 函数允许用户撤回质押的代币，并将奖励一并领取。如果代币撤回成功，则更新用户的质押代币数量和总共质押的代币数量
     */
    function withdraw() public {
        require(stakingBalance[msg.sender] > 0, "No staked balance");

        uint256 currentReward = calculateReward(msg.sender);
        rewards[msg.sender] += currentReward;

        uint256 amount = stakingBalance[msg.sender];
        stakingBalance[msg.sender] = 0;
        totalStaked -= amount;

        require(vctToken.transfer(msg.sender, amount), "Transfer failed");
    }

    /**
     * claimReward 函数允许用户单独领取已经产生的奖励。该函数将计算用户当前可以获得的奖励数量，并将奖励代币发送给用户
     */
    function claimReward() public {
        uint256 currentReward = calculateReward(msg.sender);
        rewards[msg.sender] += currentReward;

        require(vctToken.transfer(msg.sender, currentReward), "Transfer failed");
    }

    /**
     * calculateReward 函数用于计算用户当前可以获得的奖励数量，根据用户质押的代币数量、距离上一次质押时间和奖励速率来计算
     */
    function calculateReward(address user) public view returns (uint256) {
        uint256 stakedAmount = stakingBalance[user];
        uint256 timeDelta = block.timestamp - lastStakeTime[user];
        uint256 reward = stakedAmount * rewardRate * timeDelta / (365 days);

        return reward;
    }
}
