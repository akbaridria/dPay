// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAaveFaucet {
    function mint(address token, address to, uint256 amount) external returns (uint256);
}
