// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import 'src/math2/VaultCollateral.sol';
import '../../../../math2/DepositWithdraw.sol';
import 'forge-std/console.sol';

abstract contract PreviewWithdrawCollateral is VaultCollateral {
    using uMulDiv for uint256;

    function previewWithdrawCollateral(uint256 assets, PreviewVaultState memory state) public pure returns (uint256 shares) {
        (shares, ) = _previewWithdrawCollateral(assets, previewVaultStateToPreviewCollateralVaultData(state, false));
    }

    function _previewWithdrawCollateral(uint256 assets, PreviewCollateralVaultData memory data) internal pure returns (uint256, DeltaFuture memory) {
        // HODLer <=> withdrawer conflict, assume user withdraws more to burn more shares
        uint256 assetsInUnderlying = assets.mulDivUp(data.collateralPrice, Constants.ORACLE_DIVIDER);

        (int256 sharesInUnderlying, DeltaFuture memory deltaFuture) = DepositWithdraw.calculateDepositWithdraw(
            DepositWithdrawData({
                collateral: data.collateral,
                borrow: data.borrow,
                futureBorrow: data.futureBorrow,
                futureCollateral: data.futureCollateral,
                userFutureRewardBorrow: data.userFutureRewardBorrow,
                userFutureRewardCollateral: data.userFutureRewardCollateral,
                protocolFutureRewardBorrow: data.protocolFutureRewardBorrow,
                protocolFutureRewardCollateral: data.protocolFutureRewardCollateral,
                collateralSlippage: data.collateralSlippage,
                borrowSlippage: data.borrowSlippage,
                targetLTV: data.targetLTV,
                deltaRealCollateral: -int256(assetsInUnderlying),
                deltaRealBorrow: 0
            })
        );

        console.log("sharesInUnderlying", sharesInUnderlying);

        if (sharesInUnderlying > 0) {
            return (0, deltaFuture);
        }

        console.log("totalAssetsCollateral", data.totalAssetsCollateral);
        console.log("supplyAfterFee", data.supplyAfterFee);

        // HODLer <=> withdrawer conflict, round in favor of HODLer, round up to burn more shares
        return (
            uint256(-sharesInUnderlying).mulDivUp(Constants.ORACLE_DIVIDER, data.collateralPrice).mulDivUp(
                data.supplyAfterFee,
                data.totalAssetsCollateral
            ),
            deltaFuture
        );
    }
}
