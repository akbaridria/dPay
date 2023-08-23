// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {AddressToString} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/AddressString.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Types.sol";
contract DPayConnector is AxelarExecutable, Ownable {
  using AddressToString for address;

  // variables
  IAxelarGasService gasReceiver;
  IERC20 aUsdc;
  string public destinationChain = 'ethereum-2';
  string public axlUsdc = 'aUSDC';
  address public destinationAddress;

  // modifiers

  // events
  event _deposit(address indexed _fromAddress, uint256 _amount);
  event _depositAgain(address indexed _fromAddress, uint256 indexed _id, uint256 _amount);
  event _withdraw(address indexed _fromAddress, uint256 indexed _id);

  // constructor
  constructor(
    address _gateway,
    address _gasReceiver,
    address _ausdc,
    address _dpay
  ) AxelarExecutable(_gateway) {
    gasReceiver = IAxelarGasService(_gasReceiver);
    aUsdc = IERC20(_ausdc);
    destinationAddress = _dpay;
  }

  function deposit(
    uint256 _amount,
    uint256 _amountPerTimes,
    string memory _times,
    address _recipient
  ) external payable {
    require(aUsdc.balanceOf(msg.sender) >= _amount, "insufficient balance");
    require(_amount >= _amountPerTimes, "amount should be larger than amountPerTimes");
    require(_recipient != msg.sender, "sender and recipient can't be the same");
    require(_recipient != address(0), "recipient can't be zero address");
    require(_amount <= 2e8, "maximum deposit is 200 usdc");

    aUsdc.transferFrom(msg.sender, address(this), _amount);

    Types.ExecuteToken memory tps = Types.ExecuteToken({
      amountPerTimes: _amountPerTimes,
      times: _times,
      recipient: _recipient,
      id: 0,
      sender: msg.sender
    });

    bytes memory _payload = abi.encode(tps);

    aUsdc.approve(address(gateway), _amount);

    // call gas service
    gasReceiver.payNativeGasForContractCallWithToken{value: msg.value}(
      msg.sender, 
      destinationChain, 
      destinationAddress.toString(), 
      _payload, 
      axlUsdc, 
      _amount, 
      msg.sender
    );
    // call bridge
    gateway.callContractWithToken(destinationChain, destinationAddress.toString(), _payload, axlUsdc, _amount);

    emit _deposit(msg.sender, _amount);
  }

  function depositAgain(
    uint256 _id,
    uint256 _amount
  ) external payable {
    require(aUsdc.balanceOf(msg.sender) >= _amount, "insufficient balance");
    require(_amount <= 2e8, "maximum deposit is 200 usdc");

    aUsdc.transferFrom(msg.sender, address(this), _amount);

    Types.ExecuteToken memory tps = Types.ExecuteToken({
      amountPerTimes: 0,
      times: '',
      recipient: msg.sender,
      id: _id,
      sender: address(0)
    });

    bytes memory _payload = abi.encode(tps);

    aUsdc.approve(address(gateway), _amount);

    // call gas servvice
    gasReceiver.payNativeGasForContractCallWithToken{value: msg.value}(
      msg.sender, 
      destinationChain, 
      destinationAddress.toString(), 
      _payload, 
      axlUsdc, 
      _amount, 
      msg.sender
    );
    // call bridge
    
    gateway.callContractWithToken(destinationChain, destinationAddress.toString(), _payload, axlUsdc, _amount);
    emit _depositAgain(msg.sender, _id, _amount);
  }

  function withdraw(
    uint256 _id
  ) external payable {
    bytes memory tps = abi.encode(_id, msg.sender);

    // call gas service
    gasReceiver.payNativeGasForContractCall{value: msg.value}(
      msg.sender, 
      destinationChain, 
      destinationAddress.toString(), 
      tps, 
      msg.sender
    );
    // call bridge
    gateway.callContract(destinationChain, destinationAddress.toString(), tps);
    emit _withdraw(msg.sender, _id);
  }

  function _executeWithToken(
    string calldata,
    string calldata,
    bytes calldata payload,
    string calldata,
    uint256 amount
  ) internal override {
    address recipient = abi.decode(payload, (address));
    aUsdc.transfer(recipient, amount);
  }
}