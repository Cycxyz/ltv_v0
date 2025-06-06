// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "src/structs/state/AuctionState.sol";

interface IAuctionModule {
    function previewExecuteAuctionBorrow(int256 deltaUserBorrowAssets, AuctionState memory auctionState)
        external
        view
        returns (int256);

    function previewExecuteAuctionCollateral(int256 deltaUserCollateralAssets, AuctionState memory auctionState)
        external
        view
        returns (int256);
}
