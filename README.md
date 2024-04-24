# Immunefi Proof of Concepts Repository

This repository contains all the proof of concepts (POCs) related to the articles published on the Immunefi Medium blog, [https://medium.com/immunefi](https://medium.com/immunefi).

## Table of Contents
| Name | Reward (USD) | POC | Article | Command
| ---- | ------- | ---- | ---- | ---- |
| Alchemix Missing Access Control | $28,730 | [AlchemixPoC](./src/Alchemix/NoAccessControlAttackContract.sol) | [Alchemix Missing Access Control]() | `forge test -vvv --match-path ./test/Alchemix/PoCNoAccessControl.t.sol` |
| Beanstalk logical vulnerability | $181,850 | [BeanStalkPoC](./test/BeanStalk.t.sol) | [Bugfix Review: Beanstalk Logic Error](https://medium.com/immunefi/beanstalk-logic-error-bugfix-review-4fea17478716) | `RPC_URL=$ALCHEMY_API forge test --match-contract BeanStalkPoC -vvv` |
| DFX Finance Rounding Error | $100,000 | [DFXFinancePoC](./src/DFXFinance/AttackContract.sol) | [Bugfix Review: DFX Finance Rounding Error](https://medium.com/immunefi/dfx-finance-rounding-error-bugfix-review-17ba5ffb4114) | `forge test -vvv --match-path ./test/DFXFinance/AttackTest.t.sol` |
| Yield protocol Logical Vulnerability | $95,000 | [YieldProtocolPoC](./test/YieldProtocol/AttackTest.t.sol) | [Bugfix Review: Yield Protocol Logic Error](https://medium.com/immunefi/yield-protocol-logic-error-bugfix-review-7b86741e6f50) | `forge test -vvv --match-path ./test/YieldProtocol/AttackTest.t.sol` |
| Balancer Rounding Error | $1,000,000 | [BalancerPoC](./test/Balancer/rounding-error-aug2023/BalancerPoC.sol) | [Bugfix Review: Balancer Rounding Error](https://medium.com/immunefi/balancer-rounding-error-bugfix-review-cbf69482ee3d) | `forge test -vvv --match-path ./test/Balancer/rounding-error-aug2023/BalancerPoC.sol` |
| Alchemix Missing Solvency Check | $116,513 | [AlchemixPoC](./test/Alchemix/PoCTest.sol) | [Bugfix Review: Alchemix Missing Solvency Check](https://medium.com/immunefi/alchemix-missing-solvency-check-bugfix-review-bcbc13289a12) | `forge test -vvv --match-path ./test/Alchemix/PoCTest.sol` |
| Astar Network Integer Truncation Bug | $50,000 | [AstarNetworkPoC](./src/AstarNetwork/AttackContract.sol) | [Bugfix Review: Astar Network Integer Truncation Error](https://medium.com/immunefi/astar-network-integer-truncation-error-bugfix-review-395e356b085c) | `forge test -vv --match-path ./test/AstarNetwork/AttackTest.t.sol` |
| Wormhole Uninitialized Proxy | $10,000,000 | [WormholePoC](./test/Wormhole/WormholeBugFix.t.sol) | [Bugfix Review: Wormhole Uninitialized Proxy](https://medium.com/immunefi/wormhole-uninitialized-proxy-bugfix-review-90250c41a43a) | `forge test -vvv --match-path ./test/Wormhole/WormholeBugFix.t.sol` |
| MEV PoC |  | [ForgeSandwichPOC](./test/MEV/Forge/Sandwich.t.sol) | [How To Reproduce A Simple MEV Attack](https://medium.com/immunefi/how-to-reproduce-a-simple-mev-attack-b38151616cb4) | `forge test -vvv --match-path ./test/MEV/Forge/Sandwich.t.sol` |

## Getting Started

Foundry is required to use this repository. See: https://book.getfoundry.sh/getting-started/installation.
