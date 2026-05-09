// File: 1_corrected_cdf.v
`timescale 1 ns / 1ps
module decode (
  input  wire reset,
  input  wire pclk,
  input  wire pclkx2,
  input  wire pclkx10,
  input  wire serdesstrobe,
  input  wire din_p,
  input  wire din_n,
  input  wire other_ch0_vld,
  input  wire other_ch1_vld,
  input  wire other_ch0_rdy,
  input  wire other_ch1_rdy,