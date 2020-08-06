// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

contract Helloer {
    address public owner;
    string private greeting;
    
    constructor() {
        owner = msg.sender;
        greeting = "Howdy";
    }
    
    function setGreeting(string memory m) public {
        require(owner == msg.sender, "Only contract owner is allowed to set the greeting message.");
        
        greeting = m;
    }
    
    function greet(string memory name) public view returns (string memory) {
        return string(abi.encodePacked(greeting, ", ", name));
    }
}