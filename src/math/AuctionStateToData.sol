// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {AuctionState} from "src/structs/state/AuctionState.sol";
import {AuctionData} from "src/structs/data/AuctionData.sol";
import {CommonMath} from "src/math/CommonMath.sol";

/**
 * @title AuctionStateToData
 * @notice Contract contains functionality to precalculate pure auction state to data needed for auction calculations.
 */
abstract contract AuctionStateToData {
    /**
     * @notice Precalculates pure auction state to data needed for auction calculations.
     */
    function auctionStateToData(AuctionState memory auctionState) internal view returns (AuctionData memory) {
        return AuctionData({
            futureBorrowAssets: auctionState.futureBorrowAssets,
            futureCollateralAssets: auctionState.futureCollateralAssets,
            futureRewardBorrowAssets: auctionState.futureRewardBorrowAssets,
            futureRewardCollateralAssets: auctionState.futureRewardCollateralAssets,
            auctionStep: CommonMath.calculateAuctionStep(
                auctionState.startAuction, uint56(block.number), auctionState.auctionDuration
            ),
            auctionDuration: auctionState.auctionDuration
        });
    }
}
