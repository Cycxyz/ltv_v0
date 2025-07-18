// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../../errors/IAdministrationErrors.sol";

abstract contract CommonWrite {
    function _delegate(address implementation, bytes memory encodedParams) internal {
        (bool success, bytes memory returndata) = implementation.delegatecall(bytes.concat(msg.sig, encodedParams));

        if (success) {
            if (returndata.length == 0 && implementation.code.length == 0) {
                revert IAdministrationErrors.EOADelegateCall();
            }

            assembly {
                return(add(returndata, 32), mload(returndata))
            }
        }

        assembly {
            revert(add(returndata, 32), mload(returndata))
        }
    }
}
