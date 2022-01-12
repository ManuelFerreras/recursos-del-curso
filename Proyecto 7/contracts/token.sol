// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importamos el estandar de ERC20.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract TokenDePrueba is ERC20 {

    // Informacion metadata del token.
    string _name = "Token de Prueba";
    string _symbol = "TDP";
    uint256 _totalSupply = 1000 * 10 ** 18;

    // Pasamos a ERC20 los argumentos necesarios para el constructor.
    constructor() ERC20(_name, _symbol) {

        // Minteamos los tokens iniciales al creador del contrato.
        _mint(msg.sender, _totalSupply);

    }

    function burn(uint256 amount) public {

        // Quemamos los tokens.
        _burn(msg.sender, amount);

    }

    function mint(uint256 amount) public {

        // Mintemos tokens al que llama la funcion.
        _mint(msg.sender, amount);

    }

}
