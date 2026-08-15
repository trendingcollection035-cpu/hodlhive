// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title HodlHive Staking
/// @notice Basic staking contract — users deposit ETH and it tracks their holdings
/// @dev Starter/work-in-progress contract — not audited, do not use with real funds yet
contract HodlHiveStaking {
    address public owner;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositTimestamp;

    event Deposited(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Deposit ETH into the hive
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
        depositTimestamp[msg.sender] = block.timestamp;
        emit Deposited(msg.sender, msg.value, block.timestamp);
    }

    /// @notice Withdraw your deposited ETH
    /// @param amount Amount to withdraw in wei
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");
        emit Withdrawn(msg.sender, amount, block.timestamp);
    }

    /// @notice Check how long a user has held their deposit
    function holdingDuration(address user) external view returns (uint256) {
        if (balances[user] == 0) return 0;
        return block.timestamp - depositTimestamp[user];
    }

    /// @notice Get total balance held in the contract
    function totalHeld() external view returns (uint256) {
        return address(this).balance;
    }
}
