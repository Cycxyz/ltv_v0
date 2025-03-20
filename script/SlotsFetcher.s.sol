// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import '../src/ltv_lendings/GhostLTV.sol';
import 'forge-std/Script.sol';

contract SlotsFetcher is GhostLTV {
    function fetchSlots() public pure returns (string[] memory, uint256[] memory) {
        string[] memory variableNames = new string[](20);
        variableNames[0] = 'feeCollector';
        variableNames[1] = 'futureBorrowAssets';
        variableNames[2] = 'futureCollateralAssets';
        variableNames[3] = 'futureRewardBorrowAssets';
        variableNames[4] = 'futureRewardCollateralAssets';
        variableNames[5] = 'startAuction';
        variableNames[6] = 'baseTotalSupply';
        variableNames[7] = 'balanceOf';
        variableNames[8] = 'allowance';
        variableNames[9] = 'name';
        variableNames[10] = 'symbol';
        variableNames[11] = 'decimals';
        variableNames[12] = 'collateralToken';
        variableNames[13] = 'borrowToken';
        variableNames[14] = 'maxSafeLTV';
        variableNames[15] = 'minProfitLTV';
        variableNames[16] = 'targetLTV';
        variableNames[17] = 'isNotFirstTime';
        variableNames[18] = 'lendingProtocol';
        variableNames[19] = 'oracle';

        uint256[] memory values = new uint256[](20);
        assembly {
            mstore(add(values, 0x20), FEE_COLLECTOR.slot)
            mstore(add(values, add(0x20, mul(0x20, 1))), futureBorrowAssets.slot)
            mstore(add(values, add(0x20, mul(0x20, 2))), futureCollateralAssets.slot)
            mstore(add(values, add(0x20, mul(0x20, 3))), futureRewardBorrowAssets.slot)
            mstore(add(values, add(0x20, mul(0x20, 4))), futureRewardCollateralAssets.slot)
            mstore(add(values, add(0x20, mul(0x20, 5))), startAuction.slot)
            mstore(add(values, add(0x20, mul(0x20, 6))), baseTotalSupply.slot)
            mstore(add(values, add(0x20, mul(0x20, 7))), balanceOf.slot)
            mstore(add(values, add(0x20, mul(0x20, 8))), allowance.slot)
            mstore(add(values, add(0x20, mul(0x20, 9))), name.slot)
            mstore(add(values, add(0x20, mul(0x20, 10))), symbol.slot)
            mstore(add(values, add(0x20, mul(0x20, 11))), decimals.slot)
            mstore(add(values, add(0x20, mul(0x20, 12))), collateralToken.slot)
            mstore(add(values, add(0x20, mul(0x20, 13))), borrowToken.slot)
            mstore(add(values, add(0x20, mul(0x20, 14))), maxSafeLTV.slot)
            mstore(add(values, add(0x20, mul(0x20, 15))), minProfitLTV.slot)
            mstore(add(values, add(0x20, mul(0x20, 16))), targetLTV.slot)
            mstore(add(values, add(0x20, mul(0x20, 17))), isNotFirstTime.slot)
            mstore(add(values, add(0x20, mul(0x20, 18))), lendingProtocol.slot)
            mstore(add(values, add(0x20, mul(0x20, 19))), oracle.slot)
        }

        return (variableNames, values);
    }
}

// forge script -vv script/SlotsFetcher.s.sol:PrintSlots
contract PrintSlots is Script {
    function run() external {
        SlotsFetcher fetcher = new SlotsFetcher();
        (string[] memory variableNames, uint256[] memory values) = fetcher.fetchSlots();
        for (uint256 i = 0; i < variableNames.length; i++) {
            console.log(variableNames[i], values[i]);
        }
    }
}