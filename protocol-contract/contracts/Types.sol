// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Types {
  struct StreamDetail {
    bool isEntity;
    address sender;
    address receiver;
    uint256 amount;
    uint256 remainingBalance;
    uint256 lastClaimTime;
    uint256 startTime;
    uint256 ratePerSecond;
  }
  
  struct RewardDetail {
    bool isEntity;
    address sender;
    address rewardContract;
    uint256 lastClaimTime;
  }
}