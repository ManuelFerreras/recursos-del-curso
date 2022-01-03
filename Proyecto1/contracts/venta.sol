// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


contract VentaDeObjetos {
    
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
    modifier soloCreador(uint256 idSubasta_) {

        // Chequeamos que el que envia el mensaje sea el creador de la subasta.
        require(subastas[idSubasta_].creador == msg.sender, "No eres el creador de la subasta.");

        // Finaliza el Modifier.
        _;

    }

    modifier soloSubastaFinalizada(uint256 idSubasta_) {

        // Chequeamos que la subasta haya finalizado.
        require(subastas[idSubasta_].tiempoFin < block.timestamp, "La subasta no ha finalizado aun.");

        // Finaliza el Modifier.
        _;

    }

    modifier soloSubastaActiva(uint256 idSubasta_) {

        // Chequeamos que la subasta no haya sido claimeada aun.
        require(subastas[idSubasta_].estadoActiva, "La subasta ya ha sido reclamada.");

        // Finaliza el Modifier-
        _;

    }


    function crearSubasta(string memory articulo_, string memory descripcion_, uint256 precio_, uint256 tiempoFin_) public {

        // Chequeamos que los datos ingresados son correctos.
        require(keccak256(abi.encodePacked(articulo_)) != keccak256(abi.encodePacked("")), "El nombre no puede estar vacio.");
        require(keccak256(abi.encodePacked(descripcion_)) != keccak256(abi.encodePacked("")), "La descripcion no puede estar vacia.");
        require(precio_ > 0, "El precio debe ser mayor a 0.");
        require(tiempoFin_ > 0, "El tiempo de finalizacion debe ser mayor a 0.");

        // Agregar nueva subasta.
        subastas.push(Subasta(articulo_, descripcion_, precio_, tiempoFin_ + block.timestamp, msg.sender, msg.sender, true));
        subastasDeDireccion[msg.sender].push(subastas.length);

        // Emitimos el Evento Correspondiente.
        emit nuevaSubasta(articulo_, descripcion_, precio_, tiempoFin_ + block.timestamp, msg.sender);

    }


    function ofertarSubasta(uint idSubasta_) payable public {

        // Chequeamos que esté todo bien.
        require(subastas[idSubasta_].tiempoFin > block.timestamp, "Subasta ya Finalizada.");
        require(subastas[idSubasta_].precio < msg.value, "La subasta posee un valor mayor al ingresado.");
        require(subastas[idSubasta_].ganadorActual != msg.sender, "Ya eres el mayor ofertante.");
        require(subastas[idSubasta_].creador != msg.sender, "El creador no puede ofertar.");

        // Chequeamos que se haya subido la oferta al nmenos una vez.
        if(subastas[idSubasta_].ganadorActual != subastas[idSubasta_].creador) {

            // Devolvemos el Ether al ofertante anterior.
            payable(subastas[idSubasta_].ganadorActual).transfer(subastas[idSubasta_].precio);

        }

        // Actualizamos el precio.
        subastas[idSubasta_].precio = msg.value;
        
        // Actualizamos el mayor ofertante actual.
        subastas[idSubasta_].ganadorActual = msg.sender;

        // Emitimos el evento correspondiente.
        emit nuevaOferta(idSubasta_, msg.value, msg.sender);

    }


    function completarSubasta(uint256 idSubasta_) public soloCreador(idSubasta_) soloSubastaFinalizada(idSubasta_) soloSubastaActiva(idSubasta_) {

        // Si se desea realizar una lógica para transferir un objeto, tiene que ser antes de transferir el ether al creador de la misma.

        // Se desactiva la subasta antes de transferir el ether.
        subastas[idSubasta_].estadoActiva = false;

        // Se le transfiere el ether de la subasta al creador.
        payable(subastas[idSubasta_].creador).transfer(subastas[idSubasta_].precio);

        // Emitimos el evento correspondiente.
        emit ganadorDeSubasta(subastas[idSubasta_].ganadorActual, idSubasta_);

    }


    function devolverSubastas() public view returns(Subasta[] memory) {
        
        // Devolvemos el array de subastas.
        return subastas;

    }


    function devolverSubasta(uint idSubasta_) public view returns(Subasta memory) {

        // Devolvemos la subasa en el indice.
        return subastas[idSubasta_];

    }


    function devolverSubastasDeDireccion(address direccion_) public view returns(uint[] memory) {

        // Devolvemos el array enlazado con la direccion en el mapping.
        return subastasDeDireccion[direccion_];

    }


    function tiempoRestanteSubasta(uint256 idSubasta_) public view returns(uint) {

        // Devolvemos el tiempo restante, si es que no ha finalizado.
        if (subastas[idSubasta_].tiempoFin < block.timestamp) {
            return 0;
        } else {
            return subastas[idSubasta_].tiempoFin - block.timestamp;
        }

    }

}