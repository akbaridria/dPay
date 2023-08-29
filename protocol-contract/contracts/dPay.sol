// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {StringToAddress} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/AddressString.sol";

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
  using StringToAddress for string;

  IAxelarGasService gasReceiver;
  IERC20 usdc;
  IERC20 aUsdc;
  IAToken aToken;
  IAaveFaucet aaveFaucet;
  IPool iPool;

  uint256 public TotalValueLock;
  uint256 public lastId = 0;
  string public axlUSDC = 'aUSDC';
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

  modifier isOwnerStream(address _user) {
    require(trackReward[_user].isEntity == true, "You are not the owner of stream");
    _;
  }

  modifier isSender(uint256 _id, address _sender) {
    require(paymentStream[_id].sender == _sender, "You are not the sender");
    _;
  }

  // events
  event _Deposit(address indexed _fromAddress, address indexed _recipient, uint256 indexed _lastId, string _fromChain, uint256 _amount);
  event _DepositAgain(address indexed _fromAddress, uint256 indexed _id, string _fromChain, uint256 _amount);
  event _Withdraw(address indexed _fromAddress, uint256 indexed _lastId, string _fromChain, uint256 _amount);
  event _claim(address indexed _fromAddress, uint256 _amount);
  event _cancle(address indexed _fromAddress, uint256 indexed _id, uint256 _amount);
  event _error(string _error);

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
    uint256 _amountperTimes,
    string memory _times
  ) external nonReentrant {
    // validation
    require(usdc.balanceOf(msg.sender) >= _amount, "insufficient balance");
    require(_amountperTimes >= 1e8, "minimum deposit 100 usdc");
    require(_amount >=_amountperTimes, "amount should be greater or equal to amount per times");
    require(_recipient != msg.sender, "sender and recipient can't be the same");
    require(_recipient != address(0), "recipient can't be zero address");
    require(_amount <= 2e8, "maximum deposit is 200 usdc");

    // logics
    Types.DepositDetail memory tps = Types.DepositDetail({
      _sender: msg.sender,
      _amount: _amount,
      _amountPerTimes: _amountperTimes,
      _recipient: _recipient,
      _times: _times,
      _fromChain: "Ethereum"
    });

    usdc.transferFrom(msg.sender, address(this), _amount);
    _deposit(tps);
  }

  function _deposit(
    Types.DepositDetail memory args
  ) internal {
    
    DPayReward payReward;

    // if RewardDetail is exist then set the instance if it is not then create the new one
    if(trackReward[args._sender].isEntity == true) {
      payReward = DPayReward(trackReward[args._sender].rewardContract);
    } else {
      payReward = new DPayReward(
        address(this),
        address(aToken),
        address(iPool),
        address(usdc)
      );
      trackReward[args._sender].isEntity = true;
      trackReward[args._sender].sender = args._sender;
      trackReward[args._sender].rewardContract = address(payReward);
      trackReward[args._sender].lastClaimTime = block.timestamp;
    }
    
    TotalValueLock += args._amount;
    payReward.addTotalDeposit(args._amount);

    // set stream detail
    Types.StreamDetail memory stream = Types.StreamDetail({
      isEntity: true,
      sender: args._sender,
      receiver: args._recipient,
      amount: args._amount,
      remainingBalance: args._amount,
      lastClaimTime: block.timestamp,
      startTime: block.timestamp,
      ratePerSecond: args._amountPerTimes.div(times[args._times])
    });
    
    lastId++;
    paymentStream[lastId] = stream;
    
    // set streamId for ongoing and ingoing address
    senders[args._sender].push(lastId);
    recipients[args._recipient].push(lastId);

    usdc.approve(address(iPool), args._amount);
    iPool.supply(address(usdc), args._amount, trackReward[args._sender].rewardContract, 0);

    emit _Deposit(args._sender, args._recipient, lastId, args._fromChain, args._amount);
  }

  function depositAgain(
    uint256 _id,
    uint256 _amount
  ) external streamExist(_id) nonReentrant {
    require(_amount <= 2e8, "maximum deposit is 200 usdc");
    
    usdc.transferFrom(msg.sender, address(this), _amount);
    
    _depositAgain(
      _id,
      _amount,
      msg.sender,
      "Ethereum"
    );
  }

  function _depositAgain(
    uint256 _id,
    uint256 _amount,
    address _sender,
    string memory _fromChain
  ) internal {
    require(paymentStream[_id].sender == _sender, "you are not the sender");
    paymentStream[_id].amount += _amount;
    paymentStream[_id].remainingBalance += _amount;

    DPayReward payReward = DPayReward(trackReward[_sender].rewardContract);
    TotalValueLock += _amount;
    payReward.addTotalDeposit(_amount);

    usdc.approve(address(iPool), _amount);
    iPool.supply(address(usdc), _amount, trackReward[_sender].rewardContract,0);
    emit _DepositAgain(_sender, _id, _fromChain, _amount);
  }

  // withdraw function
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

  function claim() external isOwnerStream(msg.sender)  nonReentrant {
    // because of aave v3 usdc market cap has reach 100% on testnet, we need to add more reward by minting usdc 
    // let say that the additional reward is 0.0000001 usdc per seconds
    DPayReward payReward = DPayReward(trackReward[msg.sender].rewardContract);
    uint256 realReward = payReward.getClaimablePrize();
    uint256 additionalReward = (block.timestamp - trackReward[msg.sender].lastClaimTime);
    if(realReward.add(additionalReward) > 0) {
      if(realReward > 0) {
        payReward.withdraw(realReward);
      }
      aaveFaucet.mint(address(usdc), address(this), additionalReward);
      trackReward[msg.sender].lastClaimTime = block.timestamp;
      usdc.transfer(msg.sender, realReward.add(additionalReward));
      emit _claim(msg.sender, realReward.add(additionalReward));
    } else {
      revert('you dont have any reward to claim');
    }
  }

  // cancle function
  function cancle(
    uint256 _id
  ) external streamExist(_id) isSender(_id, msg.sender) nonReentrant {
    DPayReward payReward = DPayReward(trackReward[msg.sender].rewardContract);
    uint256 lastBalance = paymentStream[_id].remainingBalance;
    payReward.withdraw(lastBalance);
    paymentStream[_id].remainingBalance = 0;
    usdc.transfer(msg.sender, lastBalance);
    emit _cancle(msg.sender, _id, lastBalance);
  }

  function transfer(
    address _token,
    address _sender,
    uint256 _amount
  ) internal returns (bool) {
    IERC20(_token).transfer(_sender, _amount);
    return true;
  }

  // cross-chain receiver
  function _executeWithToken(
    string calldata sourceChain,
    string calldata,
    bytes calldata payload,
    string calldata tokenSymbol,
    uint256 amount
  ) internal override {
    address tokenAddress = gateway.tokenAddresses(tokenSymbol);
    Types.ExecuteToken memory args = abi.decode(payload, (Types.ExecuteToken));    
    if(tokenAddress == address(aUsdc)) {
      if(args.id > 0) {
        if(paymentStream[args.id].isEntity == false) {
          transfer(tokenAddress, args.recipient, amount);
          emit _error("paymentStream not exist!");
        } else {
          aaveFaucet.mint(address(usdc), address(this), amount);
          _depositAgain(
            args.id,
            amount,
            args.recipient, 
            sourceChain
          );
        }
      } else {
        if(amount < 1e8) {
          transfer(tokenAddress, args.recipient, amount);
          emit _error("minimum 100 usdc to create stream");
        } else {
          if(amount < args.amountPerTimes) {
            transfer(tokenAddress, args.recipient, amount);
            emit _error("amount should be larger than amountPerTimes");
          } else {
            aaveFaucet.mint(address(usdc), address(this), amount);
            Types.DepositDetail memory tps = Types.DepositDetail({
              _sender: args.sender,
              _amount: amount,
              _amountPerTimes: args.amountPerTimes,
              _recipient: args.recipient,
              _times: args.times,
              _fromChain: sourceChain
            });

            _deposit(
              tps
            );
          }
        }
      }
    } else {
      transfer(tokenAddress, args.recipient, amount);
      emit _error("token should be (a)usdc only");
    }
  }

  function _execute(
    string calldata sourceChain,
    string calldata sourceAddress,
    bytes calldata payload
  ) internal override {
    (uint256 _id, address recipient) = abi.decode(payload, (uint256, address));

    if(paymentStream[_id].isEntity == true && paymentStream[_id].receiver == recipient) {
      uint256 amountWithdraw = _withdraw(_id, recipient, sourceChain);
      bytes memory _payload = abi.encode(amountWithdraw, recipient);
      aUsdc.approve(address(gateway), amountWithdraw);
      gateway.callContractWithToken(sourceChain, sourceAddress, _payload, axlUSDC, amountWithdraw);
    } else {
      emit _error("stream not exist or you are not the recipient");
    }
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