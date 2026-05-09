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

// Placeholder for tube_fifo module definition
/* module tube_fifo #(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=4) (
    input                   rst_b,     // Asynchronous Reset (connect to dft_local_rst_b_low)
    input                   h_clk,     // Host Clock (connect to dft_h_clk)
    input                   p_clk,     // Parasite Clock (connect to dft_p_clk)
    input                   h_wr,      // Host Write Enable
    input [DATA_WIDTH-1:0]  h_data_in, // Host Data In
    output[DATA_WIDTH-1:0]  h_data_out,// Host Data Out
    output                  h_full,    // Host FIFO Full
    output                  h_empty,   // Host FIFO Empty (p_data_available = !h_empty)
    input                   h_rd,      // Host Read Enable
    input                   p_wr,      // Parasite Write Enable
    input [DATA_WIDTH-1:0]  p_data_in, // Parasite Data In
    output[DATA_WIDTH-1:0]  p_data_out,// Parasite Data Out
    output                  p_full,    // Parasite FIFO Full
    output                  p_empty,   // Parasite FIFO Empty (h_data_available = !p_empty)
    input                   p_rd       // Parasite Read Enable
);
 // FIFO implementation here...
endmodule */


module tube (
             input        test_i, // DFT input
             input        scan_clk, // DFT input
             input [2:0]  h_addr,
             input        h_cs_b,
`ifdef SEPARATE_HOST_DATABUSSES_D
             input [7:0]  h_data_in,
             output reg [7:0] h_data_out,
`else
             inout [7:0] h_data,
`endif
             input        h_phi2,
             input        h_rdnw,
             input        h_rst_b, // Primary reset (active low)
             output       h_irq_b,
`ifndef OMIT_DMA_PINS_D
             output       drq,
             input        dack_b,
`endif

             input [2:0] p_addr,
             input       p_cs_b,
`ifdef SEPARATE_PARASITE_DATABUSSES_D
             input [7:0]  p_data_in,
             output reg [7:0] p_data_out,
`else
             inout [7:0] p_data,
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

   // DFT clock muxing
   wire dft_h_clk;
   assign dft_h_clk = test_i ? scan_clk : h_phi2;
   wire dft_p_clk;
   assign dft_p_clk = test_i ? scan_clk : p_phi2;

   // DFT Reset Logic
   wire         local_rst_b_w; // Original functional reset (active low)
   wire         dft_local_rst_b_low; // DFT-friendly reset (active low)

   // Combine hard and soft resets (functional, active low)
   assign local_rst_b_w = h_rst_b && !h_reg0_q_r[`T_IDX] ; // Active low functional reset
   // DFT-friendly reset (active low): Use only primary reset in test mode
   assign dft_local_rst_b_low = test_i ? h_rst_b : local_rst_b_w;


   // Internal signals
   wire       p_r3_two_bytes_available_w; // Assumed output from FIFO 3 logic
   wire       ph_zero_r3_bytes_avail_w;   // Assumed output from FIFO 3 logic

   wire [3:0] h_select_fifo_d_w;
   wire       h_select_reg0_d_w;
   reg        h_select_reg0_q_r;
   reg [3:0]  h_select_fifo_q_r;
   reg [3:0]  p_select_fifo_r;
   reg        h_rdnw_q_r;
   reg        p_rdnw_q_r;
   reg        n_flag; // Combinational flag for NMI logic

   reg [7:0]  h_data_r; // Combinational output mux for host read data
   reg [7:0]  p_data_r; // Combinational output mux for parasite read data
   reg        p_nmi_b_r; // Registered NMI signal

   reg [6:0]  h_reg0_q_r; // Host control/status register bits [6:0]
   reg [5:0]  p_reg0_q_r; // Parasite status register bits [5:0] (read-only for host)

   wire [7:0] p_data_w; // Data output from parasite-read FIFOs (muxed below)
   wire [7:0] h_data_w; // Data output from host-read FIFOs (muxed below)

   wire [7:0] p_fifo0_data_out_w;
   wire [7:0] p_fifo1_data_out_w;
   wire [7:0] p_fifo2_data_out_w;
   wire [7:0] p_fifo3_data_out_w;
   wire [7:0] h_fifo0_data_out_w;
   wire [7:0] h_fifo1_data_out_w;
   wire [7:0] h_fifo2_data_out_w;
   wire [7:0] h_fifo3_data_out_w;

   wire [3:0] p_data_available_w; // Parasite FIFO has data available (!empty)
   wire [3:0] p_full_w;           // Parasite FIFO is full
   wire [3:0] h_data_available_w; // Host FIFO has data available (!empty)
   wire [3:0] h_full_w;           // Host FIFO is full

   wire [6:0] h_reg0_d_w; // Next state logic for h_reg0_q_r

   // Internal data bus wires
`ifdef SEPARATE_HOST_DATABUSSES_D
   wire [7:0] 	h_data_int;
   assign h_data_int = h_data_in;
   always @(*) begin // Combinational assignment for output
      h_data_out = h_data_r;
   end
`else // SEPARATE_HOST_DATABUSSES_D
   wire [7:0] h_data_int;
   assign h_data = ( h_rdnw_q_r && h_select_reg0_q_r || h_select_fifo_q_r != 4'b0 ) ? h_data_r : 8'bzzzzzzzz; // Output enable controlled by registered select and RDNW
   assign h_data_int = h_data;
`endif // SEPARATE_HOST_DATABUSSES_D

`ifdef SEPARATE_PARASITE_DATABUSSES_D
   wire [7:0] 	p_data_int;
   assign p_data_int = p_data_in;
    always @(*) begin // Combinational assignment for output
       p_data_out = p_data_r;
    end
`else // SEPARATE_PARASITE_DATABUSSES_D
   wire [7:0] p_data_int;
   assign p_data = ( p_rdnw_q_r && (p_select_fifo_r != 4'b0 || (p_addr == 3'h0 && !p_cs_b)) ) ? p_data_r : 8'bzzzzzzzz; // Output enable controlled by registered select and RDNW
   assign p_data_int = p_data;
`endif // SEPARATE_PARASITE_DATABUSSES_D


   // Assign to primary IOs
`ifndef OMIT_DMA_PINS_D
   // "DMA Operation
   //  The DRQ pin (active state = 1) may be used to request a DMA transfer - when M = 1 DRQ will have the
   //  opposite value to PNMI, and depends on V in exactly the same way (see description of interrupt operation)."
   assign drq = h_reg0_q_r[ `M_IDX] & !p_nmi_b_r  ;
`endif

   // host interrupt active only if enabled and data ready in register 4 (FIFO 3)
   assign h_irq_b = ( h_reg0_q_r[`Q_IDX] & h_data_available_w[3] ) ? 1'b0 : `H_INTERRUPT_OFF_D ;
   assign p_nmi_b = (p_nmi_b_r) ?  `P_INTERRUPT_OFF_D : 1'b0 ; // Use registered NMI signal
   // parasite IRQ active
   assign p_irq_b = ( (h_reg0_q_r[`I_IDX] & p_data_available_w[0]) | (h_reg0_q_r[`J_IDX] & p_data_available_w[3]) ) ? 1'b0 : `P_INTERRUPT_OFF_D  ;

   // Active p_rst_b when '1' in P flag or host reset is applied (use primary host reset)
   assign p_rst_b = !(h_reg0_q_r[`P_IDX] && h_rst_b) ; // p_rst_b is active low


   // Compute register selects for host side (combinational)
   assign h_select_reg0_d_w    = !h_cs_b && ( h_addr == 3'b0) && h_phi2; // Qualify with clock
   assign h_select_fifo_d_w[0] = !h_cs_b && ( h_addr == 3'h1) && h_phi2; // Addr 1&2 -> FIFO 0
   assign h_select_fifo_d_w[1] = !h_cs_b && ( h_addr == 3'h3) && h_phi2; // Addr 3&4 -> FIFO 1
   assign h_select_fifo_d_w[2] = !h_cs_b && ( h_addr == 3'h5) && h_phi2; // Addr 5&6 -> FIFO 2
   assign h_select_fifo_d_w[3] = !h_cs_b && ( h_addr == 3'h7) && h_phi2; // Addr 7   -> FIFO 3


   // Register host select signals
   always @(posedge dft_h_clk or negedge dft_local_rst_b_low) begin
       if (!dft_local_rst_b_low) begin
           h_select_reg0_q_r <= 1'b0;
           h_select_fifo_q_r <= 4'b0;
           h_rdnw_q_r        <= 1'b1; // Default to read
       end else begin
           h_select_reg0_q_r <= h_select_reg0_d_w;
           h_select_fifo_q_r <= h_select_fifo_d_w;
           h_rdnw_q_r        <= h_rdnw; // Register RDNW signal
       end
   end

   // Register parasite select signals
   always @(posedge dft_p_clk or negedge dft_local_rst_b_low) begin
       if (!dft_local_rst_b_low) begin
           p_select_fifo_r <= 4'b0;
           p_rdnw_q_r      <= 1'b1; // Default to read
       end else begin
           // Parasite select logic (combinational part)
           wire [3:0] p_select_fifo_d_w;
           assign p_select_fifo_d_w[0] = !p_cs_b && ( p_addr == 3'h1); // Addr 1&2 -> FIFO 0
           assign p_select_fifo_d_w[1] = !p_cs_b && ( p_addr == 3'h3); // Addr 3&4 -> FIFO 1
           assign p_select_fifo_d_w[2] = !p_cs_b && ( p_addr == 3'h5); // Addr 5&6 -> FIFO 2
           assign p_select_fifo_d_w[3] = !p_cs_b && ( p_addr == 3'h7); // Addr 7   -> FIFO 3

           p_select_fifo_r <= p_select_fifo_d_w;
           p_rdnw_q_r      <= p_rdnw; // Register RDNW signal
       end
   end


   // Flag definitions from the Tube Application Note
   // These flags are set or cleared according to the value of S, eg writing 92 (hex)
   // to address 0 will set V and I to 1 but not affect the other flags, whereas 12 (hex)
   // would clear V and I without changing the other flags. All flags except T are read
   // out directly as the least significant 6 bits from address 0.

`ifdef DEBUG_NO_TUBE_D
   // Don't allow host interrupts to be enabled and prevent tube from being recognized
   assign h_reg0_d_w[`Q_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `Q_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `Q_IDX] ): 1'b1; // Force Q to 1 if read, otherwise update based on write
`else
   assign h_reg0_d_w[`Q_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `Q_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `Q_IDX] ): h_reg0_q_r [ `Q_IDX];
`endif
   assign h_reg0_d_w[`I_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `I_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `I_IDX] ): h_reg0_q_r [ `I_IDX];
   assign h_reg0_d_w[`J_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `J_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `J_IDX] ): h_reg0_q_r [ `J_IDX];
   assign h_reg0_d_w[`V_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `V_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `V_IDX] ): h_reg0_q_r [ `V_IDX];
   assign h_reg0_d_w[`M_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `M_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `M_IDX] ): h_reg0_q_r [ `M_IDX];
   assign h_reg0_d_w[`P_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `P_IDX] ? h_data_int[`S_IDX] : h_reg0_q_r[ `P_IDX] ): h_reg0_q_r [ `P_IDX];
   // T flag is write only, acts as soft reset when written as 1 along with S=1. Cleared automatically after reset assertion.
   assign h_reg0_d_w[`T_IDX] = ( !h_rdnw_q_r && h_select_reg0_q_r) ? ( h_data_int[ `T_IDX] & h_data_int[`S_IDX] ) : 1'b0; // T is set only if T=1 and S=1 are written, otherwise cleared


   // Register Host Control/Status Register 0
   always @(posedge dft_h_clk or negedge dft_local_rst_b_low) begin
       if (!dft_local_rst_b_low) begin
           h_reg0_q_r <= 7'b0; // Clear all flags on reset
       end else begin
           h_reg0_q_r <= h_reg0_d_w;
       end
   end

   // Register Parasite Status Register 0 (Read only from host, written by parasite)
   // This register reflects FIFO status bits, not directly written flags like h_reg0.
   // The definition requires p_reg0_q_r to hold status bits read by the parasite at address 0.
   // Let's assume these bits are derived from FIFO status lines.
   // The original code had p_reg0_q_r[5:0] in the p_data_r mux, implying it's readable by parasite.
   // Let's define the logic for what the parasite *writes* to this register address (if anything)
   // and what it *reads*. The original code only shows the read part.
   // Assuming parasite *reads* status from address 0.
   // If parasite can *write* to address 0, need logic for that. Let's assume it's read-only for now.
   // If p_reg0_q_r represents readable status bits for the parasite:
   // p_reg0_q_r[5] = p_data_available_w[0] (FIFO 0 has data for parasite)
   // p_reg0_q_r[4] = !p_full_w[0]          (FIFO 0 not full for parasite write)
   // p_reg0_q_r[3:0] = TBD (Original code had 6 bits total)
   // Let's keep p_reg0_q_r as defined for the parasite read mux, assuming it's combinational status.
   // If it needs to be registered based on parasite writes, more info is needed.
   // For now, remove the reg declaration for p_reg0_q_r if it's purely combinational status read by parasite.
   // Let's assume p_reg0_q_r holds bits written by the parasite at address 0.
   wire p_write_reg0 = !p_cs_b && (p_addr == 3'h0) && !p_rdnw_q_r;
   always @(posedge dft_p_clk or negedge dft_local_rst_b_low) begin
        if (!dft_local_rst_b_low) begin
            p_reg0_q_r <= 6'b0;
        end else if (p_write_reg0) begin
             // Assuming parasite writes to bits 5:0 of its address 0.
             // Actual function depends on the specific parasite processor requirements.
             p_reg0_q_r <= p_data_int[5:0];
        end
   end


//   PNMI logic:
//   PNMI  either:
//   M = 1 V = 0   1 or 2 bytes in host to parasite register 3 FIFO or
//                 0 bytes in parasite to host register 3 FIFO (this allows
//                 single byte transfers across register 3)
//   or:
//
//   M = 1 V = 1   2 bytes in host to parasite register 3 FIFO or 0 bytes
//                 in