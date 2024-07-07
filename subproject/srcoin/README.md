# SRCoin

This project provides sample code for project administrators to publish Coin Contract. It can support the exchange between Supporter Ticket and Coin, facilitating entry into DEX trading.

1. Modify the configuration in [srcoin.move](./sources/srcoin.move).
2. Deploying this contract and get the `TreasuryCap` and `CoinMetadata`.
3. Send the `TreasuryCap` to the project administrator's address, which is the address holding the `ProjectAdminCap`.
4. The project administrator should call the init_swap function in [swap.move](../../sources/swap.move), where `T` is the `CoinType` published by this contract.
5. If you confirm that the `CoinMetadata` no longer needs to be modified, call `transfer::public_freeze_object(CoinMetadata)`.
