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
// Compile time Options (Assumed for this correction):
// SEPARATE_HOST_DATABUSSES_D     - Undefined
// SEPARATE_PARASITE_DATABUSSES_D - Undefined
// OMIT_DMA_PINS_D                - Undefined
// ENABLE_DMA_D                   - Defined
// DEBUG_NO_TUBE_D                - Undefined
// TWOSTATE_HOST_INTERRUPTS_D     - Undefined
// TWOSTATE_PARASITE_INTERRUPTS_D - Undefined
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

// Basic FIFO module for compilation and basic function
module tube_fifo #(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=4) (
    input                   rst_b,     // Asynchronous Reset (active low) - Assume connected to primary input or controlled source
    input                   clk,       // Functional Clock - Assume connected to primary input or controlled source
    input                   scan_clk,  // Scan Clock - Assume connected to primary input
    input                   test_i,    // Test Mode signal - Assume connected to primary input
    input                   wr,        // Write Enable
    input [DATA_WIDTH-1:0]  data_in,   // Data In
    output reg[DATA_WIDTH-1:0] data_out, // Data Out
    output                  full,      // FIFO Full
    output                  empty,     // FIFO Empty
    input                   rd         // Read Enable
);
    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0]   wr_ptr_r, rd_ptr_r; // Pointers are ADDR_WIDTH+1 wide

    wire dft_clk;
    assign dft_clk = test_i ? scan_clk : clk;

    wire wr_en = wr && !full;
    wire rd_en = rd && !empty;

    always @(posedge dft_clk or negedge rst_b) begin
        if (!rst_b) begin
            wr_ptr_r <= {ADDR_WIDTH+1{1'b0}};
            rd_ptr_r <= {ADDR_WIDTH+1{1'b0}};
            data_out <= {DATA_WIDTH{1'b0}}; // Default output value on reset
        end else begin
            // Write pointer update
            if (wr_en) begin
                mem[wr_ptr_r[ADDR_WIDTH-1:0]] <= data_in;
                wr_ptr_r <= wr_ptr_r + 1;
            end

            // Read pointer update and data output
            if (rd_en) begin
                data_out <= mem[rd_ptr_r[ADDR_WIDTH-1:0]]; // Read current location
                rd_ptr_r <= rd_ptr_r + 1;                  // Increment pointer for next read
            end
            // If !rd_en, data_out holds its value (inferred latch behavior is avoided by reset default)
        end
    end

    // Full/Empty flags (combinational based on pointers)
    // Check if lower ADDR_WIDTH bits match
    wire ptr_addr_match = (wr_ptr_r[ADDR_WIDTH-1:0] == rd_ptr_r[ADDR_WIDTH-1:0]);
    // Check if MSBs differ (indicates wrap-around for full)
    wire ptr_msb_match = (wr_ptr_r[ADDR_WIDTH] == rd_ptr_r[ADDR_WIDTH]);

    assign empty = ptr_addr_match && ptr_msb_match; // Pointers are identical
    assign full  = ptr_addr_match && !ptr_msb_match; // Lower bits match, MSBs differ

endmodule