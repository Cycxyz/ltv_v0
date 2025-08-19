// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {MaxWithdrawRedeemCollateralVaultState} from "src/structs/state/vault/MaxWithdrawRedeemCollateralVaultState.sol";
import {PreviewWithdrawVaultStateReader} from "src/state_reader/vault/PreviewWithdrawVaultStateReader.sol";

contract MaxWithdrawRedeemCollateralVaultStateReader is PreviewWithdrawVaultStateReader {
    function maxWithdrawRedeemCollateralVaultState(address owner)
        internal
        view
        returns (MaxWithdrawRedeemCollateralVaultState memory)
    {
        return MaxWithdrawRedeemCollateralVaultState({
            previewWithdrawVaultState: previewWithdrawVaultState(),
            maxSafeLTVDividend: maxSafeLTVDividend,
            maxSafeLTVDivider: maxSafeLTVDivider,
            ownerBalance: balanceOf[owner]
        });
    }
}
