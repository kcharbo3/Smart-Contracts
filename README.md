# Smart-Contracts
There are currently two smart contracts: an escrow service contract and a multi-signature wallet contract.

## Escrow Service:
This contract acts as an escrow service. Essentially, it acts as the middle man between two parties who are exchanging money for a service or item. The seller of the service or item must initiate the contract with the address of the buyer and the cost he/she is selling it for. Then, both parties must commit two times the selling price to the contract for it to hold. This is done via the buyerPay() and sellerPay() methods. The contract holds on to these items until the buyer calls the recievedItem() function when the buyer has recieved the item or service (it has an onlyBuyer modifier so only the buyer can call this function). 

Once the recievedItem() function is called, the contract will refund the seller with three times the item cost (2 for the initial deposit from the seller, and one for the item/service being sent) and the buyer with one times the item cost (half of the buyers initial deposit, the other half is paying for the item/service). 

However, if both have paid but want to cancel the arrangement, they can both call the terminate() function which will refund them both. If only one person calls this function, the other person must not have paid in order for a refund to be delivered.

## Multi-Signature Wallet
This contract acts as a very basic multi-signature wallet using solidity.

Whoever deploys the contract initially has all of the power to send funds, add owners, and remove owners. However, once other owners are added, if the parameter "majority" was never changed below 100, then 100 percent of the owners signatures are needed to send funds, add an owner, remove an owner, or change the term "majority". Since the number of signatures required uses the following equation: "(Number of Owners * majority) / 100" and all numbers are ints, the number required will round down. The fallback function is a payable so the contract can't be killed by paying it ether.
