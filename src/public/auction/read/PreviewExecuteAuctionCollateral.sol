// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "src/math/AuctionMath.sol";
import "src/math/AuctionStateToData.sol";
import "src/structs/state_transition/DeltaAuctionState.sol";

abstract contract PreviewExecuteAuctionCollateral is AuctionStateToData {
    function previewExecuteAuctionCollateral(int256 deltaUserCollateralAssets, AuctionState memory auctionState)
        external
        view
        returns (int256)
    {
        return _previewExecuteAuctionCollateral(deltaUserCollateralAssets, auctionStateToData(auctionState))
            .deltaUserBorrowAssets;
    }

    function _previewExecuteAuctionCollateral(int256 deltaUserCollateralAssets, AuctionData memory auctionData)
        internal
        pure
        returns (DeltaAuctionState memory)
    {
        return AuctionMath.calculateExecuteAuctionCollateral(deltaUserCollateralAssets, auctionData);
    }
}
