// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IVoteD21.sol";

contract D21 is IVoteD21{


    address public owner;
    address[] subjectAddresses;
    mapping(address => mapping(address => bool)) voted;
    mapping(address => int8) voters;
    mapping(address => Subject) creatorToSubject; 
    uint remainingTime;
    uint start;
    
    constructor(){
        remainingTime = 604800;
        start = block.timestamp;
        owner = msg.sender;
    }

    modifier stillValid(){
        require(block.timestamp < start + remainingTime, "Voting is over");
        _;
    }

    function addSubject(string memory name) external stillValid {
        require(bytes(name).length > 0, "Name is empty");
        require(bytes(creatorToSubject[msg.sender].name).length == 0, "You already have registered a subject");
        subjectAddresses.push(msg.sender);
        creatorToSubject[msg.sender] = Subject({name: name, votes: 0});
    } 

    function addVoter(address addr) external stillValid {
        require(msg.sender == owner, "You are not the owner");
        require(voters[addr] == 0, "This address is already a voter");
        voters[addr] = 1;
    }

    function getVoter(address addr) external view returns(int8){
        return voters[addr];
    }

    function getSubjects() external view returns(address[] memory) {
        return subjectAddresses;    
    }

    function getSubject(address addr) external view returns(Subject memory) {
        require(bytes(creatorToSubject[addr].name).length != 0, "This address is not a subject"); 
        return creatorToSubject[addr];
    }

    function votePositive(address addr) external stillValid {
        require(voters[msg.sender] != 0, "You are not a voter");
        require(bytes(creatorToSubject[addr].name).length != 0, "This address is not a subject"); 
        require(voted[msg.sender][addr] == false, "You already voted for this subject");
        require(voters[msg.sender] != 3, "You already voted 2 times");
        require(voters[msg.sender] != 4, "You already voted 3 times");
        creatorToSubject[addr].votes++;
        voters[msg.sender]++;
        voted[msg.sender][addr] = true;
    }

    function voteNegative(address addr) external stillValid {
        require(voters[msg.sender] != 0, "You are not a voter");
        require(bytes(creatorToSubject[addr].name).length != 0, "This address is not a subject"); 
        require(voters[msg.sender] >= 3, "You did not vote positive for 2 subjects");
        require(voters[msg.sender] != 4, "You already voted negative");
        creatorToSubject[addr].votes--;
        voters[msg.sender]++;
        voted[msg.sender][addr] = true;
    }

    function getRemainingTime() external view stillValid returns (uint256) {
        return start + remainingTime - block.timestamp;
    }

    function getResults() external view returns(Subject[] memory) {
        Subject[] memory subjects = new Subject[](subjectAddresses.length);
        for(uint8 i = 0; i < subjectAddresses.length; i++) {
            subjects[i] = creatorToSubject[subjectAddresses[i]];
        }
        sortResults(subjects, 0, int(subjectAddresses.length - 1));
        return subjects;
    }


    function sortResults(Subject[] memory subjects, int left, int right) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        int pivot = subjects[uint(left + (right - left) / 2)].votes;
        while (i <= j) {
            while (subjects[uint(i)].votes > pivot) i++;
            while (pivot > subjects[uint(j)].votes) j--;
            if (i <= j) {
                (subjects[uint(i)], subjects[uint(j)]) = (subjects[uint(j)], subjects[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            sortResults(subjects, left, j);
        if (i < right)
            sortResults(subjects, i, right);
    }
}