// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "./PreviewDepositVaultState.sol";

struct MaxDepositMintBorrowVaultState {
    PreviewDepositVaultState previewDepositVaultState;
    uint256 maxTotalAssetsInUnderlying;
    uint256 minProfitLTV;
}
