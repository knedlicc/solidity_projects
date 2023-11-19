// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {IVoteD21} from "./IVoteD21.sol";

contract D21 is IVoteD21 {
    struct Voter {
        bool isVoter;
        uint256 positiveVotes;
        uint256 negativeVotes;
        address firstVotedSubject;
        address secondVotedSubject;
    }

    mapping(address => Voter) private _voters;

    uint256 private constant MAX_POSITIVE_VOTES = 2;
    uint256 private constant MAX_NEGATIVE_VOTES = 1;

    address private immutable _owner;
    uint256 private immutable _endTime;

    address[] private _subjectAddresses;
    mapping(address => Subject) private _subjects;

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyVoter() {
        require(_voters[msg.sender].isVoter);
        _;
    }

    modifier votingOngoing() {
        require(block.timestamp < _endTime);
        _;
    }

    modifier subjectExists(address addr) {
        require(bytes(_subjects[addr].name).length != 0);
        _;
    }

    constructor() {
        _owner = msg.sender;
        _endTime = block.timestamp + 7 days;
    }

    function addSubject(string memory name) external {
        require(bytes(name).length != 0);
        require(bytes(_subjects[msg.sender].name).length == 0);

        _subjectAddresses.push(msg.sender);
        _subjects[msg.sender].name = name;
    }

    function addVoter(address addr) external onlyOwner {
        _voters[addr].isVoter = true;
    }

    function getSubjects() external view returns (address[] memory) {
        return _subjectAddresses;
    }

    function getSubject(address addr) external view returns (Subject memory) {
        return _subjects[addr];
    }

    function votePositive(address addr)
        external
        votingOngoing
        onlyVoter
        subjectExists(addr)
    {
        Voter storage voter = _voters[msg.sender];
        require(voter.firstVotedSubject != addr);
        require(voter.positiveVotes < MAX_POSITIVE_VOTES);

        voter.positiveVotes++;

        if (voter.positiveVotes == 1) {
            voter.firstVotedSubject = addr;
        } else {
            voter.secondVotedSubject = addr;
        }

        _subjects[addr].votes++;
    }

    function voteNegative(address addr)
        external
        votingOngoing
        onlyVoter
        subjectExists(addr)
    {
        Voter storage voter = _voters[msg.sender];
        require(voter.firstVotedSubject != addr);
        require(voter.secondVotedSubject != addr);
        require(voter.positiveVotes == MAX_POSITIVE_VOTES);
        require(voter.negativeVotes < MAX_NEGATIVE_VOTES);

        voter.negativeVotes++;
        _subjects[addr].votes--;
    }

    function getRemainingTime() external view returns (uint256) {
        if (block.timestamp >= _endTime) {
            return 0;
        }

        return _endTime - block.timestamp;
    }

    function getResults() external view returns (Subject[] memory) {
        if (_subjectAddresses.length == 0) {
            return new Subject[](0);
        }

        Subject[] memory results = new Subject[](_subjectAddresses.length);

        for (uint256 i = 0; i < _subjectAddresses.length; i++) {
            results[i] = _subjects[_subjectAddresses[i]];
        }

        sort(results);

        return results;
    }

    function sort(Subject[] memory data) private pure {
        if (data.length > 1) {
            quickSort(data, 0, data.length - 1);
        }
    }

    function quickSort(
        Subject[] memory data,
        uint256 low,
        uint256 high
    ) private pure {
        Subject memory pivotVal = data[(low + high) / 2];

        uint256 i = low;
        uint256 j = high;

        while (true) {
            while (data[i].votes > pivotVal.votes) i++;
            while (data[j].votes < pivotVal.votes) j--;

            if (i >= j) break;

            (data[i], data[j]) = (data[j], data[i]);

            i++;
            j--;
        }

        if (low < j) quickSort(data, low, j);

        j++;

        if (j < high) quickSort(data, j, high);
    }
}
