// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "./utils/BalancedTest.t.sol";

contract MaxGrowthFeeTest is BalancedTest {
    function test_maxGrowthFee(address owner, address user)
        public
        initializeBalancedTest(owner, user, 10 ** 18, 0, 0, 0)
    {
        vm.stopPrank();
        vm.startPrank(owner);
        // multiplied total assets by 2
        oracle.setAssetPrice(address(collateralToken), 250 * 10 ** 18);

        // check that price grown not for 100% but for 80%. Precision tricks because of virtual assets
        assertEq(dummyLTV.convertToAssets(10 ** 18), 18 * 10 ** 17);
        vm.startPrank(user);
        borrowToken.approve(address(dummyLTV), 1000);
        dummyLTV.deposit(1000, user);
        assertEq(dummyLTV.convertToAssets(10 ** 18), 18 * 10 ** 17);
    }
}
