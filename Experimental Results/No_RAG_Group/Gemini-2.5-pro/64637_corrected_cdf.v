// **************************************************************************
//    1_corrected_cdf.v - top level module for the Beeb816 Acorn Tube Replacement
//
//    COPYRIGHT 2010 Richard Evans, Ed Spittles
//
//    This file is part of tube - an Acorn Tube ULA compatible system.
//
//    tube is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    tube is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with tube.  If not, see <http://www.gnu.org/licenses/>.
//
// **************************************************************************
// Compile time Options
// OMIT_DMA_PINS_D     - if set eliminates drq and dack_b pins, not required
//                       for 6502 and Z80 coprocessors
// ENABLE_DMA_D        - set this to enable DMA operation. Since the 6502/Z80
//                       don't require it we can't verify it on our board so
//                       leave this disabled (and the logic slightly reduced)
// DEBUG_NO_TUBE_D     - if set forces the LSB of register 0 (the status/
//                       command word) to return '0' and so not be recognized
//                       on boot by the host system
// TWOSTATE_PARASITE_INTERRUPTS_D - if set then parasite interrupt pins are driven high and low
//                                  if not set (default) then they are open collector
//
// **************************************************************************
`timescale 1ns /1ns

// Interrupts can be open collector type outputs in non-trivial systems
`ifdef TWOSTATE_HOST_INTERRUPTS_D
 `define H_INTERRUPT_OFF_D 1'b1
`else
 `define H_INTERRUPT_OFF_D 1'bz
`endif
`ifdef TWOSTATE_PARASITE_INTERRUPTS_D
 `define P_INTERRUPT_OFF_D 1'b1
`else
 `define P_INTERRUPT_OFF_D 1'bz
`endif

// Define bit positions of all flags
`define S_IDX 7
`define T_IDX 6
`define P_IDX 5
`define V_IDX 4
`define M_IDX 3
`define J_IDX 2
`define I_IDX 1
`define Q_IDX 0

module tube (
             input [2:0] h_addr,
             input       h_cs_b,
`ifdef SEPARATE_HOST_DATABUSSES_D
             input [7:0]  h_data_in,
             output reg [7:0] h_data_out, // Made reg for assignment in always block
`else
             inout [7:0] h_data,
`endif
             input       h_phi2,
             input       h_rdnw,
             input       h_rst_b,
             output      h_irq_b,
`ifndef OMIT_DMA_PINS_D
             output      drq,
             input       dack_b,
`endif

             input [2:0] p_addr,
             input       p_cs_b,
`ifdef SEPARATE_PARASITE_DATABUSSES_D
             input [7:0]  p_data_in,
             output reg [7:0] p_data_out, // Made reg for assignment in always block
`else
             inout [7:0] p_data,
`endif

             input       p_rdnw,
             input       p_phi2,
             output      p_rst_b,
             output      p_nmi_b,
             output      p_irq_b
             );

`ifdef OMIT_DMA_PINS_D
   wire       dack_b_w = 1'b1;
`else
 `ifdef ENABLE_DMA_D
   wire       dack_b_w = dack_b;
 `else
   wire       dack_b_w = 1'b1;
 `endif
`endif

   wire       p_r3_two_bytes_available_w;

   wire [3:0] h_select_fifo_d_w;
   wire       h_select_reg0_d_w;
   reg        h_select_reg0_q_r;
   reg [3:0]  h_select_fifo_q_r;
   reg [3:0]  p_select_fifo_r;
   reg        h_rdnw_q_r;
   reg        n_flag; // Should be wire? Assigned combinationally


   reg [7:0]    h_data_r; // Internal reg for holding data to be driven out
   reg [7:0]    p_data_r; // Internal reg for holding data to be driven out
   reg          p_nmi_b_r; // Should be wire? Assigned combinationally

   reg [6:0]    h_reg0_q_r;
   reg [5:0]    p_reg0_q_r;

   wire [7:0]   p_data_w; // Data read from parasite-host FIFO
   wire [7:0]   h_data_w; // Data read from host-parasite FIFO (Incorrect comment? Should be parasite-host)

   wire [3:0]   p_data_available_w;
   wire [3:0]   p_full_w;
   wire [3:0]   h_data_available_w;
   wire [3:0]   h_full_w;

   wire [6:0]   h_reg0_d_w;
   wire         local_rst_b_w;
   wire         ph_zero_r3_bytes_avail_w   ;

   wire         p_nmi_b_comb_w; // Renamed from p_nmi_b_r as it's assigned combinationally

   // Assign to primary IOs
`ifndef OMIT_DMA_PINS_D
   // "DMA Operation
   //  The DRQ pin (active state = 1) may be used to request a DMA transfer - when M = 1 DRQ will have the
   //  opposite value to PNMI, and depends on V in exactly the same way (see description of interrupt operation)."
   assign drq = h_reg0_q_r[ `M_IDX] & !p_nmi_b_comb_w  ; // Use combinational value
`endif


   // host interrupt active only if enabled and data ready in register 4
   assign h_irq_b = ( h_reg0_q_r[`Q_IDX] & h_data_available_w[3] ) ? 1