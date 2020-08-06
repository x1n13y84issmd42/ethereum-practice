// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.6.8;

contract Test {
	uint256 public value;

	constructor() public {
		value = 123;
	}
	
	function things() public view returns (uint256) {
	    return value;
	}
}
