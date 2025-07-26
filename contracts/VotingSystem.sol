// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingSystem {
    string[5] public candidates = ["ALICE", "BOB", "CHARLIE", "DAVE", "EVE"];

    mapping(string => uint256) public votingCount;
    mapping(address => bool) public hasVoted;
    mapping(address => uint256) public votedAt;

    uint256 public immutable votingStart;
    uint256 public immutable votingEnd;

    event VoteCasted(address indexed voter, string candidate, uint256 timestamp);

    constructor(uint256 _startDelay, uint256 _duration) {
        require(_duration > 0, "Duration must be > 0");
        votingStart = block.timestamp + _startDelay;
        votingEnd = votingStart + _duration;
    }

    modifier duringVoting() {
        require(block.timestamp >= votingStart, "Voting not started");
        require(block.timestamp <= votingEnd, "Voting ended");
        _;
    }

    modifier noRevoting() {
        require(!hasVoted[msg.sender], "Already voted");
        _;
    }

    function vote(string calldata candidateName) external duringVoting noRevoting {
        require(_isValidCandidate(candidateName), "Invalid candidate");
        votingCount[candidateName] += 1;
        hasVoted[msg.sender] = true;
        votedAt[msg.sender] = block.timestamp;
        emit VoteCasted(msg.sender, candidateName, block.timestamp);
    }

    function getVotes(string calldata candidateName) external view returns (uint256) {
        require(_isValidCandidate(candidateName), "Invalid candidate");
        return votingCount[candidateName];
    }

    function timeUntilStart() external view returns (uint256) {
        return block.timestamp >= votingStart ? 0 : votingStart - block.timestamp;
    }

    function timeUntilEnd() external view returns (uint256) {
        return block.timestamp >= votingEnd ? 0 : votingEnd - block.timestamp;
    }

    function _isValidCandidate(string calldata candidateName) private view returns (bool) {
        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                keccak256(abi.encodePacked(candidates[i])) ==
                keccak256(abi.encodePacked(candidateName))
            ) {
                return true;
            }
        }
        return false;
    }
}
