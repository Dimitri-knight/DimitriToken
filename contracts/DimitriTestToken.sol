// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DimitriTestToken is ERC20, ERC20Permit, Ownable {
    uint256 public faucetAmount = 30 * 1e18; // 30 DIM tokens
    uint256 public bonusfaucetAmount = 5 * 1e18; // 5 DIM tokens
    uint256 public claimCount = 0;

    address[] public claimers;
    mapping(address => bool) public hasClaimed;

    mapping(address => uint256) public lastClaimed;
    uint256 public claimCooldown = 1 days;

    constructor() 
        ERC20("DimitriTestToken", "DIM") 
        ERC20Permit("DimitriTestToken") 
        Ownable(msg.sender) 
    {}

    event TokensClaimed(address indexed user, uint256 amount);
    event BonusAwarded(address indexed user, uint256 bonusAmount);

    // ========== OPTIONAL: Minting ==========
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // ========== OPTIONAL: Burning ==========
    function burn(uint256 amount) public onlyOwner{
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public onlyOwner{
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }

    // ========== FAUCET ==========
    function claim() external {
        require(block.timestamp - lastClaimed[msg.sender] >= claimCooldown, "Please wait before claiming again");
        claimCount++;
        lastClaimed[msg.sender] = block.timestamp;

        if (!hasClaimed[msg.sender]) {
            hasClaimed[msg.sender] = true;
            claimers.push(msg.sender);
        }

        if (claimCount % 5 == 0) {
            _mint(msg.sender, faucetAmount+bonusfaucetAmount);
            emit BonusAwarded(msg.sender, faucetAmount+bonusfaucetAmount);
        }
        else 
        {
            _mint(msg.sender, faucetAmount);
            emit TokensClaimed(msg.sender, faucetAmount);
        }
    }

    function timeUntilNextClaim(address user) external view returns (uint256) {
        uint256 last = lastClaimed[user];
        if (block.timestamp >= last + claimCooldown) {
            return 0;
        } else {
            return (last + claimCooldown) - block.timestamp;
        }
    }

    function getClaimers() external view onlyOwner returns (address[] memory, uint256[] memory) {
        uint256[] memory balances = new uint256[](claimers.length);

        for (uint256 i = 0; i < claimers.length; i++) {
            balances[i] = balanceOf(claimers[i]);
        }

        return (claimers, balances);
    }

}
