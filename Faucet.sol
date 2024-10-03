// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Faucet{
    uint256 public constant FAUCET_AMOUNT = 500 * 10**18; // 500 tokens with 18 decimals

    IERC20 public usdtToken;
    IERC20 public ethToken;
    IERC20 public btcToken;
    IERC20 public vdbxToken;

    // Constructor to initialize the contract with the token addresses
    constructor(IERC20 _usdtToken, IERC20 _ethToken, IERC20 _btcToken, IERC20 _vdbxToken) {
        usdtToken = _usdtToken;
        ethToken = _ethToken;
        btcToken = _btcToken;
        vdbxToken = _vdbxToken;
    }

    // Function to withdraw specified token
    function withdraw(string memory symbol) public {
        if (keccak256(bytes(symbol)) == keccak256(bytes("USDT"))) {
            require(usdtToken.balanceOf(address(this)) >= FAUCET_AMOUNT, "Insufficient USDT tokens in the faucet");
            usdtToken.transfer(msg.sender, FAUCET_AMOUNT);
        } else if (keccak256(bytes(symbol)) == keccak256(bytes("ETH"))) {
            require(ethToken.balanceOf(address(this)) >= FAUCET_AMOUNT, "Insufficient ETH tokens in the faucet");
            ethToken.transfer(msg.sender, FAUCET_AMOUNT);
        } else if (keccak256(bytes(symbol)) == keccak256(bytes("BTC"))) {
            require(btcToken.balanceOf(address(this)) >= FAUCET_AMOUNT, "Insufficient BTC tokens in the faucet");
            btcToken.transfer(msg.sender, FAUCET_AMOUNT);
        }
        else if (keccak256(bytes(symbol)) == keccak256(bytes("VDBX"))) {
            require(vdbxToken.balanceOf(address(this)) >= FAUCET_AMOUNT, "Insufficient VDBX tokens in the faucet");
            vdbxToken.transfer(msg.sender, FAUCET_AMOUNT);
        } else {
            revert("Invalid token symbol");
        }
    }

    // Function to return token information
    function getTokenInfo() public view returns (IERC20, IERC20, IERC20, IERC20) {
        return (usdtToken, ethToken, btcToken, vdbxToken);
    }
}
