// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract TokenDePrueba is ERC20 {

    string _name = "Token de Prueba";
    string _symbol = "TDP";
    uint256 _totalSupply = 10000000 * 10 ** 18;

    constructor() ERC20(_name, _symbol) {

        _mint(msg.sender, _totalSupply);

    }

}
