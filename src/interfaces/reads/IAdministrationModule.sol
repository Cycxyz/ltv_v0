// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

interface IAdministrationModule {
    function owner() external view returns (address);

    function guardian() external view returns (address);

    function governor() external view returns (address);

    function emergencyDeleverager() external view returns (address);
}
