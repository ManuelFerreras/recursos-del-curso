// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract casino {

    // Variable para el duenio del casino.
    address duenio;

    // Precio de las fichas.
    uint256 precioDeCompraPorFicha;
    uint256 precioDeVentaPorFicha;

    // Variable para el porcentaje de ganancia en el juego.
    uint256 porcentajeEnVictoria;

    // Enum para opciones del coinflip.
    enum Opciones {CARA, CRUZ}

    Opciones opcionDefault = Opciones.CARA;

    constructor(uint256 _precioDeCompraPorFicha, uint256 _precioDeVentaPorFicha, uint256 _porcentajeEnVictoria) {

        // Chequeamos que el Porcentaje En Victoria sea mayor a 100.
        require(_porcentajeEnVictoria > 100, "El porcentaje de ganancia debe ser mayor a 100.");

        // Chequeamos que el precio de venta sea menor o igual al precio de compra.
        require(_precioDeVentaPorFicha <= _precioDeCompraPorFicha, "El precio de venta por ficha debe ser menor o igual al precio de compra.");

        // Seteamos al duenio como el que crea el contrato.
        duenio = msg.sender;

        // Seteamos el precio por ficha.
        precioDeCompraPorFicha = _precioDeCompraPorFicha;
        precioDeVentaPorFicha = _precioDeVentaPorFicha;

        // Seteamos el porcentaje de ganancia.
        porcentajeEnVictoria = _porcentajeEnVictoria;
    
    }

    // Mapping para el balance de fichas por usuario.
    mapping(address => uint256) balanceDeFichas;

    // Eventos
    event precioPorFichaModificado(uint256, uint256);
    event fichasCompradas(address, uint256);
    event fichasVendidas(address, uint256);
    event apuestaGanada(address, uint256);
    event apuestaPerdida(address, uint256);
    event nuevoPorcentajeEnVictoria(uint256);

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

    function modificarPorcentajeEnVictoria(uint256 _nuevoPorcentaje) public soloElDuenio {

        // Chequeamos que el nuevo porcentaje sea valido.
        require(_nuevoPorcentaje > 100, "El nuevo porcentaje debe ser mayor a 100.");

        // Seteamos el nuevo porcentaje.
        porcentajeEnVictoria = _nuevoPorcentaje;

        // Emitimos el evento correspondiente.
        emit nuevoPorcentajeEnVictoria(_nuevoPorcentaje);

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


    // Lógica del juego
    function _conseguirOpcionGanadora() private returns(Opciones) {

        // Conseguimos el valor ganador aleatorio.
        uint256 _valorGanador = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender, msg.value, duenio))) % 2;

        // Convertimos el valor a opcion.
        Opciones _opcion = Opciones(_valorGanador);

        // Retornamos el valor.
        return _opcion;

    }

    function coinflip(Opciones _opcion, uint256 _apuesta) public {

        // Chequeamos que la apuesta sea valida.
        require(_apuesta > 0, "La apuesta debe ser mayor a 0.");

        // Chequeamos que el usuario posea las fichas necesarias.
        require(balanceDeFichas[msg.sender] >= _apuesta, "El usuario no posee suficientes fichas.");

        // Antes que nada restamos la apuesta del balance del usuario.
        balanceDeFichas[msg.sender] -= _apuesta;

        // Conseguimos el lado ganador.
        Opciones _opcionGanadora = _conseguirOpcionGanadora();

        // Chequeamos si el usuario ha ganado.
        if (_opcionGanadora == _opcion) {

            // En caso que el usuario ha ganado, acreditamos el premio.
            balanceDeFichas[msg.sender] += _apuesta * porcentajeEnVictoria / 100;

            // Emitimos el evento correspondiente.
            emit apuestaGanada(msg.sender, _apuesta);

        } else {
        
            // Emitimos el evento correspondiente.
            emit apuestaPerdida(msg.sender, _apuesta);
        
        }

    }

}