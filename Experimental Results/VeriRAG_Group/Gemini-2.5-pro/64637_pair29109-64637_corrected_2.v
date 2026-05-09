// **************************************************************************
//    tube.v - top level module for the Beeb816 Acorn Tube Replacement
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
             input        test_i, // DFT test mode signal
             input        scan_clk, // DFT scan clock
             input [2:0]  h_addr,
             input        h_cs_b,
`ifdef SEPARATE_HOST_DATABUSSES_D
             input [7:0]  h_data_in,
             output [7:0] h_data_out,
`else
             inout [7:0]  h_data,
`endif
             input        h_phi2,
             input        h_rdnw,
             input        h_rst_b,
             output       h_irq_b,
`ifndef OMIT_DMA_PINS_D
             output       drq,
             input        dack_b,
`endif

             input [2:0]  p_addr,
             input        p_cs_b,
`ifdef SEPARATE_PARASITE_DATABUSSES_D
             input [7:0]  p_data_in,
             output [7:0] p_data_out,
`else
             inout [7:0]  p_data,
`endif

             input        p_rdnw,
             input        p_phi2,
             output       p_rst_b,
             output       p_nmi_b,
             output       p_irq_b
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

   // Wires from FIFO block
   wire         p_r3_two_bytes_available_w;
   wire [7:0]   p_data_w;
   wire [7:0]   h_data_w;
   wire [3:0]   p_data_available_w;
   wire [3:0]   p_full_w;
   wire [3:0]   h_data_available_w;
   wire [3:0]   h_full_w;
   wire         ph_zero_r3_bytes_avail_w;

   // Intermediate signals for selects
   wire [3:0] h_select_fifo_d_w;
   wire       h_select_reg0_d_w;
   wire [3:0] p_select_fifo_d_w;

   // Registers
   reg        h_select_reg0_q_r;
   reg [3:0]  h_select_fifo_q_r;
   reg [3:0]  p_select_fifo_r;
   reg        h_rdnw_q_r;
   reg        p_rdnw_q_r;
   reg        n_flag; // Intermediate flag for NMI logic
   reg [7:0]  h_data_r; // Output data register for host reads
   reg [7:0]  p_data_r; // Output data register for parasite reads
   reg        p_nmi_b_r; // Internal NMI state before output buffer
   reg [6:0]  h_reg0_q_r; // Host control/status register bits (excluding S)


   // Wires for control logic
   wire [6:0] h_reg0_d_w; // Next state for h_reg0_q_r
   wire [5:0] p_reg0_q_r; // Parasite view of status bits (derived from h_reg0_q_r)
   wire       local_rst_b_w; // Internal reset used by logic blocks

   // DFT signals
   wire       dft_clk_h;
   wire       dft_clk_p;
   wire       dft_rst_b;
   wire       func_rst_b;

   assign dft_clk_h = test_i ? scan_clk : h_phi2;
   assign dft_clk_p = test_i ? scan_clk : p_phi2;

   // Combine hard and soft resets. Use muxed reset for DFT.
   // Soft reset (T flag) clears internal state but not parasite reset output p_rst_b
   assign func_rst_b = !(!h_rst_b | h_reg0_q_r[`T_IDX]); // Functional reset including soft reset
   assign dft_rst_b = test_i ? h_rst_b : func_rst_b; // Muxed reset: use primary h_rst_b for test, functional reset otherwise.
   assign local_rst_b_w = dft_rst_b; // Use this muxed reset internally


   // Assign to primary IOs
`ifndef OMIT_DMA_PINS_D
   // "DMA Operation
   //  The DRQ pin (active state = 1) may be used to request a DMA transfer - when M = 1 DRQ will have the
   //  opposite value to PNMI, and depends on V in exactly the same way (see description of interrupt operation)."
   assign drq = h_reg0_q_r[ `M_IDX] & !p_nmi_b_r  ;
`endif


   // host interrupt active only if enabled and data ready in register 4 (FIFO 3)
   assign h_irq_b = ( h_reg0_q_r[`Q_IDX] & h_data_available_w[3] ) ? 1'b0 : `H_INTERRUPT_OFF_D ;
   // parasite NMI logic result drives output buffer
   assign p_nmi_b = (p_nmi_b_r) ?  `P_INTERRUPT_OFF_D : 1'b0 ;
   // parasite IRQ active if enabled for FIFO 0 (Reg 1) or FIFO 3 (Reg 4) and data available
   assign p_irq_b = ( (h_reg0_q_r[`I_IDX] & p_data_available_w[0]) | (h_reg0_q_r[`J_IDX] & p_data_available_w[3]) ) ? 1'b0 : `P_INTERRUPT_OFF_D  ;

   // Active p_rst_b when '1' in P flag or host reset is applied
   // Output reset should follow functional reset logic, not DFT internal reset
   // p_rst_b is active LOW. P=1 means activate reset (low). h_rst_b is active low.
   assign p_rst_b = (!h_reg0_q_r[`P_IDX] & h_rst_b) ;

`ifdef SEPARATE_HOST_DATABUSSES_D
   wire [7:0] 	h_data_int; // Internal wire for host data input
   assign h_data_int = h_data_in;
   assign h_data_out = h_data_r;
`else // SEPARATE_HOST_DATABUSSES_D
   wire [7:0] 	h_data_int; // Internal wire for host data bus
   assign h_data_int = h_data;
   // Use functional clock h_phi2 for tri-state control
   assign h_data = ( h_rdnw && !h_cs_b && h_phi2 ) ? h_data_r : 8'bzzzzzzzz;
`endif // SEPARATE_HOST_DATABUSSES_D

`ifdef SEPARATE_PARASITE_DATABUSSES_D
   wire [7:0] 	p_data_int; // Internal wire for parasite data input
   assign p_data_int = p_data_in;
   assign p_data_out = p_data_r;
`else // SEPARATE_PARASITE_DATABUSSES_D
   wire [7:0] 	p_data_int; // Internal wire for parasite data bus
   assign p_data_int = p_data;
   // Use functional p_rdnw and p_cs_b for tri-state control
   assign p_data = ( p_rdnw && !p_cs_b ) ? p_data_r : 8'bzzzzzzzz;
`endif // SEPARATE_PARASITE_DATABUSSES_D

   // Compute register selects for host side (combinational)
   assign h_select_reg0_d_w    = !h_cs_b && ( h_addr == 3'b0);
   assign h_select_fifo_d_w[0] = !h_cs_b & ( h_addr == 3'h1); // FIFO 0 (Reg 1)
   assign h_select_fifo_d_w[1] = !h_cs_b & ( h_addr == 3'h3); // FIFO 1 (Reg 2)
   assign h_select_fifo_d_w[2] = !h_cs_b & ( h_addr == 3'h5); // FIFO 2 (Reg 3)
   assign h_select_fifo_d_w[3] = !h_cs_b & ( h_addr == 3'h7); // FIFO 3 (Reg 4)

   // Compute register selects for parasite side (combinational)
   assign p_select_fifo_d_w[0] = !p_cs_b & ( p_addr == 3'h1); // FIFO 0 (Reg 1)
   assign p_select_fifo_d_w[1] = !p_cs_b & ( p_addr == 3'h3); // FIFO 1 (Reg 2)
   assign p_select_fifo_d_w[2] = !p_cs_b & ( p_addr == 3'h5); // FIFO 2 (Reg 3)
   assign p_select_fifo_d_w[3] = !p_cs_b & ( p_addr == 3'h7); // FIFO 3 (Reg 4)

   // Flag definitions from the Tube Application Note
   // These flags are set or cleared according to the value of S, eg writing 92 (hex)
   // to address 0 will set V and I to 1 but not affect the other flags, whereas 12 (hex)
   // would clear V and I without changing the other flags. All flags except T are read
   // out directly as the least significant 6 bits from address 0.

   // Calculate next state for host control/status register flags (combinational)
`ifdef DEBUG_NO_TUBE_D
   // Don't allow host interrupts to be enabled and prevent tube from being recognized
   assign h_reg0_d_w[`Q_IDX] = 1'b0; // Force Q to 0 if debug flag set
`else
   assign h_reg0_d_w[`Q_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `Q_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `Q_IDX] ): h_reg0_q_r [ `Q_IDX];
`endif
   assign h_reg0_d_w[`I_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `I_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `I_IDX] ): h_reg0_q_r [ `I_IDX];
   assign h_reg0_d_w[`J_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `J_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `J_IDX] ): h_reg0_q_r [ `J_IDX];
   assign h_reg0_d_w[`V_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `V_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `V_IDX] ): h_reg0_q_r [ `V_IDX];
   assign h_reg0_d_w[`M_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? (