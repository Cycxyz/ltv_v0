# LTV protocol: proof of concept

This is a proof of concept implementation of the LTV protocol: Curatorless Leveraged Tokenized Vault with a Constant Target Loan-To-Value Ratio

**THIS IS A PROOF OF CONCEPT IMPLEMENTATION AND SHOULD NOT BE USED IN PRODUCTION**

**PLEASE DONT EVEN TRY TO USE THIS IN PRODUCTION**

**IT'S RISKY AND NOT AUDITED**

## Build

To build the project, run:

```bash
forge build
```

## Original paper

The original paper can be found here:

[LTV: Curatorless Leveraged Tokenized Vault with a Constant Target Loan-To-Value Ratio](https://github.com/ltvprotocol/papers/blob/main/LTV_Curatorless_Leveraged_Tokenized_Vault_with_a_Constant_Target_Loan-To-Value_Ratio.pdf)

Abstract:

The proposed system is a Curatorless Leveraged Tokenized Vault (LTV) with a Constant Target Loan-To-Value (LTV) ratio. This vault operates without a central curator and allows users to deposit and withdraw funds while receiving tokenized shares representing their holdings. The architec- ture is based on two interconnected EIP4626 vaults. To ensure alignment with the target LTV, an auction-based stimulus system is employed, which incentivizes users to participate in rebalancing actions through rewards or fees. This approach also integrates basic level of MEV protection to guard against frontrunning and maintain system integrity.