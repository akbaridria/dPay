// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IAToken} from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";

import "./intefaces/IAaveFaucet.sol";
import "./Types.sol";
import "./DPayReward.sol";

contract DPay is AxelarExecutable, ReentrancyGuard, Ownable {
  // variables
  using SafeMath for uint256;

  IAxelarGasService gasReceiver;
  IERC20 usdc;
  IERC20 aUsdc;
  IAToken aToken;
  IAaveFaucet aaveFaucet;
  IPool iPool;

  uint256 public TotalValueLock;
  uint256 public lastId = 0;
  mapping(uint256 => Types.StreamDetail) public paymentStream;
  mapping(address => uint256[]) public senders;
  mapping(address => uint256[]) public recipients;
  mapping(address => Types.RewardDetail) public trackReward;
  mapping(string => uint256) public times;

  // modifiers
  modifier streamExist(uint256 _id) {
    require(paymentStream[_id].isEntity == true, "Stream doesn't exist");
    _;
  }

  modifier isSender(uint256 _id, address _sender) {
    require(paymentStream[_id].sender == _sender, "You are not the sender");
    _;
  }

  // events
  event _Deposit(address indexed _fromAddress, uint256 indexed _lastId, string _fromChain, uint256 _amount);
  event _Withdraw(address indexed _fromAddress, uint256 indexed _lastId, string _fromChain, uint256 _amount);

  // constructor
  constructor(
    address _gasReceiver,
    address _gateway,
    address _usdc,
    address _aaveFaucet,
    address _aUsdc,
    address _iPool,
    address _aToken
  ) AxelarExecutable(_gateway) {
    gasReceiver = IAxelarGasService(_gasReceiver);
    usdc = IERC20(_usdc);
    aaveFaucet = IAaveFaucet(_aaveFaucet);
    aUsdc = IERC20(_aUsdc);
    iPool = IPool(_iPool);
    aToken = IAToken(_aToken);

    times['seconds'] = 1;
    times['hours'] = 3600;
    times['days'] = 86400;
    times['months'] = 2628288;
    times['years'] = 31536000;

  }
  // methods

  // write methods
  function deposit(
    uint256 _amount,
    address _recipient,
    string memory _times
  ) external nonReentrant {
    // validation
    require(usdc.balanceOf(msg.sender) >= _amount, "insufficient balance");
    require(_amount >= 1e8, "minimum deposit 100 usdc");

    // logics
    usdc.transferFrom(msg.sender, address(this), _amount);
    _deposit(
      msg.sender,
      _amount,
      _recipient,
      _times,
      "Ethereum"
    );
  }

  function _deposit(
    address _sender,
    uint256 _amount,
    address _recipient,
    string memory _times,
    string memory _fromChain
  ) internal {
    
    DPayReward payReward;

    // if RewardDetail is exist then set the instance if it is not then create the new one
    if(trackReward[_sender].isEntity == true) {
      payReward = DPayReward(trackReward[_sender].rewardContract);
    } else {
      payReward = new DPayReward(
        address(this),
        address(aToken),
        address(iPool),
        address(usdc)
      );
      trackReward[_sender].isEntity = true;
      trackReward[_sender].sender = _sender;
      trackReward[_sender].rewardContract = address(payReward);
    }
    
    TotalValueLock += _amount;
    payReward.addTotalDeposit(_amount);

    // set stream detail
    Types.StreamDetail memory stream = Types.StreamDetail({
      isEntity: true,
      sender: _sender,
      receiver: _recipient,
      amount: _amount,
      remainingBalance: _amount,
      lastClaimTime: block.timestamp,
      startTime: block.timestamp,
      ratePerSecond: _amount.div(times[_times])
    });
    
    lastId++;
    paymentStream[lastId] = stream;
    
    // set streamId for ongoing and ingoing address
    senders[_sender].push(lastId);
    recipients[_recipient].push(lastId);

    usdc.approve(address(iPool), _amount);
    iPool.supply(address(usdc), _amount, trackReward[_sender].rewardContract, 0);

    emit _Deposit(msg.sender, lastId, _fromChain, _amount);
  }

  function withdraw(
    uint256 _id
  ) external streamExist(_id) nonReentrant {

    uint256 amount = _withdraw(
      _id,
      msg.sender,
      "Ethereum"
    );
    usdc.transfer(msg.sender, amount);
  }

  function _withdraw(
    uint256 _id,
    address _recipient,
    string memory _toChain
  ) internal returns (uint256) {
    // validation
    require(paymentStream[_id].receiver == _recipient, "You are not the recipeint");

    // logics
    DPayReward payReward = DPayReward(trackReward[paymentStream[_id].sender].rewardContract);
    uint256 amount = _calculateAmountWithdraw(_id);

    TotalValueLock -= amount;
    paymentStream[_id].remainingBalance -= amount;
    paymentStream[_id].lastClaimTime = block.timestamp;

    payReward.withdraw(amount);
    emit _Withdraw(_recipient, _id, _toChain, amount);

    return amount;
  }

  // view functions
  function _calculateAmountWithdraw(
    uint256 _id
  ) internal view returns (uint256) {
    if(paymentStream[_id].lastClaimTime == block.timestamp) {
      return 0;
    } else {
      uint256 amount = (block.timestamp - paymentStream[_id].lastClaimTime).mul(paymentStream[_id].ratePerSecond);
      if(amount > paymentStream[_id].remainingBalance) {
        return paymentStream[_id].remainingBalance;
      }
      return amount;
    }
  }
}