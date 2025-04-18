// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../facades/reads/AutcionRead.sol";

import "../facades/writes/AuctionWrite.sol";
import '../facades/reads/ERC20Read.sol';
import '../facades/writes/ERC20Write.sol';

contract LTV is AuctionRead, AuctionWrite, ERC20Read, ERC20Write {

}