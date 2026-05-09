module mtx_io_corrected_acn #(parameter IOW    = 64,
	        parameter TARGET = "GENERIC"
	       )
  (
   input 	    nreset, // Primary asynchronous reset
   input 	    io_clk,
   input 	    ddr_mode,
   input [1:0] 	    iowidth,
   output [IOW-1:0] tx_packet,
   output reg 	    tx_access,
   input 	    tx_wait,
   input [7:0] 	    io_valid,
   input [IOW-1:0]  io_packet,
   output 	    io_wait
   );

   reg [63:0] 	    shiftreg;
   reg [2:0] 	    tx_state;
   reg [IOW-1:0]    tx_packet_sdr;
   reg [7:0] 	    io_valid_reg;
   wire [IOW/2-1:0] tx_packet_ddr;
   wire 	    tx_wait_sync;
   wire 	    transfer_active;
   wire [7:0] 	    io_valid_next;
   wire [IOW/2-1:0] ddr_data_even;
   wire [IOW/2-1:0] ddr_data_odd;
   wire 	    dmode8;
   wire 	    dmode16;
   wire 	    dmode32;
   wire 	    dmode64;
   wire 	    io_nreset_sync; // Renamed synchronized reset, if needed elsewhere
   wire 	    reload;

   assign dmode8   = (iowidth[1:0]==2'b00);
   assign dmode16  = ((iowidth[1:0]==2'b01) & ~ddr_mode) |
                     (iowidth[1:0]==2'b00) & ddr_mode;
   assign dmode32  = ((iowidth[1:0]==2'b10) & ~ddr_mode) |
                     (iowidth[1:0]==2'b01) & ddr_mode;
   assign dmode64  = ((iowidth[1:0]==2'b11) & ~ddr_mode) |
                     (iowidth[1:0]==2'b10) & ddr_mode;

   assign io_valid_next[7:0] = dmode8  ? {1'b0,io_valid_reg[7:1]} :
			       dmode16 ? {2'b0,io_valid_reg[7:2]} :
			       dmode32 ? {4'b0,io_valid_reg[7:4]} :
			                  8'b0;

   assign reload = ~transfer_active | dmode64 | (io_valid_next[7:0]==8'b0);

   // Use primary input 'nreset' for asynchronous reset
   always @ (posedge io_clk or negedge nreset)
     if(!nreset)
       io_valid_reg[7:0] <= 'b0;
     else if(reload)
       io_valid_reg[7:0] <= io_valid[7:0];
     else
       io_valid_reg[7:0] <= io_valid_next[7:0];

   assign transfer_active = |io_valid_reg[7:0];

   // Use primary input 'nreset' for asynchronous reset
   always @ (posedge io_clk or negedge nreset)
     if(!nreset)
       tx_access <= 1'b0;
     else
       tx_access <= transfer_active;

   assign io_wait = tx_wait_sync | ~reload;

   // Shift register does not have asynchronous reset in original code - OK
   always @ (posedge io_clk)
     if(reload)
       shiftreg[63:0] <= io_packet[IOW-1:0];
     else if(dmode8)
       shiftreg[63:0] <= {8'b0,shiftreg[IOW-1:8]};
     else if(dmode16)
       shiftreg[63:0] <= {16'b0,shiftreg[IOW-1:16]};
     else if(dmode32)
       shiftreg[63:0] <= {32'b0,shiftreg[IOW-1:32]};

   // SDR packet register does not have asynchronous reset in original code - OK
   always @ (posedge io_clk)
     tx_packet_sdr[IOW-1:0] <= shiftreg[IOW-1:0];

   assign ddr_data_even[IOW/2-1:0] = shiftreg[IOW/2-1:0];
   assign ddr_data_odd[IOW/2-1:0] = (iowidth[1:0]==2'b00) ? shiftreg[7:4]   :
				    (iowidth[1:0]==2'b01) ? shiftreg[15:8]  :
    				    (iowidth[1:0]==2'b10) ? shiftreg[31:16] :
				                            shiftreg[63:32];

   // Assuming oh_oddr is a combinational or synchronous element w.r.t io_clk
   oh_oddr#(.DW(IOW/2))
   data_oddr (.out	(tx_packet_ddr[IOW/2-1:0]),
              .clk	(io_clk),
	      .din1	(ddr_data_even[IOW/2-1:0]),
	      .din2	(ddr_data_odd[IOW/2-1:0]));

   assign tx_packet[IOW-1:0] = ddr_mode ? {{(IOW/2){1'b0}},tx_packet_ddr[IOW/2-1:0]}:
		                                           tx_packet_sdr[IOW-1:0];

   // Synchronizer for reset - output io_nreset_sync should not be used for async reset of core flops
   oh_rsync sync_reset(.nrst_out (io_nreset_sync), // Output is synchronized reset
		       .clk	 (io_clk),
		       .nrst_in	 (nreset)); // Input is primary reset

   // Synchronizer for wait signal - use primary 'nreset' for its reset
   oh_dsync sync_wait(.nreset	(nreset), // Use primary reset
		      .clk	(io_clk),
		      .din      (tx_wait),
		      .dout     (tx_wait_sync));

endmodule

// Dummy synchronizer modules (replace with actual library cells if available)
// These are simplified and may not represent real synchronizer behavior perfectly.
module oh_rsync (output reg nrst_out, input clk, input nrst_in);
    reg sync_flop1;
    always @(posedge clk or negedge nrst_in) begin
        if (!nrst_in) begin
            sync_flop1 <= 1'b0;
            nrst_out <= 1'b0;
        end else begin
            sync_flop1 <= 1'b1;
            nrst_out <= sync_flop1;
        end
    end
endmodule

module oh_dsync (output reg dout, input nreset, input clk, input din);
    reg sync_flop1;
    always @(posedge clk or negedge nreset) begin
        if (!nreset) begin
            sync_flop1 <= 1'b0;
            dout <= 1'b0;
        end else begin
            sync_flop1 <= din;
            dout <= sync_flop1;
        end
    end
endmodule

// Dummy DDR output module (replace with actual library cell if available)
module oh_oddr #(parameter DW=1) (output [DW-1:0] out, input clk, input [DW-1:0] din1, input [DW-1:0] din2);
    reg [DW-1:0] out_reg;
    // Simplified behavioral model - real DDR flops are more complex
    always @(posedge clk) out_reg <= din1;
    always @(negedge clk) out_reg <= din2; // This is behavioral, not synthesizable as such for FPGAs/ASICs directly
    assign out = out_reg;
endmodule