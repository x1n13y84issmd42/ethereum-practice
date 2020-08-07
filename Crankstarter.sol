// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

/**
 * Yet another attempt at crowdfunding.
 * The campain must be started manually by calling Start().
 **/
contract Crankstarter {
    address payable public Creator = msg.sender;
    address payable public Beneficiary;
    
    uint public Goal;
    uint public Raised;
    uint public Duration;
    uint public Deadline;
    
    mapping(address => uint) Backers;
    
    enum State {
        Created,
        Fundraising,
        Expired,
        Successful,
        Closed
    }
    
    // For nicer messages from at_state modifier.
    mapping(State => string) private StateNames;
    
    State public CurrentState = State.Created;
    
    event Started(uint t, uint duration, uint deadline);
    event Backed(address backer, uint amount);
    event Reclaimed(address backer, uint amount);
    event Funded(uint amount);
    event Successful();
    event Expired();
    event Closed();
    
    // Allows functions to be called only at certain states.
    modifier at_state(State s) {
        require(CurrentState == s, string(abi.encodePacked(
            "Operation is possible only in the ",
            StateNames[s],
            " state. Currently it is ",
            StateNames[CurrentState],
            ".")));
        _;
    }
    
    // Automatically advances the funding state on every call.
    modifier advance_state() {
        if (CurrentState == State.Fundraising) {
            if (block.timestamp >= Deadline) {
                if (Raised >= Goal) {
                    CurrentState = State.Successful;
                    emit Successful();
                } else {
                    CurrentState = State.Expired;
                    emit Expired();
                }
            }
        }
        
        _;
    }
    
    // Restricts function invocation by specific addresses.
    modifier by(address payable who) {
        require(msg.sender == who, "You aren't allowed to do this.");
        _;
    }
    
    constructor(address payable beneficiary, uint goal, uint duration) {
        Beneficiary = beneficiary;
        
        if (Beneficiary == address(0)) {
            Beneficiary = Creator;
        }
        
        Goal = goal * 1 ether;
        Raised = 0;
        Duration = duration;
        
        // For nicer messages from at_state modifier.
        StateNames[State.Created] = "Created";
        StateNames[State.Fundraising] = "Fundraising";
        StateNames[State.Successful] = "Successful";
        StateNames[State.Expired] = "Expired";
        StateNames[State.Closed] = "Closed";
    }
    
    receive() at_state(State.Fundraising) advance_state external payable {
        Backers[msg.sender] += msg.value;
        Raised += msg.value;
        emit Backed(msg.sender, msg.value);
    }
    
    // Withdrawal pattern it is.
    function reclaim() advance_state at_state(State.Expired) public {
        // In order to prevent re-entrancy attacks (when atatcker recursively calls reclaim()) do CEI:
        // Check
        require(Backers[msg.sender] > 0, "You haven't backed the project.");
        uint amount = Backers[msg.sender];
        // Effect
        Backers[msg.sender] = 0;
        Raised -= amount;
        
        // Autoclosing the fundraiser.
        if (Raised == 0) {
            CurrentState = State.Closed;
            emit Closed();
        }
        
        // Interaction
        msg.sender.transfer(amount);
        emit Reclaimed(msg.sender, amount);
    }
    
    // The project author comes here for their funding.
    // Withdrawal pattern again.
    function claimFunds() by(Beneficiary) advance_state at_state(State.Successful) public {
        Beneficiary.transfer(Raised);
        emit Funded(Raised);
        
        // Closing the fundraiser.
        Raised = 0;
        CurrentState = State.Closed;
        emit Closed();
    }
    
    function Start() by(Creator) at_state(State.Created) public {
        Deadline = block.timestamp + Duration * 10 seconds;
        CurrentState = State.Fundraising;
        emit Started(block.timestamp, Duration, Deadline);
    }
    
    function TimeLeft() advance_state public returns (uint) {
        return Deadline - block.timestamp;
    }
}