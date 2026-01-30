// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IMarketFactory {
    function tradingFeeBPS() external view returns (uint256);
    function treasuryShareBPS() external view returns (uint256);
    function withdrawalFeeBPS() external view returns (uint256);
    function depositTreasuryFees() external payable;
    function depositProtocolFees() external payable;
    function addTradeStats(address user, uint256 volume, uint256 points) external;
    function addWinStats(address user, uint256 bonusPoints) external;
    function owner() external view returns (address);
}

contract Market is ReentrancyGuard, Pausable {
    IMarketFactory public immutable factory;

    string public question;
    string public category;
    uint256 public deadline;
    bool public resolved;
    uint256 public winningOutcomeId;

    struct Outcome {
        string name;
        uint256 totalStaked; // Net after trading fees
    }

    Outcome[] public outcomes;

    struct Position {
        uint256 outcomeId;
        uint256 shares;
        bool claimed;
    }

    mapping(address => Position) public positions;

    uint256 public totalGrossVolume;
    uint256 public constant POINTS_PER_ETH = 100;
    uint256 public constant WINNER_MULTIPLIER_BPS = 15000; // 1.5x (150%)

    event BetPlaced(address indexed user, uint256 outcomeId, uint256 grossAmount, uint256 shares);
    event MarketResolved(uint256 winningOutcomeId);
    event WinningsClaimed(address indexed user, uint256 amount);

    constructor(
        IMarketFactory _factory,
        string memory _question,
        string memory _category,
        string[] memory _outcomeNames,
        uint256 _deadline
    ) {
        factory = _factory;
        question = _question;
        category = _category;
        deadline = _deadline;
        for (uint256 i = 0; i < _outcomeNames.length; i++) {
            outcomes.push(Outcome({name: _outcomeNames[i], totalStaked: 0}));
        }
    }

    function placeBet(uint256 outcomeId) external payable nonReentrant whenNotPaused {
        require(block.timestamp < deadline, "Closed");
        require(!resolved, "Resolved");
        require(outcomeId < outcomes.length, "Invalid outcome");
        require(msg.value > 0, "No ETH");

        uint256 feeBPS = factory.tradingFeeBPS();
        uint256 treasuryShare = factory.treasuryShareBPS();

        uint256 fee = (msg.value * feeBPS) / 10000;
        uint256 treasuryFee = (fee * treasuryShare) / 10000;
        uint256 protocolFee = fee - treasuryFee;
        uint256 shares = msg.value - fee;

        outcomes[outcomeId].totalStaked += shares;
        totalGrossVolume += msg.value;

        Position storage pos = positions[msg.sender];
        if (pos.shares > 0) require(pos.outcomeId == outcomeId, "Can't switch");
        else pos.outcomeId = outcomeId;
        pos.shares += shares;

        uint256 points = (msg.value * POINTS_PER_ETH) / 1e18;
        factory.addTradeStats(msg.sender, msg.value, points);

        if (treasuryFee > 0) factory.depositTreasuryFees{value: treasuryFee}();
        if (protocolFee > 0) factory.depositProtocolFees{value: protocolFee}();

        emit BetPlaced(msg.sender, outcomeId, msg.value, shares);
    }

    function resolveMarket(uint256 _winningOutcomeId) external {
        require(msg.sender == factory.owner(), "Not owner");
        require(block.timestamp >= deadline, "Not ended");
        require(!resolved, "Resolved");
        require(_winningOutcomeId < outcomes.length, "Invalid");

        resolved = true;
        winningOutcomeId = _winningOutcomeId;
        emit MarketResolved(_winningOutcomeId);
    }

    function claimWinnings() external nonReentrant {
        require(resolved, "Not resolved");
        Position storage pos = positions[msg.sender];
        require(pos.shares > 0 && !pos.claimed && pos.outcomeId == winningOutcomeId, "No win");

        pos.claimed = true;

        uint256 totalNetPool = 0;
        for (uint256 i = 0; i < outcomes.length; i++) {
            totalNetPool += outcomes[i].totalStaked;
        }

        uint256 payout = (pos.shares * totalNetPool) / outcomes[winningOutcomeId].totalStaked;
        uint256 withdrawFee = (payout * factory.withdrawalFeeBPS()) / 10000;
        uint256 netPayout = payout - withdrawFee;

        if (withdrawFee > 0) factory.depositTreasuryFees{value: withdrawFee}();

        uint256 bonusPoints = (pos.shares * POINTS_PER_ETH * (WINNER_MULTIPLIER_BPS - 10000)) / (1e18 * 10000);
        factory.addWinStats(msg.sender, bonusPoints);

        payable(msg.sender).transfer(netPayout);

        emit WinningsClaimed(msg.sender, netPayout);
    }

    function getProbabilities() external view returns (uint256[] memory probs) {
        uint256 totalNet = 0;
        probs = new uint256[](outcomes.length);
        for (uint256 i = 0; i < outcomes.length; i++) totalNet += outcomes[i].totalStaked;
        if (totalNet == 0) return probs;
        for (uint256 i = 0; i < outcomes.length; i++) probs[i] = (outcomes[i].totalStaked * 10000) / totalNet;
    }

    receive() external payable {}
}
