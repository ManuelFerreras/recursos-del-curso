// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract periodico {

    // Variable para el duenio del contrato.
    address duenio;

    // El precio que deberan pagar los clientes para suscribirse al periodico.
    uint256 public precioSuscripcion;

    constructor(uint256 _precioSuscripcion) {

        // Seteamos el duenio como el creador del contrato.
        duenio = msg.sender;

        // Seteamos el precio de la suscripcion.
        precioSuscripcion = _precioSuscripcion;

    }

    // Mapping donde se almacenan los escritores.
    mapping(address => bool) escritores;

    // Mapping donde se almacenan los suscriptos al periodico.
    mapping(address => bool) suscritos;

    // Struct para las entradas del periodico.
    struct Entrada {
        string titulo;
        string cuerpo;
        address escritor;
        uint256 tiempoLanzamiento;
    }

    // Array de entradas del periodico.
    Entrada[] entradas;

    // Eventos
    event nuevoEscritor(address);
    event editorRemovido(address);
    event entradaCreada(string, address);
    event nuevoSuscrito(address);
    event nuevoPrecioDeSuscripcion(uint);

    // Modificadores
    modifier soloElDuenio() {

        // Chequeamos que el duenio del contrato este iteractuando.
        require(msg.sender == duenio, "No eres el duenio del periodico.");

        // Finalizamos el Modifier.
        _;

    }

    modifier soloNoEscritores(address _direccion) {
        
        // Chequeamos que la direccion no sea un escritor.
        require(!escritores[_direccion], "La direccion no debe ser un escritor.");

        // Finalizamos el Modifier.
        _;

    }

    modifier soloEscritores() {

        // Chequeamos que la direccion que esta interactuando sea un escritor.
        require(escritores[msg.sender], "No eres un escritor.");

        // Finalizamos el Modifier.
        _;

    }

    modifier soloNoSuscritos() {

        // Chequeamos que la direccion que esta interactuando no este suscrita.
        require(!suscritos[msg.sender], "Ya estas suscrito.");

        // Finalizamos el Modifier.
        _;
    
    }

    modifier soloSuscritos() {

        // Chequeamos que la direccion que esta interactuando este suscrita.
        require(suscritos[msg.sender], "No estas suscrito.");

        // Finalizamos el Modifier.
        _;

    }


    // Logica Principal
    function modificarPrecioDeSuscripcion(uint256 _nuevoPrecio) public soloElDuenio {

        // Chequeamos que el precio introducido sea el correcto.
        require(_nuevoPrecio > 0, "El precio debe ser mayor a 0.");

        // Seteamos el nuevo precio.
        precioSuscripcion = _nuevoPrecio;

        // Emitimos el evento correspondiente.
        emit nuevoPrecioDeSuscripcion(_nuevoPrecio);

    }

    
    function agregarEscritor(address _direccionDelEscritor) public soloElDuenio soloNoEscritores(_direccionDelEscritor) {

        // Seteamos la direccion como escritor.
        escritores[_direccionDelEscritor] = true;

        // Emitimos el evento correspondiente.
        emit nuevoEscritor(_direccionDelEscritor);

    }


    function crearEntrada(string memory _titulo, string memory _cuerpo) public soloEscritores {

        // Chequeamos que los valores ingresados sean validos.
        require(keccak256(abi.encodePacked(_titulo)) != keccak256(abi.encodePacked("")), "El titulo no puede estar vacio.");
        require(keccak256(abi.encodePacked(_cuerpo)) != keccak256(abi.encodePacked("")), "El cuerpo no puede estar vacio.");

        // Creamos la nueva entrada.
        entradas.push(Entrada(_titulo, _cuerpo, msg.sender, block.timestamp));

        // Emitimos el evento correspondiente.
        emit entradaCreada(_titulo, msg.sender);

    }


    function suscribirseAlPeriodico() public payable soloNoSuscritos {

        // Chequeamos que se ha enviado la cantidad correcta de ether.
        require(msg.value >= precioSuscripcion, "No se ha enviado el ether suficiente.");

        // Calculamos el ether que ha sobrado de la transaccion.
        uint256 _etherSobrante = msg.value - precioSuscripcion;

        // Devolvemos el ether sobrante al remitente.
        if (_etherSobrante > 0) {
            payable(msg.sender).transfer(_etherSobrante);
        }

        // Seteamos al nuevo suscriptor.
        suscritos[msg.sender] = true;

        // Emitimos el evento correspondiente.
        emit nuevoSuscrito(msg.sender);

    }


    function devolverNombresDeEntradas() public view returns(string[] memory) {

        // Creamos un arreglo de strings con largo igual a la cantidad de entradas que existen.
        string[] memory _nombreDeEntradas = new string[](entradas.length);

        // Poblamos el arreglo con los titulos.
        for(uint i = 0; i < entradas.length; i++) {
            _nombreDeEntradas[i] = entradas[i].titulo;
        }

        // Devolvemos el arreglo creado.
        return _nombreDeEntradas;

    }


    function devolverEntrada(uint256 _idEntrada) public view soloSuscritos returns(Entrada memory) {

        return(entradas[_idEntrada]);

    }
    
}