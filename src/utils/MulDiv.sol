// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

// TODO: refactor to UMulDiv or UnsignedMulDiv
library uMulDiv {
    uint256 internal constant MAX_UINT256 = 2 ** 256 - 1;

    function mulDivDown(uint256 factorA, uint256 factorB, uint256 denominator) internal pure returns (uint256 result) {
        require(denominator != 0, "Denominator cannot be zero");

        /// @solidity memory-safe-assembly
        assembly {
            if iszero(mul(denominator, iszero(mul(factorB, gt(factorA, div(MAX_UINT256, factorB)))))) { revert(0, 0) }

            result := div(mul(factorA, factorB), denominator)
        }
    }

    function mulDivUp(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 z) {
        require(denominator != 0, "Denominator cannot be zero");
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) { revert(0, 0) }

            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }

    function mulDiv(uint256 x, uint256 y, uint256 denominator, bool isUp) internal pure returns (uint256) {
        if (isUp) {
            return mulDivUp(x, y, denominator);
        } else {
            return mulDivDown(x, y, denominator);
        }
    }
}

// TODO: refactor to SMulDiv or SignedMulDiv
library sMulDiv {
    // Maximum value of a signed 256-bit integer
    int256 internal constant MAX_INT256 = type(int256).max;

    // Minimum value of a signed 256-bit integer
    int256 internal constant MIN_INT256 = type(int256).min;

    function mulDivDown(int256 x, int256 y, int256 denominator) internal pure returns (int256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Early return for zero denominator
            if iszero(denominator) { revert(0, 0) }

            let anyZero := or(iszero(x), iszero(y))
            // Early return for zero inputs
            if anyZero { result := 0 }

            if iszero(anyZero) {
                // Get signs using bit manipulation (most significant bit)
                let xSign := shr(255, x)
                let ySign := shr(255, y)
                let denomSign := shr(255, denominator)

                // Convert to absolute values using bit manipulation
                let xAbs :=
                    add(
                        xor(x, add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, iszero(xSign))),
                        xSign
                    )
                let yAbs :=
                    add(
                        xor(y, add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, iszero(ySign))),
                        ySign
                    )
                let denomAbs :=
                    add(
                        xor(
                            denominator,
                            add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, iszero(denomSign))
                        ),
                        denomSign
                    )

                if gt(xAbs, div(0x8000000000000000000000000000000000000000000000000000000000000000, yAbs)) {
                    revert(0, 0)
                }

                // Perform multiplication
                let productAbs := mul(xAbs, yAbs)

                // Perform division
                let divisionAbs := div(productAbs, denomAbs)

                // Determine if we need to round down
                // If product and denominator have same sign, division is already correct
                // If different signs and there's remainder, we need to subtract 1
                let division := divisionAbs

                let resultNegative := and(add(add(xSign, ySign), denomSign), 1)

                if resultNegative {
                    if mod(productAbs, denomAbs) {
                        divisionAbs := add(divisionAbs, 1)
                    }

                    if gt(divisionAbs, 0x8000000000000000000000000000000000000000000000000000000000000000) {
                        revert(0, 0)
                    }

                    division :=
                        xor(sub(divisionAbs, 1), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                }

                if iszero(resultNegative) {
                    if gt(divisionAbs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
                        revert(0, 0)
                    }
                }

                result := division
            }
        }
    }

    function mulDivUp(int256 x, int256 y, int256 denominator) internal pure returns (int256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Early return for zero denominator
            if iszero(denominator) { revert(0, 0) }

            let anyZero := or(iszero(x), iszero(y))
            // Early return for zero inputs
            if anyZero { result := 0 }

            if iszero(anyZero) {
                // Get signs using bit manipulation (most significant bit)
                let xSign := shr(255, x)
                let ySign := shr(255, y)
                let denomSign := shr(255, denominator)

                // Convert to absolute values using bit manipulation
                let xAbs :=
                    add(
                        xor(x, add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, iszero(xSign))),
                        xSign
                    )
                let yAbs :=
                    add(
                        xor(y, add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, iszero(ySign))),
                        ySign
                    )
                let denomAbs :=
                    add(
                        xor(
                            denominator,
                            add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, iszero(denomSign))
                        ),
                        denomSign
                    )

                if gt(xAbs, div(0x8000000000000000000000000000000000000000000000000000000000000000, yAbs)) {
                    revert(0, 0)
                }

                let productAbs := mul(xAbs, yAbs)
                let divisionAbs := div(productAbs, denomAbs)
                let division := divisionAbs

                let resultNegative := and(add(add(xSign, ySign), denomSign), 1)
                if iszero(resultNegative) {
                    if mod(productAbs, denomAbs) {
                        division := add(divisionAbs, 1)
                    }

                    if gt(divisionAbs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
                        revert(0, 0)
                    }
                }

                if resultNegative {
                    if gt(divisionAbs, 0x8000000000000000000000000000000000000000000000000000000000000000) {
                        revert(0, 0)
                    }

                    division :=
                        xor(sub(divisionAbs, 1), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                }

                result := division
            }
        }
    }

    function mulDiv(int256 x, int256 y, int256 denominator, bool isUp) internal pure returns (int256) {
        if (isUp) {
            return mulDivUp(x, y, denominator);
        } else {
            return mulDivDown(x, y, denominator);
        }
    }
}
