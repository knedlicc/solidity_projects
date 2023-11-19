// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4 <0.9.0;

contract PaymentSplit {

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    address[] public payees;
    uint256 public totalShares = 0;
    uint256 public totalReleased = 0;   
    mapping(address => uint256) public shares;
    mapping(address => uint256) public released;

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length, "PaymentSplit: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplit: no payees");

        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function _addPayee(address _payee, uint256 _shares) internal {
        require(_payee != address(0), "PaymentSplit: account is the zero address");
        require(_shares > 0, "PaymentSplit: shares are 0");
        require(shares[_payee] == 0, "PaymentSplit: account already has shares");

        payees.push(_payee);
        shares[_payee] = _shares;
        totalShares += _shares;
        emit PayeeAdded(_payee, _shares);
    }

    function release(address payable _account) external virtual {
      require(shares[_account] > 0, "PaymentSplit: account has no shares");
      uint amount = releasable(_account);
      require(amount != 0, "PaymentSplitter: account is not due payment");
      released[_account] = released[_account] + amount;
      totalReleased = totalReleased + amount;
      _account.transfer(amount);

      emit PaymentReleased(_account, amount);
    }

    function releasable(address _account) internal view returns (uint) {
        return pendingPayment(_account, address(this).balance + totalReleased, released[_account]);
    }

    function pendingPayment(address _account, uint _totalReceived, uint _alreadyReleased) internal view returns(uint){
        return _totalReceived * shares[_account] / totalShares - _alreadyReleased;
    }
}