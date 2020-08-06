// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

contract Tokens {
    mapping (address => uint) public Balance;
    event Transfer(address from, address to, uint amount);
    
    constructor(uint supply) {
        Balance[msg.sender] = supply;
    }
    
    function Send(address to, uint amount) public {
        require(Balance[msg.sender] >= amount, "Insufficient funds on the sender account.");
        Balance[msg.sender] -= amount;
        Balance[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }
}