// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract veterinaria {

    // Variables de Manejo de la Veterinaria.
    address duenio;

    constructor() {

        // Seteamos como dueño al creador del contrato.
        duenio = msg.sender;

    }


    // Struct Para Crear Servicios.
    struct Servicio {
        string nombreServicio;
        string descripcionServicio;
        uint256 precio;
        bool estadoServicio;
    }

    // Mapping Para Guardar la Informacion de los Servicios.
    mapping(string => Servicio) servicios;
    // Array Para Guardar los Nombres de los Servicios.
    string[] nombreServicios;


    // Eventos
    event nuevoServicio(string);
    event servicioTomado(address, uint);
    event nuevaMascota(string, uint);


    // Modificadores
    modifier soloElDuenio() {

        // Chequeamos que el Dueño sea el que llama la funcion.
        require(duenio == msg.sender, "No eres el Duenio de la Veterinaria.");

        // Finalizamos el Modifier.
        _;

    }


    function crearServicio(string memory nombreServicio_, string memory descripcionServicio_, uint256 precio_) public soloElDuenio {

        // Chequeamos que la información ingresada sea correcta.
        require(keccak256(abi.encodePacked(nombreServicio_)) != keccak256(abi.encodePacked("")), "El Nombre del servicio no puede estar vacio.");
        require(keccak256(abi.encodePacked(descripcionServicio_)) != keccak256(abi.encodePacked("")), "La descripcion del servicio no puede estar vacio.");
        require(precio_ > 0, "El precio debe ser mayor a 0");

        // Creamos el nuevo servicio.
        servicios[nombreServicio_] = Servicio(nombreServicio_, descripcionServicio_, precio_, true);
        // Agregamos el nombre del servicio al arreglo de nombres.
        nombreServicios.push(nombreServicio_);

        // Emitimos el evento correspondiente.
        emit nuevoServicio(nombreServicio_);

    }


}