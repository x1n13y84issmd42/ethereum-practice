// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

/**
 * Yet another attempt at crowdfunding.
 **/
contract Crankstarter {
    address payable public Creator = msg.sender;
    address payable public Beneficiary;
    
    uint256 public Goal;
    uint256 public Raised;
    uint256 public Deadline;
    
    mapping(address => uint256) Backers;
    
    enum State {
        Fundraising,
        Expired,
        Successful,
        Closed
    }
    
    // For nicer messages from at_state modifier.
    mapping(State => string) private StateNames;
    
    State public CurrentState = State.Fundraising;
    
    event Backed(address backer, uint256 amount);
    event Reclaimed(address backer, uint256 amount);
    event Funded(uint256 amount);
    event Successful();
    event Expired();
    
    // Allows functions to be called only at certain states.
    modifier at_state(State s) {
        require(CurrentState == s, string(abi.encodePacked("Operation is possible only in the ", StateNames[s], " state.")));
        _;
    }
    
    // Automatically advances the funding state on every call.
    modifier advance_state() {
        if (block.timestamp >= Deadline) {
            if (CurrentState == State.Fundraising) {
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
    
    constructor(address payable beneficiary, uint256 goal, uint256 duration) {
        Beneficiary = beneficiary;
        
        if (Beneficiary == address(0)) {
            Beneficiary = Creator;
        }
        
        Goal = goal;
        Raised = 0;
        Deadline = block.timestamp + duration * 10 seconds;
        
        // For nicer messages from at_state modifier.
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
    function reclaim() at_state(State.Expired) public {
        // Check
        require(Backers[msg.sender] > 0, "You haven't backed the project.");
        uint256 amount = Backers[msg.sender];
        // Effect
        Backers[msg.sender] = 0;
        // Interaction
        msg.sender.transfer(amount);
        emit Reclaimed(msg.sender, amount);
    }
    
    // The project author comes here for their funding.
    // Withdrawal pattern again.
    function claimFunds() by(Beneficiary) at_state(State.Successful) public {
        Beneficiary.transfer(Raised);
        emit Funded(Raised);
        Raised = 0;
        CurrentState = State.Closed;
    }
}