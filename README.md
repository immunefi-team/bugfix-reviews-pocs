# Immunefi Proof of Concepts Repository

This repository contains all the proof of concepts (POCs) related to the articles published on the Immunefi Medium blog, [https://medium.com/immunefi](https://medium.com/immunefi).

## Table of Contents

| Name | Reward | POC | Article | Command
| ---- | ------- | ---- | ---- | ---- |
| Beanstalk logical vulnerability | $181,850 USD | [BeanStalkPoC](./test/BeanStalk.t.sol) | [BeanStalk Logical Vulnerability Postmoterm](https://medium.com/immunefi/beanstalk-logic-error-bugfix-review-4fea17478716) | `RPC_URL=$ALCHEMY_API forge test --match-contract BeanStalkPoC -vvv --via-ir`
| DFX Finance Rounding Error | $100,000 USD | [DFXFinancePoC](./src/DFXFinance/AttackContract.sol) | [DFX Finance Bugfix Review](https://medium.com/immunefi/dfx-finance-rounding-error-bugfix-review-17ba5ffb4114) | `forge test -vvv --match-path ./test/DFXFinance/AttackTest.t.sol --via-ir`
| Yield protocol Logical Vulnerability | $95,000 USD | [YieldProtocolPoC](./test/YieldProtocol/AttackTest.t.sol) | [Yield Protocol Bugfix Review](https://medium.com/immunefi/yield-protocol-logic-error-bugfix-review-7b86741e6f50) | `forge test -vvv --match-path ./test/YieldProtocol/AttackTest.t.sol --via-ir`
| Balancer Rounding Error | $1,000,000 USD | [BalancerPoC](./test/Balancer/rounding-error-aug2023/BalancerPoC.sol) | [Balancer Rounding Error Bugfix Review](https://medium.com/immunefi/balancer-rounding-error-bugfix-review-cbf69482ee3d) | `forge test -vvv --match-path ./test/Balancer/rounding-error-aug2023/BalancerPoC.sol --via-ir`
| Alchemix Missing Solvency Check | $116,513 USD | [AlchemixPoC](./test/Alchemix/PoCTest.sol) | [Alchemix Missing Solvency Check](https://medium.com/immunefi/alchemix-missing-solvency-check-bugfix-review-bcbc13289a12) | `forge test -vvv --match-path ./test/Alchemix/PoCTest.sol --via-ir`
| Astar Network Integer Truncation Bug | $50,000 USD | [AstarNetworkPoC](./src/AstarNetwork/AttackContract.sol) | [Astar Network Integer Truncation Bug](https://medium.com/immunefi/astar-network-integer-truncation-error-bugfix-review-395e356b085c) | `forge test -vv --match-path ./test/AstarNetwork/AttackTest.t.sol --via-ir`
| Wormhole Uninitialized Proxy | $10,000,000 USD | [WormholePoC](./test/Wormhole/WormholeBugFix.t.sol) | [Wormhole Uninitialized Proxy](https://medium.com/immunefi/wormhole-uninitialized-proxy-bugfix-review-90250c41a43a) | `forge test -vvv --match-path ./test/Wormhole/WormholeBugFix.t.sol --via-ir`
| MEV POC |  | [ForgeSandwichPOC](./test/MEV/Forge/Sandwich.t.sol) | [MEV POC Article](https://medium.com/immunefi/how-to-reproduce-a-simple-mev-attack-b38151616cb4) | `forge test -vvv --match-path ./test/MEV/Forge/Sandwich.t.sol --via-ir`

## Getting Started

Foundry is required to use this repository. See: https://book.getfoundry.sh/getting-started/installation.
