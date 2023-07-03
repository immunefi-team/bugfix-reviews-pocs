# Immunefi Proof of Concepts Repository

This repository contains all the proof of concepts (POCs) related to the articles published on the Immunefi Medium blog, [https://medium.com/immunefi](https://medium.com/immunefi).

## Table of Contents

| Name | POC | Article | Command
| ---- | ------- | ---- | ---- | 
| Beanstalk logical vulnerability | [BeanStalkPoC](./test/BeanStalk.t.sol) | [BeanStalk Logical Vulnerability Postmoterm](https://medium.com/immunefi/article1) | `RPC_URL=$ALCHEMY_API forge test --match-contract BeanStalkPoC -vvv`
| DFX Finance Rounding Error | [DFXFinancePoC](./src/DFXFinance/AttackContract.sol) | [DFX Finance Bugfix Review](https://medium.com/immunefi/) | `forge test -vvv --match-path ./test/DFXFinance/AttackTest.t.sol`
| Yield protocol Logical Vulnerability| [YieldProtocolPoC](./test/YieldProtocol.t.sol) | [Yield Protocol Bugfix Review](https://medium.com/immunefi/) | `forge test --match-test testStrategyV2DAI6MMSWithDeal -vv`


## Getting Started

Foundry is required to use this repository. See: https://book.getfoundry.sh/getting-started/installation.
