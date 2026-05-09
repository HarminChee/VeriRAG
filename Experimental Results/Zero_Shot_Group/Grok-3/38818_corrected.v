`timescale 1ns / 1ps
module controlador_VGA
(
    input wire clock, reset,
    input wire [7:0] in_dato, port_id,
    input wire write_strobe, k