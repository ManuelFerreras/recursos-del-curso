// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract nfts is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Puntero al token creado.
    ERC20 token;

    // Variable que indica la cantidad de dias que los nfts generaran tokens.
    uint vidaUtilBase;

    // Variable que indica la cantidad de tokens que generan los nfts al dia.
    uint public generacionBase;

    // Struct para almacenar la informacion de staking de los nfts.
    struct InformacionStaking {
        uint256 diaDeInicio;
        uint256 vidaUtilRestante;
    }

    // Mapping para almacenar la informacion de todos los nfts.
    mapping(uint => InformacionStaking) public informacionDeStaking;

    // Eventos
    event tokensReclamados(uint, uint, address);

    constructor(string memory _nombre, string memory _simbolo, address _direccionToken, uint _vidaUtilBase, uint _generacionBase) ERC721(_nombre, _simbolo) {

        token = ERC20(_direccionToken);

        vidaUtilBase = _vidaUtilBase;
        generacionBase = _generacionBase * 10 ** 18;

    }

    function mint(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        // Conseguimos el dia actual.
        uint _diaActual = (block.timestamp - block.timestamp % 1 days) / 1 days;

        // Comenzamos el periodo.
        informacionDeStaking[newItemId] = InformacionStaking(_diaActual, vidaUtilBase);

        return newItemId;
    }

    function devolverTokensGenerados(uint _tokenId) public view returns (uint) {

        // Conseguimos la cantidad de dias que han pasado sin reclamar la recompensa.
        uint _diasPasados = ((block.timestamp - block.timestamp % 1 days) / 1 days) - informacionDeStaking[_tokenId].diaDeInicio;

        // Chequeamos la vida util restante del nft.
        if (_diasPasados < informacionDeStaking[_tokenId].vidaUtilRestante) {
            return _diasPasados * generacionBase;
        } else {
            return informacionDeStaking[_tokenId].vidaUtilRestante * generacionBase;
        }

    }

    function reclamarTokensGenerados(uint _tokenId) public onlyOwnerOf(_tokenId) {

        // Conseguimos las recompensas del nft.
        uint256 _recompensas = devolverTokensGenerados(_tokenId);

        // Chequeamos que hayan suficientes tokens para la transferencia.
        require(token.balanceOf(address(this)) >= _recompensas, "No hay suficientes tokens para la transaccion.");

        // Actualizamos la vida util del nft.

        // Chequeamos que el valor que resulte sea un uint.
        if (informacionDeStaking[_tokenId].vidaUtilRestante < ((block.timestamp - block.timestamp % 1 days) / 1 days) - informacionDeStaking[_tokenId].diaDeInicio) {
            informacionDeStaking[_tokenId].vidaUtilRestante = 0;
        } else {
            informacionDeStaking[_tokenId].vidaUtilRestante -= ((block.timestamp - block.timestamp % 1 days) / 1 days) - informacionDeStaking[_tokenId].diaDeInicio;
        }

        informacionDeStaking[_tokenId].diaDeInicio = (block.timestamp - block.timestamp % 1 days) / 1 days;

        // Transferimos las recompensas.
        token.transfer(msg.sender, _recompensas);

        // Emitimos el evento correspondiente.
        emit tokensReclamados(_recompensas, _tokenId, msg.sender);

    }

    // Chequeamos que el remitente sea el duenio del nft.
    modifier onlyOwnerOf(uint _tokenId) {

        require(ownerOf(_tokenId) == msg.sender, "No eres el duenio del nft.");

        _;

    }

}