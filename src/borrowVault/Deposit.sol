// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import '../StateTransition.sol';
import '../MaxGrowthFee.sol';
import '../Lending.sol';
import '../math/DepositWithdraw.sol';
import '../math/NextStep.sol';
import './MaxDeposit.sol';
import '../ERC4626Events.sol';

abstract contract Deposit is MaxDeposit, MaxGrowthFee, StateTransition, Lending, ERC4626Events {

    using uMulDiv for uint256;

    error ExceedsMaxDeposit(address receiver, uint256 assets, uint256 max);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        uint256 max = maxDeposit(address(receiver));
        require(assets <= max, ExceedsMaxDeposit(receiver, assets, max));

        ConvertedAssets memory convertedAssets = recoverConvertedAssets();
        Prices memory prices = getPrices();
        (int256 signedSharesInUnderlying, DeltaFuture memory deltaFuture) = DepositWithdraw.calculateDepositWithdraw(
            -1 * int256(assets),
            true,
            convertedAssets,
            prices,
            targetLTV
        );

        uint256 supplyAfterFee = previewSupplyAfterFee();
        if (signedSharesInUnderlying < 0) {
            return 0;
        } else {
            uint256 sharesInAssets = uint256(signedSharesInUnderlying).mulDivDown(Constants.ORACLE_DIVIDER, prices.borrow);
            shares = sharesInAssets.mulDivDown(supplyAfterFee, totalAssets());
        }

        // TODO: double check that Token should be transfered from msg.sender or from receiver
        borrowToken.transferFrom(msg.sender, address(this), assets);

        applyMaxGrowthFee(supplyAfterFee);

        if (deltaFuture.deltaProtocolFutureRewardBorrow < 0) {
            _mint(FEE_COLLECTOR, underlyingToShares(uint256(-deltaFuture.deltaProtocolFutureRewardBorrow)));
        }

        if (deltaFuture.deltaProtocolFutureRewardCollateral > 0) {
            _mint(FEE_COLLECTOR, underlyingToShares(uint256(deltaFuture.deltaProtocolFutureRewardCollateral)));
        }

        repay(assets);

        NextState memory nextState = NextStep.calculateNextStep(convertedAssets, deltaFuture, block.number);

        applyStateTransition(nextState);

        emit Deposit(msg.sender, receiver, assets, shares);

        _mint(receiver, shares);

        return shares;
    }
}
