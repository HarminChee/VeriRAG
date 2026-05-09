<xaiArtifact artifact_id="68072056-d2e7-4a4f-b8e8-c10884d13f4f" artifact_version_id="65779159-f30d-4267-a7e9-33d1948b324c" title="mtx_io_corrected.v" contentType="text/verilog">
module mtx_io #(parameter IOW    = 64,          
                parameter TARGET = "GENERIC"  
               )
  (
   input            test_i,
   input            nreset, 
   input            io_clk, 
   input            ddr_mode, 
   input [1:0]      iowidth, 
   output [IOW-1:0] tx_packet, 
   output reg       tx_access, 
   input            tx_wait, 
   input [7:0]      io_valid, 
   input [IOW-1:0]  io_packet, 
   output           io_wait 
   );
   reg [63:0]       shiftreg;
   reg [2:0]        tx_state;
   reg [IOW-1:0]    tx_packet_sdr;
   reg [7:0]        io_valid_reg;
   wire [IOW/2-1:0] tx_packet_ddr;
   wire             tx_wait_sync;
   wire             transfer_active;
   wire [7:0]       io_valid_next;
   wire [IOW/2-1:0] ddr_data_even;
   wire [IOW/2-1:0] ddr_data_odd;
   wire             dmode8;
   wire             dmode16;
   wire             dmode32;
   wire             dmode64;
   wire             io_nreset;
   wire             reload;
   wire             dft_io_clk;
   wire             dft_io_nreset;
   
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
   
   assign dft_io_clk = test_i ? io_clk : io_clk;
   assign dft_io_nreset = test_i ? nreset : io_nreset;
   
   always @ (posedge dft_io_clk or negedge dft_io_nreset)
     if(!dft_io_nreset)
       io_valid_reg[7:0] <= 'b0;
     else if(reload)
       io_valid_reg[7:0] <= io_valid[7:0];
     else
       io_valid_reg[7:0] <= io_valid_next[7:0];
   
   assign transfer_active = |io_valid_reg[7:0];
   
   always @ (posedge dft_io_clk or negedge dft_io_nreset)
     if(!dft_io_nreset)
       tx_access <= 1'b0;   
     else
       tx_access <= transfer_active;
   
   assign io_wait = tx_wait_sync | ~reload;
   
   always @ (posedge dft_io_clk)
     if(reload)
       shiftreg[63:0] <= io_packet[IOW-1:0];
     else if(dmode8)
       shiftreg[63:0] <= {8'b0,shiftreg[IOW-1:8]};   
     else if(dmode16)
       shiftreg[63:0] <= {16'b0,shiftreg[IOW-1:16]};
     else if(dmode32)
       shiftreg[63:0] <= {32'b0,shiftreg[IOW-1:32]};   
       
   always @ (posedge dft_io_clk)
     tx_packet_sdr[IOW-1:0] <= shiftreg[IOW-1:0];
     
   assign ddr_data_even[IOW/2-1:0] = shiftreg[IOW/2-1:0];
   assign ddr_data_odd[IOW/2-1:0] = (iowidth[1:0]==2'b00) ? shiftreg[7:4]   : 
                                   (iowidth[1:0]==2'b01) ? shiftreg[15:8]  : 
                                   (iowidth[1:0]==2'b10) ? shiftreg[31:16] : 
                                                           shiftreg[63:32];  
   
   oh_oddr#(.DW(IOW/2))
   data_oddr (.out      (tx_packet_ddr[IOW/2-1:0]),
              .clk      (dft_io_clk),
              .din1     (ddr_data_even[IOW/2-1:0]),
              .din2     (ddr_data_odd[IOW/2-1:0]));
              
   assign tx_packet[IOW-1:0] = ddr_mode ? {{(IOW/2){1'b0}},tx_packet_ddr[IOW/2-1:0]}:
                                          tx_packet_sdr[IOW-1:0];
                                          
   oh_rsync sync_reset(.nrst_out (io_nreset),
                      .clk       (dft_io_clk),
                      .nrst_in   (nreset));
                      
   oh_dsync sync_wait(.nreset   (dft_io_nreset),
                     .clk       (dft_io_clk),
                     .din       (tx_wait),
                     .dout      (tx_wait_sync));
endmodule
</xaiArtifact>