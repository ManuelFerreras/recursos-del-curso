// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract nfts is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Variable para el puntero al token.
    ERC20 token;

    uint public precioNFT;

    constructor(string memory _nombre, string memory _simbolo, address tokenERC20, uint256 _precioNFT) ERC721(_nombre, _simbolo) {

        // Creamos un puntero al token.
        token = ERC20(tokenERC20);

        // Seteamos el precio en Tokens del NFT.
        precioNFT = _precioNFT;

    }

    function mint(string memory tokenURI) public returns (uint256) {
        // Chequeamos que el remitente pueda llamar a la funcion.
        require(token.balanceOf(msg.sender) >= precioNFT, "No posees suficientes Tokens.");
        require(token.allowance(msg.sender, address(this)) >= precioNFT, "Primero debes aprobar el uso del token.");

        // Transferimos los tokens ERC20.
        token.transferFrom(msg.sender, address(this), precioNFT);

        // Minteamos el nft.
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}