module mrx_io #(parameter IOW    = 64,          
                parameter TARGET = "GENERIC"  
                )
   ( 
     input          test_i,
     input          nreset, 
     input          ddr_mode, 
     input [1:0]    iowidth, 
     input          rx_clk, 
     input [IOW-1:0] rx_packet, 
     input          rx_access, 
     output         io_access,
     output reg [7:0] io_valid, 
     output [63:0]  io_packet 
     );
   wire [IOW-1:0]  ddr_data;
   wire            io_nreset, dft_io_nreset, dft_rx_clk;
   wire [63:0]     io_data;
   wire [63:0]     mux_data;
   wire [7:0]      data_select;
   wire [7:0]      valid_input;
   wire [7:0]      valid_next;   
   wire [IOW/2-1:0] ddr_even;
   wire [IOW/2-1:0] ddr_odd;   
   wire            io_frame;
   wire            dmode8;
   wire            dmode16;
   wire            dmode32;
   wire            dmode64;
   wire            reload;
   wire            transfer_done;
   wire            transfer_active;
   reg [63:0]      shiftreg;
   reg [IOW-1:0]   sdr_data;
   reg [1:0]       rx_access_reg;

   assign dft_io_nreset = test_i ? nreset : io_nreset;
   assign dft_rx_clk = test_i ? rx_clk : rx_clk;
   assign dmode8   = (iowidth[1:0] == 2'b00);   
   assign dmode16  = ((iowidth[1:0] == 2'b01) & ~ddr_mode) | ((iowidth[1:0] == 2'b00) & ddr_mode);   
   assign dmode32  = ((iowidth[1:0] == 2'b10) & ~ddr_mode) | ((iowidth[1:0] == 2'b01) & ddr_mode);   
   assign dmode64  = ((iowidth[1:0] == 2'b11) & ~ddr_mode) | ((iowidth[1:0] == 2'b10) & ddr_mode);

   assign ddr_even = rx_packet[IOW/2-1:0];
   assign ddr_odd  = rx_packet[IOW-1:IOW/2];
   assign ddr_data = ddr_mode ? {ddr_odd, ddr_even} : rx_packet;

   always @(posedge dft_rx_clk or negedge dft_io_nreset) begin
      if (!dft_io_nreset) begin
         sdr_data <= {IOW{1'b0}};
         rx_access_reg <= 2'b00;
      end else begin
         sdr_data <= ddr_data;
         rx_access_reg <= {rx_access_reg[0], rx_access};
      end
   end

   assign io_frame = rx_access_reg[1];
   assign reload = io_frame & ~transfer_active;
   assign transfer_done = (valid_next == 8'h00);
   assign transfer_active = (io_valid != 8'h00);

   assign valid_input = reload ? 8'hFF : valid_next;
   assign valid_next = transfer_done ? 8'h00 : {1'b0, io_valid[7:1]};

   always @(posedge dft_rx_clk or negedge dft_io_nreset) begin
      if (!dft_io_nreset) begin
         io_valid <= 8'h00;
         shiftreg <= 64'h0;
      end else begin
         io_valid <= valid_input;
         if (reload) begin
            shiftreg <= sdr_data[63:0];
         end else if (transfer_active) begin
            shiftreg <= {shiftreg[55:0], 8'h00};
         end
      end
   end

   assign data_select = io_valid & {8{transfer_active}};
   assign mux_data = shiftreg;
   assign io_data = mux_data;
   assign io_access = transfer_active;
   assign io_packet = io_data;

endmodule