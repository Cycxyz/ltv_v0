// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../public/vault/collateral/execute/DepositCollateral.sol";
import "../public/vault/collateral/execute/MintCollateral.sol";
import "../public/vault/collateral/execute/RedeemCollateral.sol";
import "../public/vault/collateral/execute/WithdrawCollateral.sol";
import "../public/vault/collateral/convert/ConvertToAssetsCollateral.sol";
import "../public/vault/collateral/convert/ConvertToSharesCollateral.sol";

contract CollateralVaultModule is
    DepositCollateral,
    MintCollateral,
    RedeemCollateral,
    WithdrawCollateral,
    ConvertToAssetsCollateral,
    ConvertToSharesCollateral
{}
