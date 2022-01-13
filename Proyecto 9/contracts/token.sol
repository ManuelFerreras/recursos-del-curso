// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract tokenDePrueba is ERC20, Ownable {

    using SafeMath for uint;
    
    // Metadata del Token
    string public nombre = "Test de Prueba";
    string public simbolo = "TDP";
    uint256 public totalDeTokens = 100000000 * 10 ** 18;

    // Cantidad de tokens que habran en la ICO.
    uint256 public tokensDeICO;
    
    // Constructor
    constructor(uint256 _tokensDeICO) ERC20(nombre, simbolo) {
        
        // Minteamos los tokens totales menos los tokens para la ICO al remitente.
        _mint(msg.sender, totalDeTokens - _tokensDeICO);

        // Minteamos los tokens de la ICO a este contrato.
        _mint(address(this), _tokensDeICO);

        tokensDeICO = _tokensDeICO;
    }


    // ------- ICO -------

    // Struct para almacenar una venta.
    struct Venta {
        address inversor;
        uint cantidad;
    }

    Venta[] public ventas;

    // Informacion de la ICO.
    uint public fin;
    uint public precioPorToken;
    uint public compraMinima;
    uint public compraMaxima;
    bool public liberados;

    // Mapping para la whitelist.
    mapping (address => bool) usuariosEnWhitelist;

    // Mapping para la gente que ya ha comprado.
    mapping (address => bool) compradores;

    uint public finWhitelist = 0;

    function comenzarWhitelist (uint _duracion) public onlyOwner icoNoActiva whitelistNoActiva {

        // Chequeamos que la duracion sea valida.
        require(_duracion > 0, "La duracion debe ser > 0.");

        // Seteamos el tiempo de fin para la whitelist.
        finWhitelist = block.timestamp + _duracion;

    }

    function agregarCuentaAWhitelist() public whitelistNoFinalizada {

        // Agregamos el remitente a la whitelist.
        usuariosEnWhitelist[msg.sender] = true;

    }
    
    function comenzarICO (
        uint _duracion,
        uint _precio, // En WEI.
        uint _compraMinima, // Cantidad de tokens minima en una compra.
        uint _compraMaxima) // Cantidad de tokens maxima en una compra.
        external
        onlyOwner 
        icoNoActiva
        whitelistActiva
        whitelistFinalizada {

        // Chequeamos que se pueda iniciar la ICO.
        require(_duracion > 0, "La Duracion debe ser > 0.");
        require(_compraMinima > 0 && _compraMinima < _compraMaxima, "_compraMinima debe ser > 0 y < _compraMaxima");
        require(_compraMaxima > 0 && _compraMaxima.mul(10**18) <= tokensDeICO, "_compraMaxima debe ser > 0 y <= tokensDeICO");

        // Creamos la ICO.
        fin = _duracion + block.timestamp; 
        precioPorToken = _precio;
        compraMinima = _compraMinima;
        compraMaxima = _compraMaxima;
        liberados = false;

    }
    
    function comprarTokens () payable external icoActiva soloEnWhitelist soloUnaCompra {

        // Chequeos.
        require(msg.value % precioPorToken == 0, "Debes enviar un multiplo del precio");
        require(msg.value >= (compraMinima.mul(precioPorToken)) && msg.value <= (compraMaxima.mul(precioPorToken)), "Debes comprar entre la compraMinima y la compraMaxima.");
        
        uint _cantidad = msg.value.div(precioPorToken).mul(10**18);
        require(_cantidad <= tokensDeICO, "No hay suficientes tokens disponibles para realizar la venta.");

        // Agregamos una nueva venta.
        ventas.push(Venta(
            msg.sender,
            _cantidad
        ));

        // Restamos los tokens comprados a la cantidad de tokens disponibles.
        tokensDeICO = tokensDeICO.sub(_cantidad);
    }
    
    function liberar() external onlyOwner icoEnded tokensNoLiberados {

        // Repartimos los tokens a todos los inversores.
        for(uint i = 0; i < ventas.length; i++) {
            Venta storage venta = ventas[i];
            transfer(venta.inversor, venta.cantidad);
        }

        liberados = true;
    }
    
    function withdraw(uint _cantidad) external onlyOwner icoEnded tokensLiberados {

        // Retiramos ether del contrato.
        payable(msg.sender).transfer(_cantidad);    

    }
    
    modifier icoActiva() {

        // Chequeamos que la ICO siga activa.
        require(fin > 0 && block.timestamp < fin && tokensDeICO > 0, "La ICO no esta activa.");

        _;
    }
    
    modifier icoNoActiva() {

        // Chequeamos que la ICO no siga activa.
        require(fin == 0, "La ICO ya ha sido activada.");

        _;
    }
    
    modifier icoEnded() {

        // Chequeamos que la ICO no haya finalizado.
        require(fin > 0 && (block.timestamp >= fin || tokensDeICO == 0), "La ICO ya ha finalizado.");

        _;
    }
    
    modifier tokensNoLiberados() {
        
        // Chequeamos que los tokens no hayan sido liberados.
        require(liberados == false, "Los tokens ya han sido liberados.");

        _;
    }
    
    modifier tokensLiberados() {

        // Chequeamos que los tokens hayan sido liberados.
        require(liberados == true, "Los tokens no se han liberado aun.");
        _;
    }

    modifier whitelistNoActiva() {
    
        // Chequeamos que la whitelist nunca haya sido activada.
        require(finWhitelist == 0, "La whitelist ya se ha hecho.");

        _;    
    }

    modifier whitelistActiva() {

        // Chequeamos que la whitelist haya sido activada.
        require(finWhitelist > 0, "La whitelist todavia no ha sucedido.");

        _;
    }

    modifier whitelistFinalizada() {

        // Chequeamos que la whitelist haya finalizado.
        require(finWhitelist < block.timestamp, "La whitelist no ha terminado aun");

        _;
    }

    modifier whitelistNoFinalizada() {

        // Chequeamos que la whitelist no haya finalizado.
        require(finWhitelist > block.timestamp, "La whitelist ya ha finalizado.");

        _;
    }

    modifier soloEnWhitelist() {

        // Chequeamos que el remitente este en la whitelist.
        require(usuariosEnWhitelist[msg.sender], "No te encuentras en la whitelist.");

        _;
    }

    modifier soloUnaCompra() {

        // Chequeamos que el usuario no haya comprado tokens anteriormente.
        require(!compradores[msg.sender], "Ya has comprado tokens.");

        _;
    }
    
}