// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Crowdfunding {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public raisedAmount;
    bool public fundsWithdrawn;

    mapping(address => uint) public contributions;

    constructor(uint _goal, uint _durationInDays) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        fundsWithdrawn = false;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign has ended.");
        require(msg.value > 0, "Contribution must be more than 0.");

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw.");
        require(block.timestamp >= deadline, "Campaign is still active.");
        require(raisedAmount >= goal, "Funding goal not reached.");
        require(!fundsWithdrawn, "Funds already withdrawn.");

        fundsWithdrawn = true;
        payable(owner).transfer(address(this).balance);
    }

    function refund() external {
        require(block.timestamp >= deadline, "Campaign is still active.");
        require(raisedAmount < goal, "Funding goal was reached.");

        uint amount = contributions[msg.sender];
        require(amount > 0, "No contributions to refund.");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getMyContribution() external view returns (uint) {
        return contributions[msg.sender];
    }

    function getCampaignDetails() external view returns (
        address _owner, uint _goal, uint _deadline, uint _raisedAmount, bool _fundsWithdrawn
    ) {
        return (owner, goal, deadline, raisedAmount, fundsWithdrawn);
    }
}
