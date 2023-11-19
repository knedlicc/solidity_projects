// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ProxyContract {
  address public implementation;

  constructor(address implementation_){
    implementation = implementation_;
  } 

  fallback() external payable {
    address _implementation = implementation;
    assembly {
        // copy msg.data to memory
        // the parameters of opcode calldatacopy: start position of memory, start position of calldata, length of calldata
        calldatacopy(0, 0, calldatasize())

        // use delegatecall to call implementation contract
        // the parameters of opcode delegatecall: gas, target contract address, start position of input memory, length of input memory, start position of output memory, length of output memory
        // set start position of output memory and length of output memory to 0
        // delegatecall returns 1 if success, 0 if fail
        let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
        
        // copy returndata to memory
        // the parameters of opcode returndata: start position of memory, start position of returndata, length of retundata
        returndatacopy(0, 0, returndatasize())

        switch result
        // if delegate call fails, then revert
        case 0 {
            revert(0, returndatasize())
        }

        // if delegate call succeeds, then return memory data(as bytes format) starting from 0 with length of returndatasize()
        default {
            return(0, returndatasize())
        }
    }
  }
}
