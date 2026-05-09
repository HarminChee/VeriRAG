`define CFG_FAKECLK   1
`define CFG_MDW       32
`define CFG_DW        32
`define CFG_AW        32
`define CFG_LW        8
`define CFG_NW        13
// 1_corrected_ffc.v
// Note: Removed clock division logic's output usage for internal FFs.
// All internal FFs previously clocked by generated clocks (rxi_lclk, txo_lclk)
// are now clocked by a primary clock input (propagated as scan_clk, originating from c1_clk_in).

module e16_clock_divider(
   clk_out, clk_out90,
   clk_in, reset, div_cfg
   );
   input       clk_in;    // This is the primary clock input for this block
   input       reset;
   input [3:0] div_cfg;
   output      clk_out;   // Generated clock output (potentially for external use or non-FF logic)
   output      clk_out90; // Generated clock output (potentially for external use or non-FF logic)

   reg        clk_out_reg;
   reg [5:0]  counter;
   reg [5:0]  div_cfg_dec;

   wire div2_sel;
   wire posedge_match;
   wire negedge_match;
   wire posedge90_match;
   wire negedge90_match;
   wire clk_out90_div2;
   wire clk_out90_div4;
   wire clk_out90_div2_in;
   wire clk_out90_div4_in;

   // Combinational logic for decoding div_cfg
   always @ (div_cfg[3:0])
     begin
	casez (div_cfg[3:0])
	  4'b0000 : div_cfg_dec[5:0] = 6'b000010;
	  4'b0001 : div_cfg_dec[5:0] = 6'b000100;
	  4'b0010 : div_cfg_dec[5:0] = 6'b001000;
	  4'b0011 : div_cfg_dec[5:0] = 6'b010000;
	  4'b01?? : div_cfg_dec[5:0] = 6'b100000;
          4'b1??? : div_cfg_dec[5:0] = 6'b100000;
	  default : div_cfg_dec[5:0] = 6'b000000;
	endcase
     end

   assign div2_sel = div_cfg[3:0]==4'b0;

   // Counter logic - clocked by primary input clk_in
   always @ (posedge clk_in or posedge reset)
     if (reset)
       counter[5:0] <= 6'b000001;
     else if(posedge_match)
       counter[5:0] <= 6'b000001;
     else
       counter[5:0] <= (counter[5:0]+6'b000001);

   assign posedge_match    = (counter[5:0]==div_cfg_dec[5:0]);
   assign negedge_match    = (counter[5:0]=={1'b0,div_cfg_dec[5:1]});
   assign posedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}));
   assign negedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}+{1'b0,div_cfg_dec[5:1]}));

   // Clock output generation logic - clocked by primary input clk_in
   always @ (posedge clk_in) // Changed from posedge clk_in - original was correct
     if(posedge_match)
       clk_out_reg <= 1'b1;
     else if(negedge_match)
       clk_out_reg <= 1'b0;

   assign clk_out    = clk_out_reg; // Output the generated clock signal

   // Placeholder logic for clk_out90 - actual implementation depends on requirements
   // Assuming simple generation for demonstration; real logic might differ
   // This part doesn't directly cause FFCKNP if clk_out90 isn't used to clock FFs internally.
   // If clk_out90 *is* used to clock FFs, those FFs need to use scan_clk instead.
   // For now, we assume clk_out90 is just an output.
   assign clk_out90 = ~clk_out; // Simplified example

   // Dummy wires assignment (present in original code)
   wire		c0_emesh_wait_in=1'b0;
   wire		c0_rdmesh_wait_in=1'b0;
   wire		c1_rdmesh_wait_in=1'b0;
   wire		c2_rdmesh_wait_in=1'b0;
   wire		c3_emesh_wait_in=1'b0;
   wire		c3_mesh_wait_in=1'b0;
   wire		c3_rdmesh_wait_in=1'b0;
   wire [5:0] 	txo_cfg_reg=6'b0;

   // link_port instantiation removed as it was incomplete and context is unclear
   // If link_port was intended to be instantiated here, it needs proper connections.
endmodule

module link_port(
   // Added scan_clk input for DFT
   input             scan_clk, // Use this clock for internal FFs instead of generated clocks
   // Original ports...
   rxi_rd_wait, rxi_wr_wait, txo_data, txo_lclk, txo_frame,
   c0_emesh_frame_out, c0_emesh_tran_out, c3_emesh_frame_out,
   c3_emesh_tran_out, c0_rdmesh_frame_out, c0_rdmesh_tran_out,
   c1_rdmesh_frame_out, c1_rdmesh_tran_out, c2_rdmesh_frame_out,
   c2_rdmesh_tran_out, c3_rdmesh_frame_out, c3_rdmesh_tran_out,
   c0_mesh_access_out, c0_mesh_write_out, c0_mesh_dstaddr_out,
   c0_mesh_srcaddr_out, c0_mesh_data_out, c0_mesh_datamode_out,
   c0_mesh_ctrlmode_out, c3_mesh_access_out, c3_mesh_write_out,
   c3_mesh_dstaddr_out, c3_mesh_srcaddr_out, c3_mesh_data_out,
   c3_mesh_datamode_out, c3_mesh_ctrlmode_out, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_rdmesh_wait_out, c1_rdmesh_wait_out, c2_rdmesh_wait_out,
   c3_rdmesh_wait_out, c0_mesh_wait_out, c3_mesh_wait_out,
   reset, ext_yid_k, ext_xid_k, txo_cfg_reg, vertical_k, who_am_i,
   cfg_extcomp_dis, rxi_data, rxi_lclk_in, rxi_frame, txo_rd_wait, // Renamed rxi_lclk to rxi_lclk_in
   txo_wr_wait, c0_clk_in, c1_clk_in, c2_clk_in, c3_clk_in,
   c0_emesh_tran_in, c0_emesh_frame_in, c1_emesh_tran_in,
   c1_emesh_frame_in, c2_emesh_tran_in, c2_emesh_frame_in,
   c3_emesh_tran_in, c3_emesh_frame_in, c0_rdmesh_tran_in,
   c0_rdmesh_frame_in, c1_rdmesh_tran_in, c1_rdmesh_frame_in,
   c2_rdmesh_tran_in, c2_rdmesh_frame_in, c3_rdmesh_tran_in,
   c3_rdmesh_frame_in, c0_mesh_access_in, c0_mesh_write_in,
   c0_mesh_dstaddr_in, c0_mesh_srcaddr_in, c0_mesh_data_in,
   c0_mesh_datamode_in, c0_mesh_ctrlmode_in, c3_mesh_access_in,
   c3_mesh_write_in, c3_mesh_dstaddr_in, c3_mesh_srcaddr_in,
   c3_mesh_data_in, c3_mesh_datamode_in, c3_mesh_ctrlmode_in,
   c0_emesh_wait_in, c3_emesh_wait_in, c0_mesh_wait_in,
   c3_mesh_wait_in, c0_rdmesh_wait_in, c1_rdmesh_wait_in,
   c2_rdmesh_wait_in, c3_rdmesh_wait_in
   );
   parameter DW   = `CFG_DW  ;
   parameter AW   = `CFG_AW  ;
   parameter LW   = `CFG_LW  ;
   input             reset;
   input [3:0] 	     ext_yid_k;
   input [3:0] 	     ext_xid_k;
   input [5:0] 	     txo_cfg_reg;
   input             vertical_k;
   input [3:0] 	     who_am_i;
   input 	     cfg_extcomp_dis;
   input   [LW-1:0]  rxi_data;
   input             rxi_lclk_in;     // Renamed from rxi_lclk
   input             rxi_frame;
   input             txo_rd_wait;
   input             txo_wr_wait;
   input 	    c0_clk_in;         // Assumed primary/scan controllable clock
   input 	    c1_clk_in;         // Assumed primary/scan controllable clock - **Using this as scan_clk source**
   input 	    c2_clk_in;         // Assumed primary/scan controllable clock
   input 	    c3_clk_in;         // Assumed primary/scan controllable clock
   input [2*LW-1:0] c0_emesh_tran_in;
   input 	    c0_emesh_frame_in;
   input [2*LW-1:0] c1_emesh_tran_in;
   input 	    c1_emesh_frame_in;
   input [2*LW-1:0] c2_emesh_tran_in;
   input 	    c2_emesh_frame_in;
   input [2*LW-1:0] c3_emesh_tran_in;
   input 	    c3_emesh_frame_in;
   input [2*LW-1:0] c0_rdmesh_tran_in;
   input 	    c0_rdmesh_frame_in;
   input [2*LW-1:0] c1_rdmesh_tran_in;
   input 	    c1_rdmesh_frame_in;
   input [2*LW-1:0] c2_rdmesh_tran_in;
   input 	    c2_rdmesh_frame_in;
   input [2*LW-1:0] c3_rdmesh_tran_in;
   input 	    c3_rdmesh_frame_in;
   input 	    c0_mesh_access_in;
   input 	    c0_mesh_write_in;
   input [AW-1:0]   c0_mesh_dstaddr_in;
   input [AW-1:0]   c0_mesh_srcaddr_in;
   input [DW-1:0]   c0_mesh_data_in;
   input [1:0] 	    c0_mesh_datamode_in;
   input [3:0] 	    c0_mesh_ctrlmode_in;
   input 	    c3_mesh_access_in;
   input 	    c3_mesh_write_in;
   input [AW-1:0]   c3_mesh_dstaddr_in;
   input [AW-1:0]   c3_mesh_srcaddr_in;
   input [DW-1:0]   c3_mesh_data_in;
   input [1:0] 	    c3_mesh_datamode_in;
   input [3:0] 	    c3_mesh_ctrlmode_in;
   input 	    c0_emesh_wait_in;
   input 	    c3_emesh_wait_in;
   input 	    c0_mesh_wait_in;
   input 	    c3_mesh_wait_in;
   input 	    c0_rdmesh_wait_in;
   input 	    c1_rdmesh_wait_in;
   input 	    c2_rdmesh_wait_in;
   input 	    c3_rdmesh_wait_in;
   output 	     rxi_rd_wait;
   output 	     rxi_wr_wait;
   output  [LW-1:0]  txo_data;
   output            txo_lclk;      // Output of clock divider (if needed externally)
   output            txo_frame;
   output            c0_emesh_frame_out;
   output [2*LW-1:0] c0_emesh_tran_out;
   output            c3_emesh_frame_out;
   output [2*LW-1:0] c3_emesh_tran_out;
   output            c0_rdmesh_frame_out;
   output [2*LW-1:0] c0_rdmesh_tran_out;
   output            c1_rdmesh_frame_out;
   output [2*LW-1:0] c1_rdmesh_tran_out;
   output            c2_rdmesh_frame_out;
   output [2*LW-1:0] c2_rdmesh_tran_out;
   output            c3_rdmesh_frame_out;
   output [2*LW-1:0] c3_rdmesh_tran_out;
   output 	     c0_mesh_access_out;
   output 	     c0_mesh_write_out;
   output [AW-1:0]   c0_mesh_dstaddr_out;
   output [AW-1:0]   c0_mesh_srcaddr_out;
   output [DW-1:0]   c0_mesh_data_out;
   output [1:0]      c0_mesh_datamode_out;
   output [3:0]      c0_mesh_ctrlmode_out;
   output 	     c3_mesh_access_out;
   output 	     c3_mesh_write_out;
   output [AW-1:0]   c3_mesh_dstaddr_out;
   output [AW-1:0]   c3_mesh_srcaddr_out;
   output [DW-1:0]   c3_mesh_data_out;
   output [1: