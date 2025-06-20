// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../utils/BaseTest.t.sol";

contract ApproveTest is BaseTest {
    function test_approveAllowance(DefaultTestData memory defaultData, address user, uint256 approveAmount)
        public
        testWithPredefinedDefaultValues(defaultData)
    {
        vm.assume(user != address(0));
        vm.assume(user != defaultData.owner);
        vm.assume(approveAmount > 0);

        address owner = defaultData.owner;

        vm.startPrank(owner);

        assertEq(ltv.allowance(owner, user), 0);

        bool success = ltv.approve(user, approveAmount);
        assertTrue(success);
        assertEq(ltv.allowance(owner, user), approveAmount);
    }

    function test_bigNumbers(DefaultTestData memory defaultData, address user)
        public
        testWithPredefinedDefaultValues(defaultData)
    {
        vm.assume(user != address(0));
        vm.assume(user != defaultData.owner);

        address owner = defaultData.owner;

        vm.startPrank(owner);

        uint256 maxValue = type(uint256).max;

        bool success = ltv.approve(user, maxValue);
        assertTrue(success);
        assertEq(ltv.allowance(owner, user), maxValue);

        uint256 bigNumber = 2 ** 200;
        success = ltv.approve(user, bigNumber);
        assertTrue(success);
        assertEq(ltv.allowance(owner, user), bigNumber);
    }

    function test_smallNumbers(DefaultTestData memory defaultData, address user, uint256 smallAmount)
        public
        testWithPredefinedDefaultValues(defaultData)
    {
        vm.assume(user != address(0));
        vm.assume(user != defaultData.owner);
        vm.assume(smallAmount > 0 && smallAmount <= 10 ** 12);

        address owner = defaultData.owner;

        vm.startPrank(owner);

        bool success = ltv.approve(user, smallAmount);
        assertTrue(success);
        assertEq(ltv.allowance(owner, user), smallAmount);

        uint256 oneWei = 1;
        success = ltv.approve(user, oneWei);
        assertTrue(success);
        assertEq(ltv.allowance(owner, user), oneWei);

        uint256 oneGwei = 10 ** 9;
        success = ltv.approve(user, oneGwei);
        assertTrue(success);
        assertEq(ltv.allowance(owner, user), oneGwei);
    }

    function test_zero(DefaultTestData memory defaultData, address user, uint256 initialAmount)
        public
        testWithPredefinedDefaultValues(defaultData)
    {
        vm.assume(user != address(0));
        vm.assume(user != defaultData.owner);
        vm.assume(initialAmount > 0);

        address owner = defaultData.owner;

        vm.startPrank(owner);

        ltv.approve(user, initialAmount);
        assertEq(ltv.allowance(owner, user), initialAmount);

        bool success = ltv.approve(user, 0);
        assertTrue(success);
        assertEq(ltv.allowance(owner, user), 0);
    }

    function test_approveOverwrite(
        DefaultTestData memory defaultData,
        address user,
        uint256 firstAmount,
        uint256 secondAmount
    ) public testWithPredefinedDefaultValues(defaultData) {
        vm.assume(user != address(0));
        vm.assume(user != defaultData.owner);
        vm.assume(firstAmount > 0);
        vm.assume(secondAmount > 0);
        vm.assume(firstAmount != secondAmount);

        address owner = defaultData.owner;

        vm.startPrank(owner);

        ltv.approve(user, firstAmount);
        assertEq(ltv.allowance(owner, user), firstAmount);

        ltv.approve(user, secondAmount);
        assertEq(ltv.allowance(owner, user), secondAmount);

        assertNotEq(ltv.allowance(owner, user), firstAmount);
    }
}
