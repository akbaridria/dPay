// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IAToken} from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./DPay.sol";

contract DPayReward {
  // variables
  using SafeMath for uint256;

  address public owner;
  IAToken aToken;
  IPool iPool;
  IERC20 usdc;
  DPay dpay;
  uint256 public totalDeposit;

  // modifiers
  modifier onlyOwner(address _sender) {
    require(_sender == owner, 'forbidden');
    _;
  }

  // events

  // constructor
  constructor(
    address _owner,
    address _aToken,
    address _iPool,
    address _usdc
  ) {
    owner = _owner;
    aToken = IAToken(_aToken);
    iPool = IPool(_iPool);
    usdc = IERC20(_usdc);
    dpay = DPay(_owner);
  }

  // write method

  // withdraw
  function withdraw(
    uint256 _amount
  ) external onlyOwner(msg.sender) {
    totalDeposit -= _amount;
    iPool.withdraw(address(usdc), _amount, address(dpay));
  }

  // setTotalDeposit
  function addTotalDeposit(
    uint256 _amount
  ) external onlyOwner(msg.sender) {
    totalDeposit += _amount;
  }

  // read method
  function getClaimablePrize() public view returns (uint256) {
    DataTypes.ReserveData memory reserve = iPool.getReserveData(address(usdc));
    return (aToken.scaledBalanceOf(address(this)).mul(reserve.liquidityIndex).div(1e27)).sub(totalDeposit);
  }
}