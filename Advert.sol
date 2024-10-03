// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IBEP20.sol";

contract Advert{
    
    event Funded(string __advertId, uint __amount, uint __balance);
    event Deposited(string advertId, uint amount, uint balance);

    address [] ADMINS;
    address TRADE_CONTRACT;
    // for reentrancy guard
    bool private locked;

      struct advert{
        address payable owner;
        // original advert token quantity
        uint amount; 
        address asset;
        // advert leftover. this would be interacted with and should be updated simultaneously with the amount increment/decrement
        uint balance;
        bool closed;
    }

    modifier reentrancyGuard() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    modifier requireIsAdmin() {
        bool isAdmin = false;

        for (uint i = 0; i < ADMINS.length; i++){
            if(tx.origin == ADMINS[i]){
                isAdmin = true;
                break;
            }
        }
        require(isAdmin, "Only Admin");
        _;
    }

    modifier onlyTradeContact(){
        require(msg.sender == TRADE_CONTRACT, "Only  trade contact can execute this function");
        _;
    }
    
    mapping(string=>advert) public Adverts;
    advert [] internal ads;
    uint commision;

    constructor(address admin){
        ADMINS.push(admin);
    }

    function setTradeContract(address _tradeContractAddress)public reentrancyGuard requireIsAdmin(){
        TRADE_CONTRACT = _tradeContractAddress;
    }

    function removeAdmin(address _admin) public reentrancyGuard requireIsAdmin{
        for(uint i = 0; i < ADMINS.length;i++){
            if(ADMINS[i] == _admin){
                ADMINS[i] = ADMINS[ADMINS.length - 1];
                ADMINS.pop();
            }
        }
    }

    function setAdmin(address _admin) public reentrancyGuard requireIsAdmin{
        if(ADMINS.length > 1){
            ADMINS.pop();
        }
        if(ADMINS[0] != _admin){
        ADMINS.push(_admin);
        }
    }

    function setCommision (uint _commision) external reentrancyGuard requireIsAdmin{
        commision = _commision;
    }

    function calculateCommisionFee (uint _amount)public view returns (uint){
         return (_amount * commision)/100;
    }

    //Creating a sell offer
    function createAdvert (string memory _advertId, uint _amount, address _asset) external reentrancyGuard payable{
        require(_amount > 0, "Initial deposit cannot be null");

        uint _commision = calculateCommisionFee(_amount);
        uint netAmount = _amount - _commision;
        advert memory _ad = advert(payable(tx.origin), _amount, _asset, netAmount, false);
		ads.push(_ad);
        Adverts[_advertId] = _ad;
        IBEP20(_asset).transferFrom(tx.origin, address(this), _amount);
        emit Funded(_advertId, _amount, netAmount);
    }

    //Fund the offer
    function deposit(string memory advertId, uint _amount) external reentrancyGuard payable{
        advert storage ad = Adverts[advertId];
        require(ad.closed == false, "Advert closed");
        require(tx.origin == ad.owner, "Unauthorized to deposit"); 
        uint _commission = calculateCommisionFee(_amount);
        uint netAmount = _amount - _commission;
        ad.amount += _amount;
        ad.balance += netAmount;
        IBEP20(ad.asset).transferFrom(tx.origin, address(this), _amount);
        emit Deposited(advertId, _amount, ad.balance);
    }

    receive() external payable{}

   function getAdvertOwner(string memory _advertId) view external returns (address){
       return (Adverts[_advertId].owner);
   }
  
  //some functions were redacted
}