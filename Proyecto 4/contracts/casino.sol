// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract casino {

    // Variable para el duenio del casino.
    address duenio;

    // Precio de las fichas.
    uint256 precioDeCompraPorFicha;
    uint256 precioDeVentaPorFicha;

    constructor(uint256 _precioDeCompraPorFicha, uint256 _precioDeVentaPorFicha) {

        // Chequeamos que el precio de venta sea menor o igual al precio de compra.
        require(_precioDeVentaPorFicha <= _precioDeCompraPorFicha, "El precio de venta por ficha debe ser menor o igual al precio de compra.");

        // Seteamos al duenio como el que crea el contrato.
        duenio = msg.sender;

        // Seteamos el precio por ficha.
        precioDeCompraPorFicha = _precioDeCompraPorFicha;
        precioDeVentaPorFicha = _precioDeVentaPorFicha;

    
    }

    // Mapping para el balance de fichas por usuario.
    mapping(address => uint256) balanceDeFichas;

    // Eventos
    event precioPorFichaModificado(uint256, uint256);
    event fichasCompradas(address, uint256);
    event fichasVendidas(address, uint256);

    // Modifiers
    modifier soloElDuenio() {
    
        // Chequeamos que el remitente sea el duenio del contrato.
        require(msg.sender == duenio, "No eres el duenio.");

        // Finalizamos el modifier.
        _;

    }


    // Lógica Principal
    function modificarPrecioPorFichas(uint256 _nuevoPrecioDeCompra, uint256 _nuevoPrecioDeVenta) public soloElDuenio {

        // Chequeamos que el precio sea valido.
        require(_nuevoPrecioDeCompra > 0 && _nuevoPrecioDeVenta > 0, "El precio debe ser mayor a 0.");

        // Chequeamos que el precio de venta sea menor o igual al precio de compra.
        require(_nuevoPrecioDeVenta <= _nuevoPrecioDeCompra, "El precio de venta tiene que ser menor o igual al precio de compra.");

        // Seteamos los nuevos precios.
        precioDeCompraPorFicha = _nuevoPrecioDeCompra;
        precioDeVentaPorFicha = _nuevoPrecioDeVenta;

        // Emitimos el evento correspondiente.
        emit precioPorFichaModificado(_nuevoPrecioDeCompra, _nuevoPrecioDeVenta);

    }

    function comprarFichas(uint256 _cantidad) public payable {

        // Chequeamos que se haya enviado un monto superior o igual al requerido.
        require(msg.value >= (_cantidad * precioDeCompraPorFicha), "No se ha enviado suficiente ether.");

        // Conseguimos el ether sobrante.
        uint256 _sobrante = msg.value - _cantidad * precioDeCompraPorFicha;
        
        // Devolvemos el sobrante, en caso que haya.
        if (_sobrante > 0) {
            payable(msg.sender).transfer(_sobrante);
        }

        // Agregamos el balance.
        balanceDeFichas[msg.sender] += _cantidad;

        // Emitimos el evento correspondiente.
        emit fichasCompradas(msg.sender, _cantidad);

    }

    function venderFichas(uint256 _cantidad) public {

        // Chequeamos que el contrato tenga suficiente ether para la transaccion.
        require(address(this).balance >= _cantidad * precioDeVentaPorFicha, "No hay suficiente ether.");

        // Antes que nada restamos el balance del usuario.
        balanceDeFichas[msg.sender] -= _cantidad;

        // Enviamos el ether al usuario.
        payable(msg.sender).transfer(_cantidad * precioDeVentaPorFicha);

        // Emitimos el evento correspondiente.
        emit fichasVendidas(msg.sender, _cantidad);

    }

    

}