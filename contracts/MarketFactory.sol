// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Market.sol";

contract MarketFactory is Ownable {
    address payable public treasury;
    address payable public protocolReserves;

    uint256 public constant BASIS_POINTS = 10000;
    uint256 public tradingFeeBPS = 200; // 2%
    uint256 public treasuryShareBPS = 7000; // 70% of fee
    uint256 public withdrawalFeeBPS = 50; // 0.5%

    uint256 public treasuryBalance;
    uint256 public protocolBalance;

    struct UserStats {
        uint256 totalVolume;
        uint256 points;
        uint256 tradesCount;
        uint256 winsCount;
    }

    mapping(address => UserStats) public userStats;
    mapping(address => bool) public isValidMarket;

    address[] public allMarkets;

    event MarketCreated(address indexed marketAddr, string question, uint256 deadline);
    event FeesDeposited(uint256 treasuryAmount, uint256 protocolAmount);

    constructor(address payable _treasury, address payable _protocolReserves) Ownable(msg.sender) {
        treasury = _treasury;
        protocolReserves = _protocolReserves;
    }

    function updateFees(uint256 _tradingFeeBPS, uint256 _treasuryShareBPS, uint256 _withdrawalFeeBPS) external onlyOwner {
        tradingFeeBPS = _tradingFeeBPS;
        treasuryShareBPS = _treasuryShareBPS;
        withdrawalFeeBPS = _withdrawalFeeBPS;
    }

    function createMarket(
        string calldata question,
        string calldata category,
        string[] calldata outcomeNames,
        uint256 deadline
    ) external onlyOwner returns (address market) {
        require(deadline > block.timestamp, "Invalid deadline");
        require(outcomeNames.length >= 2, "Min 2 outcomes");

        Market newMarket = new Market(IMarketFactory(address(this)), question, category, outcomeNames, deadline);
        address marketAddr = address(newMarket);
        isValidMarket[marketAddr] = true;
        allMarkets.push(marketAddr);

        emit MarketCreated(marketAddr, question, deadline);
        return marketAddr;
    }

    function depositTreasuryFees() external payable {
        require(isValidMarket[msg.sender], "Invalid market");
        uint256 amount = msg.value;
        treasuryBalance += amount;
        emit FeesDeposited(amount, 0);
    }

    function depositProtocolFees() external payable {
        require(isValidMarket[msg.sender], "Invalid market");
        uint256 amount = msg.value;
        protocolBalance += amount;
        emit FeesDeposited(0, amount);
    }

    function withdrawTreasury() external onlyOwner {
        uint256 amount = treasuryBalance;
        treasuryBalance = 0;
        treasury.transfer(amount);
    }

    function withdrawProtocol() external onlyOwner {
        uint256 amount = protocolBalance;
        protocolBalance = 0;
        protocolReserves.transfer(amount);
    }

    function addTradeStats(address user, uint256 volume, uint256 points) external {
        require(isValidMarket[msg.sender], "Invalid market");
        UserStats storage stats = userStats[user];
        stats.totalVolume += volume;
        stats.points += points;
        stats.tradesCount++;
    }

    function addWinStats(address user, uint256 bonusPoints) external {
        require(isValidMarket[msg.sender], "Invalid market");
        UserStats storage stats = userStats[user];
        stats.winsCount++;
        stats.points += bonusPoints;
    }

    function getAllMarkets() external view returns (address[] memory) {
        return allMarkets;
    }

    receive() external payable {}
}
