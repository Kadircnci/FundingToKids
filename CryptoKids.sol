// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;
contract CryptoKids {
    // Owner DAD
    address owner;
    event LogKidFundingReceived(address addr, uint amount, uint contractBalance);
    constructor() {
        owner = msg.sender;
    }
    // define Kid
    struct Kid {    
        address payable walletAdress;
        string firstname;
        string lastname;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }
    Kid[] public kids;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }
    // add kid to contract
    function addKid(address payable walletAdress, string memory firstname, string memory lastname, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner {
        kids.push(Kid(
            walletAdress,
            firstname, 
            lastname,
            releaseTime,
            amount,
            canWithdraw
        ));
    }
    // view aand pure
    function balancedOf() public view returns(uint){
        return address(this).balance;
    }
    // deposit funds to contract, specifically to a kid's account
    function deposit(address walletAdress) payable public {
        addToKidsBalance(walletAdress);
    }
    function addToKidsBalance(address walletAdress) private {
        for(uint i = 0; i < kids.length; i++) {
            if(kids[i].walletAdress == walletAdress) {
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(walletAdress, msg.value, balancedOf());
            }
        }
    }
    function getIndex(address walletAdress) view private returns(uint) {
        for(uint i = 0; i < kids.length ; i++) {
            if (kids[i].walletAdress == walletAdress) {
                return i;
            }
        }
        return 999;
    }
    // kid checks if able to withdraw
    function availableToWithDraw(address walletAdress) public returns(bool) {
        uint i = getIndex(walletAdress);
        require(block.timestamp > kids[i].releaseTime, "You cannot withdraw yet");
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }    
    
    // withdraw money
    function withdraw(address payable walletAdress) payable public {
        uint i = getIndex(walletAdress);
        require(msg.sender == kids[i].walletAdress, "You must be the kid to withdraw");
        require(kids[i].canWithdraw == true, "You are not able to withdraw at this time");
        kids[i].walletAdress.transfer(kids[i].amount);
    }
}