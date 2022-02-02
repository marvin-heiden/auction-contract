// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Auction {
    // static
    address public owner;
    string public description;
    uint public startBlock;
    uint public endBlock;

    // state
    bool public canceled;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;

    // logs
    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();

    // modifiers
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyNotOwner {
        require (msg.sender != owner);
        _;
    }

    modifier onlyAfterStart {
        require (block.number >= startBlock);
        _;
    }

    modifier onlyBeforeEnd {
        require (block.number <= endBlock);
        _;
    }

    modifier onlyNotCanceled {
        require (!canceled);
        _;
    }

    constructor(address _owner, uint _startBlock, uint _endBlock, string memory _description) {
        require(_startBlock < _endBlock);
        require(_startBlock >= block.number);
        require(_owner != address(0));
        require(keccak256(abi.encodePacked(_description)) != keccak256(abi.encodePacked("")));

        owner = _owner;
        startBlock = _startBlock;
        endBlock = _endBlock;
        description = _description;
    }

    function placeBid()
        public
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
        returns (bool success)
    {
        require(msg.value != 0);

        uint newBid = fundsByBidder[msg.sender] + msg.value;

        fundsByBidder[msg.sender] = newBid;

        require(newBid > highestBid);

        if (msg.sender != highestBidder) {
            highestBidder = msg.sender;
        }
        highestBid = newBid;

        emit LogBid(msg.sender, newBid, highestBidder, highestBid);
        return true;
    }

    function cancelAuction()
        public
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
        returns (bool success)
    {
        canceled = true;
        emit LogCanceled();
        return true;
    }

    function getRemainingBlocks()
        public
        view
        onlyBeforeEnd
        onlyNotCanceled
        returns (uint remainingBlocks)
    {
        return endBlock - block.number;
    }

    function withdraw()
        public
        returns (bool success)
    {
        address withdrawalAccount;
        uint withdrawalAmount;

        if (canceled) {
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];

        } else if (block.number >= endBlock){ // auction terminated
            if (msg.sender == owner) {
                withdrawalAccount = highestBidder;
                withdrawalAmount = highestBid;
                ownerHasWithdrawn = true;

            } else if (msg.sender == highestBidder) {
                withdrawalAmount = 0;

            } else {
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        } else {
            if(msg.sender == owner || msg.sender == highestBidder){
                // owner and highest bidder are not allowed to withdraw until end of auction
                withdrawalAmount = 0;
            } else {
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        }

        require(withdrawalAmount != 0);

        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

        require(payable(msg.sender).send(withdrawalAmount));

        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

        return true;
    }
}