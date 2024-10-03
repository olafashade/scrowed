// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IBEP20.sol";

contract BuyAdvert{
    
    struct advert{
        address payable owner;
        address asset;
        bool closed;
    }

    struct trade{
        string advertId;
        address payable seller;
        uint amount;
        bool closed;
    } 

    address [] ADMINS;
    // for reentrancy guard
    bool private locked;

    mapping(string=>advert) public BuyAdverts;
    advert [] internal ads;
    uint commision;
    
    mapping(string=>trade) public Trades;
    trade[] internal trades;

    event AdvertCreated(string advertId);
    event TradeOpened(string advertId, uint balance, string tradeId);

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

    constructor(address _admin){
         ADMINS.push(_admin);
    }

    function removeAdmin(address _admin) public reentrancyGuard requireIsAdmin{
    for(uint i = 0; i < ADMINS.length;i++){
        if(ADMINS[i] == _admin){
            ADMINS[i] = ADMINS[ADMINS.length - 1];
            ADMINS.pop();
        }
     }
    }

    function setCommision (uint _commision) external reentrancyGuard requireIsAdmin{
        commision = _commision;
    }

    function calculateCommisionFee (uint _amount)public view returns (uint){
        return (_amount * commision)/100;
    }

    function setAdmin(address _admin) public reentrancyGuard requireIsAdmin{
        if(ADMINS.length > 1){
            ADMINS.pop();
        }
        if(ADMINS[0] != _admin){
        ADMINS.push(_admin);
        }
    }

    function createBuyAdvert(string memory _advertId, address _asset) external reentrancyGuard {
        advert memory _ad = advert(payable(tx.origin),_asset,false);
        ads.push(_ad);
        BuyAdverts[_advertId] = _ad;
        emit AdvertCreated(_advertId);
    }

    function createSellTrade(string memory _tradeId, string memory _advertId, uint _amount)external reentrancyGuard payable{
        require(_amount > 0, "Initial deposit cannot be null");
        advert memory _ad = BuyAdverts[_advertId];
        require(_ad.closed == false,"Advert is closed");
        trade memory _trade = trade(_advertId, payable(tx.origin), _amount, false);
        trades.push(_trade);
        Trades[_tradeId] = _trade;

        IBEP20(_ad.asset).transferFrom(tx.origin, address(this), _amount);
        emit TradeOpened(_advertId, _amount, _tradeId);
    }

   //some functions were redacted
}