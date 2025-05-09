// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../utils/MulDiv.sol";
import '../MaxGrowthFee.sol';

abstract contract ConvertToSharesCollateral is MaxGrowthFee {

    using uMulDiv for uint256;

    function convertToSharesCollateral(uint256 assets) external view virtual returns (uint256) {
        // assume smaller token price
        return assets.mulDivUp(previewSupplyAfterFee(), totalAssetsCollateral());
    }
}