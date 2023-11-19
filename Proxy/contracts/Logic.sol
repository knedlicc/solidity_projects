// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Logic {
  address public implementation;
  uint public x = 99;
  event CallSuccess(); 

  function increment() external returns(uint) {
    emit CallSuccess();
    return x + 1;
  }
}
