pragma solidity ^0.4.18;

contract MultiSigWallet {
    address[] public registeredOwners;
    mapping(address => mapping(address => uint)) public transferSigned;
    mapping(address => address) public newOwnerSigned;
    mapping(address => address) public removeOwnerSigned;
    mapping(address => uint) public sigPercentage;
    
    uint numOwners = 0;
    uint sigsNeeded = 1;
    //Majority is the percent required to send funds, add an owner, and remove an owner
    uint majority = 100;

    
    
    event MoneyDeposited(address sender, uint amount);
    event MoneySent(address to, uint amount);
    
    
    function MultiSigWallet() {
        registeredOwners[0] = msg.sender;
        numOwners++;
        sigsNeeded++;
    }
    
    
    modifier onlyOwner() {
        bool confirm = false;
        for(uint i = 0; i < numOwners; i++) {
            if(registeredOwners[i] == msg.sender) {
                confirm = true;
            }
        }
        require(confirm == true);
        _;
    }
    
    function addOwner(address newOwner) public onlyOwner returns(bool){
        newOwnerSigned[msg.sender] = newOwner;
        uint numAgreed = 0;
        for(uint i = 0; i < numOwners; i++) {
            if(newOwnerSigned[registeredOwners[i]] == newOwner) {
                numAgreed++;
            }
        }
        if(numAgreed >= sigsNeeded) {
            registeredOwners[numOwners] = newOwner;
            numOwners++;
            sigsNeeded = (numOwners * majority) / 100;
            for(i = 0; i < numOwners; i++) {
                newOwnerSigned[registeredOwners[i]] = address(0);
            }
            return true;
        }
        return false;
    }
    
    function removeOwner(address remove) public onlyOwner returns(bool){
        removeOwnerSigned[msg.sender] = remove;
        uint numAgreed = 0;
        for(uint i = 0; i < numOwners; i++) {
            if(removeOwnerSigned[registeredOwners[i]] == remove) {
                numAgreed++;
            }
        }
        if(numAgreed >= sigsNeeded) {
            for(i = 0; i < numOwners; i++) {
                if(registeredOwners[i] == remove) {
                    for(uint k = i; k < numOwners; k++) {
                        if(k == numOwners - 1) {
                            registeredOwners[k] = address(0);
                        }
                        else {
                            registeredOwners[k] = registeredOwners[k + 1];
                        }
                    }
                }
            }
            numOwners--;
            sigsNeeded = (numOwners * majority) / 100;
            for(i = 0; i < numOwners; i++) {
                removeOwnerSigned[registeredOwners[i]] = address(0);
            }
            return true;
        }
        return false;
    } 
    
    function transferTo(uint amount, address payTo) public onlyOwner returns(bool){
        transferSigned[msg.sender][payTo] = amount;
        uint numAgreed = 0;
        for(uint i = 0; i < numOwners; i++) {
            if(transferSigned[registeredOwners[i]][payTo] == amount) {
                numAgreed++;
            }
        }
        if(numAgreed >= sigsNeeded) {
            require(address(this).balance >= amount);
            payTo.transfer(amount);
            MoneySent(payTo, amount);
            
            for(i = 0; i < numOwners; i++) {
                transferSigned[registeredOwners[i]][payTo] = 0;
            }
            return true;
        }
        return false;        
    }
    
    
    //This map, sigPercentage, is never reset
    function sigsRequired(uint percent) public onlyOwner {
        sigPercentage[msg.sender] = percent;
        uint numAgreed = 0;
        for(uint i = 0; i < numOwners; i++) {
            if(sigPercentage[registeredOwners[i]] == percent) {
                numAgreed++;
            }
        }
        if(numAgreed >= sigsNeeded) {
            sigsNeeded = (numOwners * percent) / 100;
            majority = percent;
        }
    }
    
    
    function () public payable {
        MoneyDeposited(msg.sender, msg.value);
    }
}