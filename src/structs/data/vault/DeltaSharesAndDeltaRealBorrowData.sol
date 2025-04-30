// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "./Cases.sol";

struct DeltaSharesAndDeltaRealBorrowData {
    uint128 targetLTV;
    int256 borrow;
    int256 collateral;
    int256 protocolFutureRewardBorrow;
    int256 protocolFutureRewardCollateral;
    int256 deltaShares;
    int256 deltaRealBorrow;
    int256 userFutureRewardBorrow;
    int256 futureBorrow;
    uint256 borrowSlippage;
    Cases cases;
} 