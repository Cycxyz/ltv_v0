// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../Constants.sol";
import "../math/DepositWithdraw.sol";
import '../MaxGrowthFee.sol';

abstract contract PreviewWithdraw is MaxGrowthFee {
    using uMulDiv for uint256;

    function previewWithdraw(uint256 assets) public view returns (uint256 shares) {
        Prices memory prices = getPrices();
        int256 sharesInUnderlying = DepositWithdraw.previewDepositWithdraw(int256(assets), true, recoverConvertedAssets(), prices, targetLTV);

        if (sharesInUnderlying > 0) {
            return 0;
        } else {
            uint256 sharesInAssets = uint256(-sharesInUnderlying).mulDivDown(Constants.ORACLE_DIVIDER, getPrices().borrow);
            shares = sharesInAssets.mulDivDown(previewSupplyAfterFee(), totalAssets());
        }

        return shares;
    }
}
