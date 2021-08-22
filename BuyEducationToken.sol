// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EducationToken is IERC20{
    string _name;
    string _symbol;
    uint256 _decimals;
    uint256 _totalSupply;
    address _owner;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    
    constructor(){
        _name ="Education Token";
        _symbol = "ECT";
        _decimals = 18;
        _totalSupply = 1000000 *10**_decimals;
        _owner = msg.sender;
        balances[_owner] = _totalSupply;
    }

    function totalSupply() external view override returns (uint256){
        return _totalSupply;       
    }
    
    function balanceOf(address account) external view override returns (uint256){
        return balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool){
        require(recipient !=address(0),"ERROR: sending to Zero address");
        require(msg.sender !=address(0),"ERROR: sending from Zero address");
        require(balances[msg.sender] >= amount,"ERROR: Not enough balance to Transfer");
        require( amount > 0,"ERROR: sending zero amount");
        
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient]  = balances[recipient] + amount;
        
        emit Transfer(msg.sender,recipient,amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256){
        return allowances[owner][spender]; 
    }

    function approve(address spender, uint256 amount) external override returns (bool){
        require(spender !=address(0),"ERROR:approve from Zero address");
        require(msg.sender !=address(0),"ERROR: apprive to Zero address");
        require(balances[msg.sender] >=amount,"ERROR: dont have enough tokens");
        require(amount > 0, "ERROR: assignment should be more tha Zero");
        
        allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender,spender,amount);
        return true;       
    }
    
    function transferFrom(address sender,address recipient,uint256 amount) external override returns (bool){
        
        require(recipient !=address(0),"ERROR: sending to Zero address");
        require(msg.sender !=address(0),"ERROR: sending from Zero address");
        require(allowances[sender][recipient] >= amount,"ERROR: Not enough balance to Transfer");
        require( amount > 0,"ERROR: sending zero amount");
        
        allowances[msg.sender][sender] -= amount;
        
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient]  = balances[recipient] + amount;
        
        emit Transfer(msg.sender,recipient,amount); 
        return true;
        
    }
}

// Assignment 3A (ERC20)
//Create a token based on ERC20 which is buyable. Following features should present;
//1. Anyone can get the token by paying against ether
//2. Add fallback payable method to Issue token based on Ether received. Say 1 Ether = 100 tokens.
//3. There should be an additional method to adjust the price that allows the owner to adjust the price.

contract BuyEducationToken is EducationToken{
    // 1 ECT = 100 EThers
    // token price = 1,000000000000000000 / 100,000000000000000000
    // token price = 0.01 EThers
    
    uint256 tokenPrice = 10000000000000000; // 0.01 Ethers
    uint256 noOfTokens;
    
    function buyToken()public payable returns(bool){
        // Buy min 1 token or max 500 tokens at a time 
        require(msg.value >= 10000000000000000 && msg.value <= 5000000000000000000,"Buy min 1 token max 500 at a time");
        require(msg.sender !=address(0),"ERRO buying tokens from addres Zero");
       
        noOfTokens = (msg.value / tokenPrice) *10**18;
       
        require(balances[_owner] >=noOfTokens,"ERROR: Tokens sold out");
        
        balances[msg.sender] += noOfTokens;
        balances[_owner] -= noOfTokens;
         
         payable(_owner).transfer(msg.value);         
         
         return true;
    }     
    
    fallback()external payable{
        buyToken();
    }
    receive()external payable{ }
    
    function setNewPrice(uint newPrice)public{
        require(msg.sender == _owner,"ERROR: only owner can change price");
        tokenPrice = newPrice;
    }
}
