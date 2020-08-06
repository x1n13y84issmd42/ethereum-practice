// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import "Tokens.sol";

contract Kickstarter {
    address payable public Beneficiary;

    uint public Goal;
    uint public Raised;
    uint public Deadline;

    Tokens Reward;

    struct Backer {
        address payable addr;
        uint amount;
    }

    Backer[] public Backers;

    event Transfer(address backer, uint amount, string t);

    constructor(address payable ben, uint gl, uint dur, Tokens rew) {
        Beneficiary = ben;
        Goal = gl * 1 ether;
        Deadline = block.timestamp + dur * 10 seconds;
        Reward = Tokens(rew);
    }

    // This is called whenever someone sends ETH to the contract.
    receive() external payable {
        uint amount = msg.value;
        Backers.push(Backer({addr: msg.sender, amount: amount}));
        Raised += amount;
        
        Reward.Send(msg.sender, amount);

        emit Transfer(msg.sender, amount, "contribution");
    }

    modifier after_deadline() {if (block.timestamp >= Deadline) _; }

    function HasReachedDeadline() public view returns (bool) {
        return block.timestamp >= Deadline;
    }

    function CheckGoals() public after_deadline returns (string memory) {
        if (Raised >= Goal) {
            Beneficiary.transfer(Raised);
            emit Transfer(Beneficiary, Raised, "profit");
            
            return "Success!";
        } else {
            for (uint i=0; i<Backers.length; i++) {
                Backers[i].addr.transfer(Backers[i].amount);
                emit Transfer(Backers[i].addr, Backers[i].amount, "refund");
            }
    
            return "Backers refunded.";
        }
    }
}
