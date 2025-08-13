// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import "../src/utils/MulDiv.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

library AnotherMulDiv {
    int256 internal constant MAX_INT256 = type(int256).max;
    int256 internal constant MIN_INT256 = type(int256).min;
    uint256 internal constant MAX_UINT256 = 2 ** 256 - 1;

    function mulDivDown(int256 x, int256 y, int256 denominator) internal pure returns (int256) {
        require(denominator != 0, "Denominator cannot be zero");
        if (x == 0 || y == 0) {
            return 0;
        }

        unchecked {
            uint8 xPositive = x > 0 ? 1 : 0;
            uint8 yPositive = y > 0 ? 1 : 0;
            uint8 denominatorPositive = denominator > 0 ? 1 : 0;

            uint256 xAbs = xPositive == 0 ? uint256(-x) : uint256(x);
            uint256 yAbs = yPositive == 0 ? uint256(-y) : uint256(y);
            uint256 denominatorAbs = denominatorPositive == 0 ? uint256(-denominator) : uint256(denominator);

            if (xAbs > MAX_UINT256 / yAbs) {
                revert("Multiplication overflow detected");
            }

            uint256 product = xAbs * yAbs;
            uint256 result = product / denominatorAbs;

            if ((xPositive + yPositive + denominatorPositive) % 2 == 0) {
                uint256 remainder = product % denominatorAbs;
                if (result == uint256(-MIN_INT256)) {
                    require(remainder == 0, "Multiplication overflow detected");
                    return MIN_INT256;
                }

                if (remainder != 0) {
                    require(result <= uint256(-MIN_INT256) - 1, "Multiplication overflow detected");
                    return -int256(result) - 1;
                }

                return -int256(result);
            } else {
                require(result <= uint256(MAX_INT256), "Multiplication overflow detected");
                return int256(result);
            }
        }
    }
}

library OldMath {
    int256 internal constant MAX_INT256 = type(int256).max;
    int256 internal constant MIN_INT256 = type(int256).min;

    function mulDivDown(int256 x, int256 y, int256 denominator) internal pure returns (int256) {
        unchecked {
            require(denominator != 0, "Denominator cannot be zero");

            if (y != 0 && x != 0) {
                if (x > 0 && y > 0) {
                    require(x <= MAX_INT256 / y, "Multiplication overflow detected");
                }

                if (x < 0 && y < 0) {
                    require(x >= MAX_INT256 / y, "Multiplication overflow detected");
                }

                if (x > 0 && y < 0) {
                    // MIN_INT256 / (-1) trick
                    require(y >= MIN_INT256 / x, "Multiplication overflow detected");
                }

                if (x < 0 && y > 0) {
                    require(x >= MIN_INT256 / y, "Multiplication overflow detected");
                }
            } else {
                return 0;
            }

            // Perform the multiplication
            int256 product = x * y;

            if (product == MIN_INT256) {
                require(denominator != -1, "Division overflow");
            }

            int256 division = product / denominator;

            // if result is positive, then division returned number rounded towards zero, so mulDivDown is satisfied
            if ((product > 0 && denominator > 0) || (product < 0 && denominator < 0)) {
                return division;
            }

            // if result is negative or zero, then division rounded up, so we need to round down
            if (product % denominator != 0) {
                require(division != MIN_INT256, "Subtraction overflow");

                division -= 1;
            }

            return division;
        }
    }
}

library OldMathOptimized {
    int256 internal constant MAX_INT256 = type(int256).max;
    int256 internal constant MIN_INT256 = type(int256).min;

    function mulDivDown(int256 x, int256 y, int256 denominator) internal pure returns (int256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Early return for zero denominator
            if iszero(denominator) { revert(0, 0) }

            // Early return for zero inputs
            let anyZero := or(iszero(x), iszero(y))
            if anyZero { result := 0 }

            if iszero(anyZero) {
                // Get signs using bit manipulation (most significant bit)
                let xSign := shr(255, x)
                let ySign := shr(255, y)
                let denomSign := shr(255, denominator)

                // x > 0 && y > 0: check x <= MAX_INT256 / y
                if and(iszero(xSign), iszero(ySign)) {
                    if gt(x, sdiv(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, y)) {
                        revert(0, 0)
                    }
                }

                // x < 0 && y < 0: check x >= MAX_INT256 / y
                if and(xSign, ySign) {
                    if lt(x, sdiv(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, y)) {
                        revert(0, 0)
                    }
                }

                // x > 0 && y < 0: check y >= MIN_INT256 / x
                if and(iszero(xSign), ySign) {
                    if lt(y, sdiv(0x8000000000000000000000000000000000000000000000000000000000000000, x)) {
                        revert(0, 0)
                    }
                }

                // x < 0 && y > 0: check x >= MIN_INT256 / y
                if and(xSign, iszero(ySign)) {
                    if lt(x, sdiv(0x8000000000000000000000000000000000000000000000000000000000000000, y)) {
                        revert(0, 0)
                    }
                }

                // Perform multiplication
                let product := mul(x, y)

                // Handle special case: product == MIN_INT256
                if eq(product, 0x8000000000000000000000000000000000000000000000000000000000000000) {
                    if eq(denominator, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
                        revert(0, 0)
                    }
                }

                // Perform division
                let division := sdiv(product, denominator)

                // Determine if result should be positive or negative
                let productSign := shr(255, product)
                let shouldBePositive := eq(productSign, denomSign)

                if shouldBePositive {
                    // Result should be positive, division is already correct
                    result := division
                }

                if iszero(shouldBePositive) {
                    // Result should be negative, check if we need to round down
                    if smod(product, denominator) {
                        division := sub(division, 1)
                    }
                    result := division
                }
            }
        }
    }
}

contract GasMeterTest is Test {
    function setUp() public {}

    function test_gas_meter() public {
        int256 one = 52342562;
        int256 two = -32352562;
        int256 three = -8234;
        uint256 gasStart = gasleft();
        sMulDiv.mulDivDown(one, two, three);
        uint256 gasEnd = gasleft();
        console.log("result", sMulDiv.mulDivDown(one, two, three));
        console.log("Fancy math Gas used:", gasStart - gasEnd);
        // console.log("res up", sMulDiv.mulDivUp(5, 3, 8));
        gasStart = gasleft();
        OldMath.mulDivDown(one, two, three);
        gasEnd = gasleft();
        console.log("result", OldMath.mulDivDown(one, two, three));
        console.log("Old math gas used:", gasStart - gasEnd);

        gasStart = gasleft();
        AnotherMulDiv.mulDivDown(one, two, three);
        gasEnd = gasleft();
        console.log("result", AnotherMulDiv.mulDivDown(one, two, three));
        console.log("Fancy math unoptimized Gas used:", gasStart - gasEnd);

        gasStart = gasleft();
        uMulDiv.mulDivUp(5, 3, 8);
        gasEnd = gasleft();
        console.log("result", uMulDiv.mulDivUp(5, 3, 8));
        console.log("UMulDiv Gas used:", gasStart - gasEnd);

        gasStart = gasleft();
        OldMathOptimized.mulDivDown(one, two, three);
        gasEnd = gasleft();
        console.log("result", OldMathOptimized.mulDivDown(one, two, three));
        console.log("OldMathOptimized Gas used:", gasStart - gasEnd);
    }
}

contract _Test {
    function test(int256 product) public pure {
        assembly {
            if sgt(product, 0) { revert(0, 0) }
            // if add(gt(product, 0), gt(denominator, 0)) {
            //     return (division, 32)
            // }

            // if add(lt(product, 0), lt(denominator, 0)) {
            //     return (division, 32)
            // }
        }
    }
}
