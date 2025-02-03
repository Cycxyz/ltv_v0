// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import '../../src/dummy/DummyLending.sol';

contract MockDummyLending is DummyLending {
    constructor(address initialOwner) DummyLending(initialOwner) {}

    function setSupplyBalance(address asset, uint256 amount) public {
        supplyBalance[asset] = amount;
    }

    function setBorrowBalance(address asset, uint256 amount) public {
        borrowBalance[asset] = amount;
    }
}