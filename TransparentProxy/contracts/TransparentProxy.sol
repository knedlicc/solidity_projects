// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TransparentProxy {
  address implementation;
  address admin;
  string public words;

  constructor(address _implementation) {
    implementation = _implementation;
    admin = msg.sender;
  }

   fallback() external payable {
    require(msg.sender != admin);
    (bool success, bytes memory data) = implementation.delegatecall(msg.data);
  }

  function upgrade(address newImplementation) external {
    if (msg.sender != admin) revert();
    implementation = newImplementation;
  }
}
