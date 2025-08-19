// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {PreviewWithdrawVaultState} from "src/structs/state/vault/PreviewWithdrawVaultState.sol";

struct MaxWithdrawRedeemCollateralVaultState {
    PreviewWithdrawVaultState previewWithdrawVaultState;
    uint16 maxSafeLTVDividend;
    uint16 maxSafeLTVDivider;
    uint256 ownerBalance;
}
