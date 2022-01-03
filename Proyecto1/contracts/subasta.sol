// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract SubastaDeObjetos {
    
    // Struct para crear subastas.
    struct Subasta {
        string articulo;
        string descripcion;
        uint256 precio;
        uint256 tiempoFin;
        address ganadorActual;
        address creador;
        bool estadoActiva;
    }


    // Creamos un arreglos de Subastas, donde se almacenaran las subastas creadas.
    Subasta[] subastas;
    mapping (address => uint[]) subastasDeDireccion;


    // Eventos
    event nuevaSubasta(string, string, uint, uint, address);
    event nuevaOferta(uint, uint, address);
    event ganadorDeSubasta(address, uint);


    // Modificadores
    modifier soloCreador(uint256 _idSubasta) {

        // Chequeamos que el que envia el mensaje sea el creador de la subasta.
        require(subastas[_idSubasta].creador == msg.sender, "No eres el creador de la subasta.");

        // Finaliza el Modifier.
        _;

    }

    modifier soloSubastaFinalizada(uint256 _idSubasta) {

        // Chequeamos que la subasta haya finalizado.
        require(subastas[_idSubasta].tiempoFin < block.timestamp, "La subasta no ha finalizado aun.");

        // Finaliza el Modifier.
        _;

    }

    modifier soloSubastaActiva(uint256 _idSubasta) {

        // Chequeamos que la subasta no haya sido claimeada aun.
        require(subastas[_idSubasta].estadoActiva, "La subasta ya ha sido reclamada.");

        // Finaliza el Modifier-
        _;

    }


    function crearSubasta(string memory _articulo, string memory _descripcion, uint256 _precio, uint256 _tiempoFin) public {

        // Chequeamos que los datos ingresados son correctos.
        require(keccak256(abi.encodePacked(_articulo)) != keccak256(abi.encodePacked("")), "El nombre no puede estar vacio.");
        require(keccak256(abi.encodePacked(_descripcion)) != keccak256(abi.encodePacked("")), "La descripcion no puede estar vacia.");
        require(_precio > 0, "El precio debe ser mayor a 0.");
        require(_tiempoFin > 0, "El tiempo de finalizacion debe ser mayor a 0.");

        // Agregar nueva subasta.
        subastas.push(Subasta(_articulo, _descripcion, _precio, _tiempoFin + block.timestamp, msg.sender, msg.sender, true));
        subastasDeDireccion[msg.sender].push(subastas.length);

        // Emitimos el Evento Correspondiente.
        emit nuevaSubasta(_articulo, _descripcion, _precio, _tiempoFin + block.timestamp, msg.sender);

    }


    function ofertarSubasta(uint _idSubasta) payable public {

        // Chequeamos que esté todo bien.
        require(subastas[_idSubasta].tiempoFin > block.timestamp, "Subasta ya Finalizada.");
        require(subastas[_idSubasta].precio < msg.value, "La subasta posee un valor mayor al ingresado.");
        require(subastas[_idSubasta].ganadorActual != msg.sender, "Ya eres el mayor ofertante.");
        require(subastas[_idSubasta].creador != msg.sender, "El creador no puede ofertar.");

        // Chequeamos que se haya subido la oferta al nmenos una vez.
        if(subastas[_idSubasta].ganadorActual != subastas[_idSubasta].creador) {

            // Devolvemos el Ether al ofertante anterior.
            payable(subastas[_idSubasta].ganadorActual).transfer(subastas[_idSubasta].precio);

        }

        // Actualizamos el precio.
        subastas[_idSubasta].precio = msg.value;
        
        // Actualizamos el mayor ofertante actual.
        subastas[_idSubasta].ganadorActual = msg.sender;

        // Emitimos el evento correspondiente.
        emit nuevaOferta(_idSubasta, msg.value, msg.sender);

    }


    function completarSubasta(uint256 _idSubasta) public soloCreador(_idSubasta) soloSubastaFinalizada(_idSubasta) soloSubastaActiva(_idSubasta) {

        // Si se desea realizar una lógica para transferir un objeto, tiene que ser antes de transferir el ether al creador de la misma.

        // Se desactiva la subasta antes de transferir el ether.
        subastas[_idSubasta].estadoActiva = false;

        // Se le transfiere el ether de la subasta al creador.
        payable(subastas[_idSubasta].creador).transfer(subastas[_idSubasta].precio);

        // Emitimos el evento correspondiente.
        emit ganadorDeSubasta(subastas[_idSubasta].ganadorActual, _idSubasta);

    }


    function devolverSubastas() public view returns(Subasta[] memory) {
        
        // Devolvemos el array de subastas.
        return subastas;

    }


    function devolverSubasta(uint _idSubasta) public view returns(Subasta memory) {

        // Devolvemos la subasa en el indice.
        return subastas[_idSubasta];

    }


    function devolverSubastasDeDireccion(address _direccion) public view returns(uint[] memory) {

        // Devolvemos el array enlazado con la direccion en el mapping.
        return subastasDeDireccion[_direccion];

    }


    function tiempoRestanteSubasta(uint256 _idSubasta) public view returns(uint) {

        // Devolvemos el tiempo restante, si es que no ha finalizado.
        if (subastas[_idSubasta].tiempoFin < block.timestamp) {
            return 0;
        } else {
            return subastas[_idSubasta].tiempoFin - block.timestamp;
        }

    }

}