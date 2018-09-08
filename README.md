# OrionVaultSecurityToken

## Smart contract overview

This is the ERC-20 smart contract for Orion Vault Security Tokens, symbol OVC. These tokens are not divisible , i.e. have 0 decimals.

The tokens represent shares of Orion Vault AG, a company incorporated in Switzerland, although not all shares are represented by such tokens. The current number of shares is 10_000_000, and up to 4_500_000 will initially be represented by tokens.

The contract owner can mint tokens. Token holders can, subject to certain restrictions, request an exchange of tokens against actual shares. The maximum supply represents the number of Orion Vault shares in existence, and can be modified in case of a new share issue.

The contract owner can declare a dividend by simply sending ether to the contract. Token holders can claim the dividend at any time, and also trigger payouts for other addresses - this will allow Orion Vault to trigger payouts without token holders needing to do it.

A total of 1_500_000 tokens is reserved for the team. These will be issued by the smart contract in 4 installments. Such token payouts will be subject to a vote by the token holders.

## Minting and modifying the token supply.

The owner can mint tokens using the `mintTokens` function.

The number of tokens available to mint can be checked using the public `availableToMint` function, for which no gas is required. This number is equal to 

The owner can also modify the token supply using the `changeMaxTokenSupply` function. This will only be done if Orion Vault AG issues new shares.

## Token transferability

The contract owner can make tokens transferable at any time by calling the `makeTradeable` function. After 01-JAN-2019, anyone can make the tokens transferable by calling this function. This operation cannot be reversed.

## Exchanging tokens for equity

The contract owner decides if tokens can be exchanged for equity, by setting the isExchangeOpen variable using the `ownerExchangeOpen` and `ownerExchangeClose` functions.

When isExchangeOpen has been set to true by the owner, and voting is not open, token holders can request an exchange by calling the `exchangeForEquity` function.

## Dividends

The contract owner declares a dividend simply by sending ether to the contract. The dividend will be split among token holders at the moment of the transaction.

A token holder can claim his dividend by calling the `claimOwnDividend` function.

Anyone can trigger the dividend payment for one address (resp. for multiple addresses) by calling the `claimDividend` (resp. `claimDividendMultiple`) function.

## Team tokens and voting

A total of 1_500_000 tokens is reserved for the team. These will be issued by the smart contract in 4 installments of 375_000 tokens each. These "vesting events" will occur on 01-JAN and 01-JUL of every year staring on 01-JAN-2020, subject to a vote of token holders. In case of a negative vote, the issue of team tokens will be postponed by one period of 6 months..

Voting takes place during the month preceding the vesting event, as long as there remain any team tokens to be distributed. The first four voting periods are therefore DEC-2019, JUN-2020, DEC-2020 and JUN-2021. There will be additional voting periods if at least one of the first 4 votes was negative.

Token holders vote in favour of releasing team tokens by calling the `castVoteFor` function, and against by calling `castVoteAgainst`.

After the voting period os over, anyone can call the `processVote` function which registers the vote result and issues team tokens if the vote was positive.

