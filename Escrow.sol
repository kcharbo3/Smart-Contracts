pragma solidity ^0.4.18;

contract Escrow {
    address seller;
    address buyer;
    uint itemCost;

    
    bool buyerPaid = false;
    bool sellerPaid = false;
    
    bool buyerTerminate = false;
    bool sellerTerminate = false;
    
    event bothPaid();
    event itemRecieved();
    
    function Escrow(uint cost, address buyerAddress) payable {
        seller = msg.sender;
        buyer = buyerAddress;
        itemCost = cost;
        if(msg.value != itemCost * 2) {
            seller.transfer(msg.value);
        }
    }
    
    function getCost() view public returns(uint) {
        return itemCost;
    }
    
    function sellerPay() public payable {
        if(msg.value != itemCost * 2) {
            msg.sender.transfer(msg.value);
        }
        else {
            sellerPaid = true;
            if(buyerPaid) {
                bothPaid();
            }
        }
    }
    
    function buyerPay() public payable onlyBuyer {
        if(msg.value != itemCost * 2) {
            msg.sender.transfer(msg.value);
        }
        else {
            buyerPaid = true;
            if(sellerPaid) {
                bothPaid();
            }
        }
    }
    
    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    
    function recievedItem() public onlyBuyer {
        require(buyerPaid == true && sellerPaid == true);
        buyer.transfer(itemCost);
        seller.transfer(itemCost * 3);
        buyerPaid = false;
        sellerPaid = false;
        buyerTerminate = false;
        sellerTerminate = false;
        itemRecieved();
    }
    
    function terminate() public {
        require(msg.sender == buyer || msg.sender == seller);
        if(msg.sender == buyer && buyerPaid == true) {
            buyerTerminate = true;
        }
        else if(msg.sender == seller && sellerPaid == true) {
            sellerTerminate = true;
        }
        
        if(buyerTerminate == true && sellerTerminate == true) {
            buyer.transfer(itemCost * 2);
            seller.transfer(itemCost * 2);
            buyerTerminate = false;
            sellerTerminate = false;
            buyerPaid = false;
            sellerPaid = false;
        }
        else if(buyerTerminate == true && !sellerPaid) {
            buyer.transfer(itemCost * 2);
            buyerTerminate = false;
            buyerPaid = false;
        }
        else if(sellerTerminate == true && !buyerPaid) {
            seller.transfer(itemCost * 2);
            sellerTerminate = false;
            sellerPaid = false;
        }
    }
    
    
    function() public payable {
        
    }
}