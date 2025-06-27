// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DimitriTestToken is ERC20, ERC20Permit, Ownable {
    uint256 public faucetAmount = 100 * 1e18; // 100 DIM tokens
    uint256 public claimCooldown = 1 days;
    address megaOwner;

    mapping(address => uint256) public lastClaimed;

    constructor() 
        ERC20("DimitriTestToken", "DIM") 
        ERC20Permit("DimitriTestToken") 
        Ownable(msg.sender) 
    {
        megaOwner = msg.sender;
    }

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
        lastClaimed[msg.sender] = block.timestamp;
        _mint(msg.sender, faucetAmount);
    }

    function timeUntilNextClaim(address user) external view returns (uint256) {
        uint256 last = lastClaimed[user];
        if (block.timestamp >= last + claimCooldown) {
            return 0;
        } else {
            return (last + claimCooldown) - block.timestamp;
        }
    }
}
