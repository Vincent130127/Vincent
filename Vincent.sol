// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vincent {
    string public name = "Vincent"; //代币名称
    string public symbol = "VCT"; //代币符号
    uint256 public totalSupply = 100000000 * 10**18; //代币总供应量
    uint8 public decimals = 18; //代币小数点位数
    
    mapping(address => uint256) public balanceOf; //记录地址的余额
    mapping(address => mapping(address => uint256)) public allowance; //记录授权
    
    event Transfer(address indexed from, address indexed to, uint256 value); //转账事件
    event Approval(address indexed owner, address indexed spender, uint256 value); //授权事件
    
    constructor() {
        balanceOf[msg.sender] = totalSupply; //初始化合约创建者的余额
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address"); //检查接收方地址是否合法
        require(balanceOf[msg.sender] >= value, "ERC20: transfer amount exceeds balance"); //检查余额是否足够
        
        balanceOf[msg.sender] -= value; //减少发送者余额
        balanceOf[to] += value; //增加接收者余额
        
        emit Transfer(msg.sender, to, value); //触发转账事件
        
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value; //记录授权
        
        emit Approval(msg.sender, spender, value); //触发授权事件
        
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address"); //检查接收方地址是否合法
        require(balanceOf[from] >= value, "ERC20: transfer amount exceeds balance"); //检查发送方余额是否足够
        require(allowance[from][msg.sender] >= value, "ERC20: transfer amount exceeds allowance"); //检查授权是否足够
        
        balanceOf[from] -= value; //减少发送者余额
        balanceOf[to] += value; //增加接收者余额
        
        allowance[from][msg.sender] -= value; //减少授权额度
        
        emit Transfer(from, to, value); //触发转账事件
        
        return true;
    }
}
