// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import '../LTV.sol';
import '../dummy/interfaces/IDummyLending.sol';
import '../dummy/interfaces/IDummyOracle.sol';

contract DummyLTV is LTV {
    IDummyLending private lendingProtocol;
    IDummyOracle private oracle;

    constructor(address initialOwner, IDummyLending _lendingProtocol, IDummyOracle _oracle) LTV(initialOwner) {
        lendingProtocol = _lendingProtocol;
        oracle = _oracle;
    }
    
    function getPriceBorrowOracle() public view override returns (uint256) {
        return oracle.getAssetPrice(address(borrowToken));
    }

    function getPriceCollateralOracle() public view override returns (uint256) {
        return oracle.getAssetPrice(address(collateralToken));
    }

    function getRealBorrowAssets() public view override returns (uint256) {
        return lendingProtocol.supplyBalance(address(borrowToken));
    }

    function getRealCollateralAssets() public view override returns (uint256) {
        return lendingProtocol.borrowBalance(address(collateralToken));
    }

    function setLendingProtocol(IDummyLending _lendingProtocol) public {
        lendingProtocol = _lendingProtocol;
    }

    function setOracle(IDummyOracle _oracle) public {
        oracle = _oracle;
    }

    function borrow(uint256 assets) internal override {
        lendingProtocol.borrow(address(borrowToken), assets);
    }

    function repay(uint256 assets) internal override {
        lendingProtocol.repay(address(borrowToken), assets);
    }

    function supply(uint256 assets) internal override {
        lendingProtocol.supply(address(collateralToken), assets);
    }

    function withdraw(uint256 assets) internal override {
        lendingProtocol.withdraw(address(collateralToken), assets);
    }
}