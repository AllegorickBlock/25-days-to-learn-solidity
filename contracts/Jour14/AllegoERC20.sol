// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AllegoToken is ERC20, Ownable {

    mapping(address => bool) admins;

    uint public _maxSupply =  1000000000 * 10 ** 18;

    constructor() ERC20("AllegoERC20", "ALGOT") {}

    function addAdmin(address _newAdmin) external onlyOwner{
        admins[_newAdmin] = true;
    }

    function removeAdmin(address _oldAdmin) external onlyOwner{
        admins[_oldAdmin] = false;
    }

    function mint(address _to, uint _amount) external {
        require(admins[msg.sender],"Vous n'etes pas admin !");
        require(totalSupply() + _amount <= _maxSupply,"Limite de supply atteite");
        _mint(_to,_amount);
    }
}