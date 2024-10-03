// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IBEP20.sol";
import {Advert} from "./Advert.sol";

contract Trade{

    struct trade{
        string advertId;
        address payable buyer;
        uint amount;
        bool closed;
    } 
    //address ADMIN_ADDRESS;
    address [] ADMINS;
    Advert AdvertFactory;

    mapping(string=>trade) public Trades;
    trade[] internal __trades;
	
	event TokenTransfered(string tradeId);
    event AdvertClosed(string advertId);
    event TradeClosed(string tradeId);
    bool locked = false;

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

    constructor(address _admin, address payable _advertAddress){
        //ADMIN_ADDRESS = _admin;
        ADMINS.push(_admin);
        AdvertFactory = Advert(_advertAddress);
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

    function closeTrade(string memory _tradeId)external{
        trade storage _trade = Trades[_tradeId];
        require(_trade.closed == false, "Trade closed already");
        require(tx.origin == _trade.buyer, "Unauthorized to close trade");
         _trade.closed = true;
        AdvertFactory.addBalance(_trade.advertId, _trade.amount, _tradeId);
    }

    function createTrade(string memory _tradeId, string memory _advertId, uint _amount) external {
        uint advertBalance = AdvertFactory.getBalance(_advertId);
        require(_amount <= advertBalance, "insufficient advert balance to initiate trade");
        trade memory _t = trade(_advertId,payable(tx.origin),_amount,false);
        Trades[_tradeId] = _t;
        __trades.push(_t);
        AdvertFactory.deductBalance(_advertId, _amount, _tradeId);
    }
    
    receive() external payable{}

   //some functions were redacted
}