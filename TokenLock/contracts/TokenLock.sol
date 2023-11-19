// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./ERC20.sol";

contract TokenLock {

  event TokenLockStart(address indexed token, address indexed beneficiary, uint256 startTime, uint256 lockTime);
  event Release(address indexed token, address indexed beneficiary, uint256 amount, uint256 releaseTime);

  IERC20 public immutable token;
  address public immutable beneficiary;
  uint256 public immutable startTime;
  uint256 public immutable lockTime;

  constructor(address _token, address _beneficiary, uint _lockTime){
    require(_token != address(0), "TokenLock: token is the zero address");
    require(_beneficiary != address(0), "TokenLock: beneficiary is the zero address");
    require(_lockTime > 0, "TokenLock: lockTime is 0");
    token = IERC20(_token);
    beneficiary = _beneficiary;
    lockTime = _lockTime;
    startTime = block.timestamp;

    emit TokenLockStart(address(_token), _beneficiary, block.timestamp, _lockTime);
  }

  function release() public {
    require(block.timestamp >= startTime + lockTime, "TokenLock: current time is before release time");

    uint256 amount = token.balanceOf(address(this));
    require(amount > 0, "TokenLock: no tokens to release");

    require(token.transfer(beneficiary, amount), "TokenLock: transfer failed");

    emit Release(address(token), beneficiary, amount, block.timestamp);
  }
}
