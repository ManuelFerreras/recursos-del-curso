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


    // Struct Para Crear Mascotas.
    struct Mascota {
        string tipoMascota;
        string nombreMascota;
        string apellidoMascota;
    }

    // Arreglo de las Mascotas Creadas.
    Mascota[] mascotas;

    // Mapping de las Mascotas de una Direccion.
    mapping(address => uint[]) mascotasDeDireccion;

    // Mapping para los servicios tomados por mascota.
    mapping(uint => string[]) serviciosTomadosPorMascota;


    // Eventos
    event nuevoServicio(string);
    event servicioTomado(address, uint);
    event servicioDesactivado(string);
    event nuevaMascota(string, string, address, uint);


    // Modificadores
    modifier soloElDuenio() {

        // Chequeamos que el Dueño sea el que llama la funcion.
        require(duenio == msg.sender, "No eres el Duenio de la Veterinaria.");

        // Finalizamos el Modifier.
        _;

    }

    modifier soloElDuenioDeMascota(uint _idMascota) {

        // Chequeamos que el que envia la transaccion sea el duenio de la mascota.
        bool _duenio = false;

        // Chequeamos si la mascota esta en la lista del duenio.
        for(uint256 i = 0; i < mascotasDeDireccion[msg.sender].length; i++) {
            if (mascotasDeDireccion[msg.sender][i] == _idMascota) {
                _duenio = true;
            }
        }

        // Chequeamos si es el duenio.
        require(_duenio == true, "No eres el duenio de la mascota.");

        // Finalizamos el Modifier.
        _;
        
    }

    modifier soloServicioActivo(string memory _nombreServicio) {

        // Chequeamos que el servicio este activo.
        require(servicios[_nombreServicio].estadoServicio, "El servicio deseado no se encuentra disponible.");

        // Finalizamos el modifier.
        _;

    }


    function crearServicio(string memory _nombreServicio, string memory _descripcionServicio, uint256 _precio) public soloElDuenio {

        // Chequeamos que la información ingresada sea correcta.
        require(keccak256(abi.encodePacked(_nombreServicio)) != keccak256(abi.encodePacked("")), "El Nombre del servicio no puede estar vacio.");
        require(keccak256(abi.encodePacked(_descripcionServicio)) != keccak256(abi.encodePacked("")), "La descripcion del servicio no puede estar vacio.");
        require(_precio > 0, "El precio debe ser mayor a 0");

        // Creamos el nuevo servicio.
        servicios[_nombreServicio] = Servicio(_nombreServicio, _descripcionServicio, _precio, true);
        // Agregamos el nombre del servicio al arreglo de nombres.
        nombreServicios.push(_nombreServicio);

        // Emitimos el evento correspondiente.
        emit nuevoServicio(_nombreServicio);

    }


    function desactivarServicio(string memory _nombreServicio) public soloElDuenio {

        // Chequeamos que el servicio este activo.
        require(servicios[_nombreServicio].estadoServicio, "El servicio ya ha sido desactivado.");

        // Desactivamos el servicio.
        servicios[_nombreServicio].estadoServicio = false;

        // Emitimos el evento correspondiente.
        emit servicioDesactivado(_nombreServicio);

    }


    function crearMascota(string memory _tipoMascota, string memory _nombreMascota, string memory _apellidoMascota) public {

        // Creamos la mascota.
        mascotas.push(Mascota(_tipoMascota, _nombreMascota, _apellidoMascota));

        // Agregamos el id de la mascota a las mascotas de la direccion.
        mascotasDeDireccion[msg.sender].push(mascotas.length - 1);

        // Emitimos el evento correspondiente.
        emit nuevaMascota(_tipoMascota, _nombreMascota, msg.sender, mascotas.length - 1);

    }


    function tomarServicio(string memory _nombreServicio, uint _idMascota) public payable soloElDuenioDeMascota(_idMascota) soloServicioActivo(_nombreServicio) {

        // Chequeamos que se haya enviado la cantidad de ether necesaria.
        require(msg.value >= servicios[_nombreServicio].precio, "No se ha enviado suficiente ether.");

        // Calculamos el ether que ha sobrado de la transaccion.
        uint256 etherSobrante_ = msg.value - servicios[_nombreServicio].precio;

        // Devolvemos el ether sobrante al remitente.
        if (etherSobrante_ > 0) {
            payable(msg.sender).transfer(etherSobrante_);
        }

        // Agregamos el evento tomado a la mascota correspondiente.
        serviciosTomadosPorMascota[_idMascota].push(_nombreServicio);

        // Emitimos el evento correspondiente.
        emit servicioTomado(msg.sender, _idMascota);

    } 


    function devolverServiciosTomadosPorMascota(uint256 _idMascota) public view returns(string[] memory) {

        // Devolvemos los servicios que la mascota ha tomado.
        return serviciosTomadosPorMascota[_idMascota];

    }

}