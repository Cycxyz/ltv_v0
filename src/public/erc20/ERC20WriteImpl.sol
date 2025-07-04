// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "src/modifiers/WhitelistModifier.sol";
import "src/modifiers/FunctionStopperModifier.sol";
import "src/events/IERC20Events.sol";
import "src/errors/IERC20Errors.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "src/state_transition/ERC20.sol";

abstract contract ERC20WriteImpl is
    WhitelistModifier,
    FunctionStopperModifier,
    ReentrancyGuardUpgradeable,
    IERC20Events,
    IERC20Errors,
    ERC20
{
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        isFunctionAllowed
        isReceiverWhitelisted(recipient)
        nonReentrant
        returns (bool)
    {
        if (recipient == address(0)) {
            revert TransferToZeroAddress();
        }
        _spendAllowance(sender, msg.sender, amount);
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        external
        isFunctionAllowed
        isReceiverWhitelisted(recipient)
        nonReentrant
        returns (bool)
    {
        if (recipient == address(0)) {
            revert TransferToZeroAddress();
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external isFunctionAllowed nonReentrant returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}
