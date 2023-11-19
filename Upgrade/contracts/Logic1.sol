// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Logic1 {
  address public implementation;
  address public admin;
  string public words;

  function foo() public {
    words = "old";
  }
}
