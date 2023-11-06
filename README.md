# Immunefi Proof of Concepts Repository

This repository contains all the proof of concepts (POCs) related to the articles published on the Immunefi Medium blog, [https://medium.com/immunefi](https://medium.com/immunefi).

## Table of Contents

| Name | POC | Article | Command
| ---- | ------- | ---- | ---- | 
| Beanstalk logical vulnerability | [BeanStalkPoC](./test/BeanStalk.t.sol) | [BeanStalk Logical Vulnerability Postmoterm](https://medium.com/immunefi/article1) | `RPC_URL=$ALCHEMY_API forge test --match-contract BeanStalkPoC -vvv`
| DFX Finance Rounding Error | [DFXFinancePoC](./src/DFXFinance/AttackContract.sol) | [DFX Finance Bugfix Review](https://medium.com/immunefi/) | `forge test -vvv --match-path ./test/DFXFinance/AttackTest.t.sol`
| Yield protocol Logical Vulnerability| [YieldProtocolPoC](./test/YieldProtocol.t.sol) | [Yield Protocol Bugfix Review](https://medium.com/immunefi/) | `forge test -vvv --match-path ./test/YieldProtocol/AttackTest.t.sol`
| MEV POC| [ForgeSandwichPOC](./test/MEV/Forge/Sandwich.t.sol) | [MEV POC Article](https://medium.com/immunefi/how-to-reproduce-a-simple-mev-attack-b38151616cb4) | `forge test -vvv --match-path ./test/MEV/Forge/Sandwich.t.sol`
| Balancer Rounding Error | [BalancerPoC](./test/Balancer/rounding-error-aug2023/BalancerPoC.sol) | [Balancer Rounding Error Bugfix Review](https://medium.com/immunefi/) | `forge test -vvv --match-path ./test/Balancer/rounding-error-aug2023/BalancerPoC.sol`
| Alchemix Missing Solvency Check | [AlchemixPoC](./test/Alchemix/AttackContract.sol) | [Alchemix Missing Solvency Check](https://medium.com/immunefi/) | `forge test -vvv --match-path ./test/Alchemix/PoCTest.sol --via-ir`


## Getting Started

Foundry is required to use this repository. See: https://book.getfoundry.sh/getting-started/installation.
