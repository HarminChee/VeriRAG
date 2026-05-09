<xaiArtifact artifact_id="b46f2f07-9a00-40ca-9f7e-b4b50c1db644" artifact_version_id="75bb7e02-2ba4-4097-9185-b1b71e300160" title="mrx_io_corrected.v" contentType="text/verilog">
module mrx_io #(parameter IOW    = 64,          
                parameter TARGET = "GENERIC"  
                )
   ( 
     input          test_i,
     input 	      nreset, 
     input 	      ddr_mode, 
     input [1:0]      iowidth, 
     input 	      rx_clk, 
     input [IOW-1:0]  rx_packet, 
     input 	      rx_access, 
     output 	      io_access,
     output reg [7:0] io_valid, 
     output [63:0]    io_packet 
     );
   wire [IOW-1:0]    ddr_data;
   wire 	     io_nreset,dft_io_nreset,dft_rx_clk;
   wire [63:0] 	     io_data;
   wire [63:0] 	     mux_data;
   wire [7:0] 	     data_select;
   wire [7:0] 	     valid_input;
   wire [7:0] 	     valid_next;   
   wire [IOW/2-1:0]  ddr_even;
   wire [IOW/2-1:0]  ddr_odd;   
   wire 	     io_frame;
   wire 	     dmode8;
   wire 	     dmode16;
   wire 	     dmode32;
   wire 	     dmode64;
   wire 	     reload;
   wire 	     transfer_done;
   wire 	     transfer_active;
   reg [63:0] 	     shiftreg;
   reg [IOW-1:0]     sdr_data;
   reg [1:0] 	     rx_access_reg;
   assign dmode8   = (iowidth[1:0]==2'b00);   
   assign dmode16  = ((iowidth[1:0]==2'b01) & ~ddr_mode) |
                     (iowidth[1:0]==2'b00) & ddr_mode;   
   assign dmode32  = ((iowidth[1:0]==2'b10) & ~ddr_mode) |
                     (iowidth[1:0]==2'b01) & ddr_mode;   
   assign dmode64  = ((iowidth[1:0]==2'b11) & ~ddr_mode) |
                     (iowidth[1:0]==2'b10) &