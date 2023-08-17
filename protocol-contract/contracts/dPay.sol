// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/IERC20.sol";

import {IAToken} from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

import "./intefaces/IAaveFaucet.sol";
import "./Types.sol";

contract dPay is AxelarExecutable, ReentrancyGuard, Ownable {
  // variables
  using SafeMath for uint256;

  IAxelarGasService gasReceiver;
  IERC20 usdc;
  IERC20 aUsdc;
  IAaveFaucet aaveFaucet;
  IPool iPool;

  uint256 public TotalValueLock;
  uint256 public lastId = 0;
  mapping(uint256 => Types.StreamDetail) public paymentStream;
  mapping(address => uint256[]) public senders;
  mapping(address => uint256[]) public recipients;

  // modifiers

  // events
  event _deposit(address indexed _fromAddress, uint256 indexed _lastId, string _fromChain, uint256 _amount);

  // constructor
  constructor(
    address _gasReceiver,
    address _gateway,
    address _usdc,
    address _aaveFaucet,
    address _aUsdc,
    address _iPool
  ) AxelarExecutable(_gateway) {
    gasReceiver = IAxelarGasService(_gasReceiver);
    usdc = IERC20(_usdc);
    aaveFaucet = IERC20(_aaveFaucet);
    aUsdc = IERC20(_aUsdc);
    iPool = IPool(_iPool);
  }
  // methods

  // write methods
  function deposit(
    uint256 amount
  ) external nonReentrant {
    // validation
    require(usdc.balanceOf(msg.sender) >= amount, "insufficient balance");
    require(amount >= 1e8, "minimum deposit 100 usdc");

    // logics
    usdc.transferFrom(msg.sender, address(this), amount);
    aaveFaucet.mint(address(_aUsdc), address(this), amount);
    
    TotalValueLock += TotalValueLock;

    aUsdc.approve(address(iPool), amount);
    iPool.supply(address(_aUsdc), amount, address(this), 0);

    emit _deposit(msg.sender, lastId, 'Ethereum', amount);
  }

  function withdraw(uint256 amount) external userExist(msg.sender) nonReentrant {
    require(userData[msg.sender].balance >= amount, "insufficient balance");

    totalDeposit -= amount;

    iPool.withdraw(address(usdc), amount, address(this));

    userData[msg.sender].balance -= amount;

    if(userData[msg.sender].balance == 0) {
      Utils.deleteArrayByValue(msg.sender, listUserData);
    }

    usdc.safeTransfer(msg.sender, amount);

    emit _withdraw(msg.sender, 'Polygon', roundId, amount);
  }

  // view methods
  function getClaimablePrize() public view returns (uint256) {
    DataTypes.ReserveData memory reserve = iPool.getReserveData(address(usdc));
    return (aToken.scaledBalanceOf(address(this)).mul(reserve.liquidityIndex).div(1e27)).sub(totalDeposit);
  }

}