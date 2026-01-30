// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// This contract acts as the admin-controlled Market creator and treasury fee handler.
contract MarketFactory {
    address public owner;
    address public treasury;
    address public protocolReserves;
    uint256 public protocolFeePercent = 2;   // 2% trading fee
    uint256 public withdrawalFeeBp = 50;     // 0.5% withdrawal fee (in basis points)

    event MarketCreated(address indexed market, string name);

    constructor(address _treasury, address _protocolReserves) {
        owner = msg.sender;
        treasury = _treasury;
        protocolReserves = _protocolReserves;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Admin can adjust fee percents at any time
    function setFeePercents(uint256 _tradeFeePercent, uint256 _withdrawalFeeBp) external onlyOwner {
        protocolFeePercent = _tradeFeePercent;
        withdrawalFeeBp = _withdrawalFeeBp;
    }

    // Admin creates a new market contract
    function createMarket(string memory name, string[] memory outcomes) external onlyOwner returns (address) {
        Market m = new Market(address(this), name, outcomes, msg.sender);
        emit MarketCreated(address(m), name);
        return address(m);
    }
}

// Basic market contract (will extend in next steps)
contract Market {
    address public factory;
    address public owner;
    string public name;
    string[] public outcomes;

    constructor(address _factory, string memory _name, string[] memory _outcomes, address _owner) {
        factory = _factory;
        name = _name;
        outcomes = _outcomes;
        owner = _owner;
    }
}
