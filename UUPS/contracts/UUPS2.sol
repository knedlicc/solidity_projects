// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract UUPS2 {
  address public implementation;
  address public admin;
  string public words;

  function foo() public{
    words = "new";
  }

  function upgrade(address newImplementation) external {
    require(msg.sender == admin);
    implementation = newImplementation;
  }
}
