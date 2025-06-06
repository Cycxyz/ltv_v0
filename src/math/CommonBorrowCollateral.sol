// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../Constants.sol";
import "../structs/data/vault/Cases.sol";
import "../structs/state_transition/DeltaFuture.sol";
import "src/math/CasesOperator.sol";
import "../utils/MulDiv.sol";

library CommonBorrowCollateral {
    using uMulDiv for uint256;
    using sMulDiv for int256;

    // Future executor <=> executor conflict, round up to make auction more profitable
    function calculateDeltaFutureBorrowFromDeltaFutureCollateral(
        Cases memory ncase,
        int256 futureCollateral,
        int256 futureBorrow,
        int256 deltaFutureCollateral
    ) internal pure returns (int256) {
        // (cna + cmcb + cmbc + ceccb + cecbc) × ∆futureCollateral +
        // + (cecb + cebc) × ∆futureCollateral × futureBorrow / futureCollateral +
        // + (ceccb + cecbc) × (futureCollateral − futureBorrow)

        int256 deltaFutureBorrow =
            int256(int8(ncase.cna + ncase.cmcb + ncase.cmbc + ncase.ceccb + ncase.cecbc)) * deltaFutureCollateral;
        if (futureCollateral == 0) {
            return deltaFutureBorrow;
        }

        deltaFutureBorrow +=
            int256(int8(ncase.cecb + ncase.cebc)) * deltaFutureCollateral.mulDivUp(futureBorrow, futureCollateral);
        deltaFutureBorrow += int256(int8(ncase.ceccb + ncase.cecbc)) * (futureCollateral - futureBorrow);

        return deltaFutureBorrow;
    }

    // Future executor <=> executor conflict, round down to make auction more profitable
    function calculateDeltaFutureCollateralFromDeltaFutureBorrow(
        Cases memory ncase,
        int256 futureCollateral,
        int256 futureBorrow,
        int256 deltaFutureBorrow
    ) internal pure returns (int256) {
        int256 deltaFutureCollateral =
            int256(int8(ncase.cna + ncase.cmcb + ncase.cmbc + ncase.ceccb + ncase.cecbc)) * deltaFutureBorrow;
        if (futureCollateral == 0) {
            return deltaFutureCollateral;
        }

        deltaFutureCollateral +=
            int256(int8(ncase.cecb + ncase.cebc)) * deltaFutureBorrow.mulDivDown(futureCollateral, futureBorrow);
        deltaFutureCollateral += int256(int8(ncase.ceccb + ncase.cecbc)) * (futureBorrow - futureCollateral);

        return deltaFutureCollateral;
    }

    // Future executor <=> executor conflict, round down to make auction more profitable
    function calculateDeltaUserFutureRewardCollateral(
        Cases memory ncase,
        int256 futureCollateral,
        int256 userFutureRewardCollateral,
        int256 deltaFutureCollateral
    ) internal pure returns (int256) {
        // cecb × userFutureRewardCollateral × ∆futureCollateral / futureCollateral +
        // + ceccb × −userFutureRewardCollateral

        if (futureCollateral == 0) {
            return 0;
        }

        int256 deltaUserFutureRewardCollateral =
            int256(int8(ncase.cecb)) * userFutureRewardCollateral.mulDivDown(deltaFutureCollateral, futureCollateral);
        deltaUserFutureRewardCollateral -= int256(int8(ncase.ceccb)) * userFutureRewardCollateral;
        return deltaUserFutureRewardCollateral;
    }

    //  Fee collector <=> future executor conflict, round down to leave a bit more future reward collateral in the protocol
    function calculateDeltaProtocolFutureRewardCollateral(
        Cases memory ncase,
        int256 futureCollateral,
        int256 protocolFutureRewardCollateral,
        int256 deltaFutureCollateral
    ) internal pure returns (int256) {
        // cecb × userFutureRewardCollateral × ∆futureCollateral / futureCollateral +
        // + ceccb × −userFutureRewardCollateral

        if (futureCollateral == 0) {
            return 0;
        }

        int256 deltaProtocolFutureRewardCollateral =
            int256(int8(ncase.cecb)) * protocolFutureRewardCollateral.mulDivUp(deltaFutureCollateral, futureCollateral);
        deltaProtocolFutureRewardCollateral -= int256(int8(ncase.ceccb)) * protocolFutureRewardCollateral;
        return deltaProtocolFutureRewardCollateral;
    }

    // auction creator <=> future executor conflict, resolve in favor of future executor, round down to leave more rewards in protocol
    function calculateDeltaFuturePaymentCollateral(
        Cases memory ncase,
        int256 futureCollateral,
        int256 deltaFutureCollateral,
        uint256 collateralSlippage
    ) internal pure returns (int256) {
        // cmbc × −∆futureCollateral × collateralSlippage +
        // + cecbc × −(∆futureCollateral + futureCollateral) × collateralSlippage

        int256 deltaFuturePaymentCollateral = -int256(int8(ncase.cmbc))
            * deltaFutureCollateral.mulDivUp(int256(collateralSlippage), Constants.SLIPPAGE_PRECISION);
        deltaFuturePaymentCollateral -= int256(int8(ncase.cecbc))
            * (deltaFutureCollateral + futureCollateral).mulDivUp(int256(collateralSlippage), Constants.SLIPPAGE_PRECISION);

        return deltaFuturePaymentCollateral;
    }

    // auction executor <=> future auction executor conflict, resolve in favor of future executor, round up to leave more rewards in protocol
    function calculateDeltaUserFutureRewardBorrow(
        Cases memory ncase,
        int256 futureBorrow,
        int256 userFutureRewardBorrow,
        int256 deltaFutureBorrow
    ) internal pure returns (int256) {
        // cebc × userF utureRewardBorrow × ∆futureBorrow / futureBorrow +
        // + cecbc × −userFutureRewardBorrow

        if (futureBorrow == 0) {
            return 0;
        }

        int256 deltaUserFutureRewardBorrow =
            int256(int8(ncase.cebc)) * userFutureRewardBorrow.mulDivUp(deltaFutureBorrow, futureBorrow);
        deltaUserFutureRewardBorrow -= int256(int8(ncase.cecbc)) * userFutureRewardBorrow;

        return deltaUserFutureRewardBorrow;
    }

    // Fee collector <=> future executor conflict, round up to leave a bit more future reward borrow in the protocol
    function calculateDeltaProtocolFutureRewardBorrow(
        Cases memory ncase,
        int256 futureBorrow,
        int256 protocolFutureRewardBorrow,
        int256 deltaFutureBorrow
    ) internal pure returns (int256) {
        if (futureBorrow == 0) {
            return 0;
        }

        int256 deltaProtocolFutureRewardBorrow =
            int256(int8(ncase.cebc)) * protocolFutureRewardBorrow.mulDivUp(deltaFutureBorrow, futureBorrow);
        deltaProtocolFutureRewardBorrow -= int256(int8(ncase.cecbc)) * protocolFutureRewardBorrow;

        return deltaProtocolFutureRewardBorrow;
    }

    // auction creator <=> future executor conflict, resolve in favor of future executor, round up to leave more rewards in protocol
    function calculateDeltaFuturePaymentBorrow(
        Cases memory ncase,
        int256 futureBorrow,
        int256 deltaFutureBorrow,
        uint256 borrowSlippage
    ) internal pure returns (int256) {
        // cmcb × −∆futureBorrow × borrowSlippage +
        // + ceccb × −(∆futureBorrow + futureBorrow) × borrowSlippage

        int256 deltaFuturePaymentBorrow = -int256(int8(ncase.cmcb))
            * deltaFutureBorrow.mulDivDown(int256(borrowSlippage), Constants.SLIPPAGE_PRECISION);
        deltaFuturePaymentBorrow -= int256(int8(ncase.ceccb))
            * (deltaFutureBorrow + futureBorrow).mulDivDown(int256(borrowSlippage), Constants.SLIPPAGE_PRECISION);

        return deltaFuturePaymentBorrow;
    }
}
