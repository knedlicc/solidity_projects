// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.4 <=0.9.0;
import "./ERC20.sol";
contract TokenVesting {

  event TokenReleased(address indexed token, uint256 amount);

  address public immutable beneficiary;
  uint256 public immutable start;
  uint256 public immutable duration;
  mapping(address => uint256) public tokenReleased;


  constructor(address beneficiaryAddr, uint256 durationSeconds) {
    require(beneficiaryAddr != address(0), "TokenVesting: beneficiary is the zero address");
    require(durationSeconds > 0, "TokenVesting: duration <= 0");

    beneficiary = beneficiaryAddr;
    duration = durationSeconds;
    start = block.timestamp;
  }

  function release(address token) external {
    uint256 amount = vestedAmount(token, uint256(block.timestamp)) - tokenReleased[token];
    require(amount > 0, "TokenVesting: no tokens are due");
    tokenReleased[token] += amount;
    emit TokenReleased(token, amount);
    IERC20(token).transfer(beneficiary, amount);
  }

  function vestedAmount(address token, uint256 timestamp) public view returns (uint256) {
    uint256 total = IERC20(token).balanceOf(address(this)) + tokenReleased[token];
    if(timestamp < start) {
      return 0;
    } else if(timestamp - start > duration) {
      return total;
    } else return total * (timestamp - start) / duration;
  }
}
