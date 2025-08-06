// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "src/structs/state/MaxGrowthFeeState.sol";

struct PreviewLowLevelRebalanceState {
    MaxGrowthFeeState maxGrowthFeeState;
    uint256 depositRealBorrowAssets;
    uint256 depositRealCollateralAssets;
    uint16 targetLTVDividend;
    uint16 targetLTVDivider;
    uint64 blockNumber;
    uint64 startAuction;
}
