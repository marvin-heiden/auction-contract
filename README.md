### Crypto & Blockchain - Assignment 3

## Smart Contract

# Description

This Smart Contract implements a simple auction functionality. The auction type is the classic "English Auction" where each bidder places their bids over a fixed timespan and in the end the highest bid wins. The bidders are always aware of the current highest bid so they can adjust their investment as long as the auction is still running. As long as one is *not* the highest bidder, one can withdraw the amount of ether one has invested up to that point at any time. Once the auction is over, the asset owner may withdraw an amount of Ether equal to the highest bid.

# Initialization

In order to create an instant of the auction, one has to set a number of properties:
- **Owner:** The address of the individual that owns the asset on auction so that they may withdraw their winnings in the end
- **Start Block:** The blocknumber of the first block during which the auction takes place (approximate "start time")
- **End Block:** The blocknumber of the last block during which the auction takes place (approximate "end time")
- **Description:** A String value containing a description of the asset on auction (could also be replaced with an ID to a database object or a hyperlink to a more detailed description in future releases)

