// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import './Whitelist.sol';
import './FunctionStopper.sol';
import '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';

contract ERC20 is Whitelist, FunctionStopper, ReentrancyGuardUpgradeable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    error DepositIsDisabled();
    error WithdrawIsDisabled();

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external isFunctionAllowed isReceiverWhitelisted(recipient) nonReentrant returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external isFunctionAllowed isReceiverWhitelisted(recipient) nonReentrant returns (bool) {
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

    function _mint(address to, uint256 amount) internal isReceiverWhitelisted(to) {
        require(!isDepositDisabled, DepositIsDisabled());
        balanceOf[to] += amount;
        baseTotalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(!isWithdrawDisabled, WithdrawIsDisabled());
        balanceOf[from] -= amount;
        baseTotalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}
