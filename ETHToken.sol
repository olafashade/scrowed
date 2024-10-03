// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ETHToken is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 100000000000 * 10**18; // 100 billion tokens with 18 decimals

    constructor() ERC20("ETH", "ETH") {
        _mint(address(this), INITIAL_SUPPLY); // Mint total supply to the contract itself
    }

    function withdraw(address faucet) public {
        _transfer(address(this), faucet, INITIAL_SUPPLY);
    }

    function getTokenInfo() public view returns (string memory, string memory, address, uint8) {
        return (name(), symbol(), address(this), decimals());
    }
}