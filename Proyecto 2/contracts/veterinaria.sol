// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract veterinaria {

    address duenio;

    constructor() {

        // Seteamos como dueño al creador del contrato.
        duenio = msg.sender;

    }

}