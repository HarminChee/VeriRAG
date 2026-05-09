module smbus
(
   input             bus_clk,
   input 	     quiesce,
   input 	     user_w_smb_wren,
   input [7:0] 	     user_w_smb_data,
   output 	     user_w_smb_full,
   input 	     user_w_smb_open,
   input 	     user_r_smb_rden,
   output [7:0]      user_r_smb_data,
   output 	     user_r_smb_empty,
   output 	     user_r_smb_eof,
   input 	     user_r_smb_open,
   output 	     smb_sclk,
   inout 	     smb_sdata,
   output [1:0]      smbus_addr
 );
   reg [11:0] 	     div_counter;
   reg 		     sclk_logic, sdata_logic, sdata_sample;
   reg 		     SMBus_en, pre_en;
   reg [3:0] 	     state;
   reg 		     first, dir_write, save_direction;
   reg [7:0] 	     write_byte, read_byte;
   reg [2:0] 	     idx;
   reg 		     write_byte_valid;
   reg 		     fifo_wr_en;
   reg 		     open_d, stop_pending;
   parameter 	     clk_freq = 150; 
   parameter st_idle = 0,
	     st_start = 1,
	     st_fetch = 2,
	     st_bit0 = 3,
	     st_bit1 = 4,
	     st_bit2 = 5,
	     st_ack0 = 6,
	     st_ack1 = 7,
	     st_ack2 = 8,
	     st_stop0 = 9,
	     st_stop1 = 10,
	     st_stop2 = 11; 
   assign    user_r_smb_eof = 0;
   assign    smb_sclk = sclk_logic ? 1'bz : 1'b0 ;
   assign    smb_sdata = sdata_logic ? 1'bz : 1'b0 ;
   assign    smbus_addr = 0;
   assign    user_w_smb_full = write_byte_valid || stop_pending;
   always @(posedge bus_clk)
     begin
	SMBus_en <= pre_en;
	sdata_sample <= smb_sdata;
	fifo_wr_en <= SMBus_en && (state == st_ack0) && !dir_write;
	open_d <= user_w_smb_open;
	if (open_d && !user_w_smb_open)
	  stop_pending <= 1;
	if (user_w_smb_wren)
	  begin
	     write_byte <= user_w_smb_data;
	     write_byte_valid <= 1; 
	  end
	if (div_counter == ((clk_freq * 10) - 1))
	  begin
	     div_counter <= 0;
	     pre_en <= 1;
	  end
	else
	  begin
	     div_counter <= div_counter + 1;
	     pre_en <= 0;	     
	  end
 	if (SMBus_en)
	  case (state)
	    st_idle:
	      begin
		 sclk_logic <= 1;
		 sdata_logic <= 1;
		 stop_pending <= 0;
		 if (write_byte_valid)
		   state <= st_start;
	      end
	    st_start: 
	      begin
		 sdata_logic <= 0; 
		 first <= 1;
		 dir_write <= 1;
		 state <= st_fetch;
	      end
	    st_fetch:
	      begin
		 sclk_logic <= 0;
		 idx <= 7;
		 state <= st_bit0;
	      end
	    st_bit0:
	      begin
		 if (dir_write)
		   sdata_logic <= write_byte[idx];
		 else
		   sdata_logic <= 1; 
		 state <= st_bit1;
	      end
	    st_bit1:
	      begin
		 sclk_logic <= 1;
		 read_byte[idx] <= sdata_sample;
		 state <= st_bit2;
	      end
	    st_bit2:
	      begin
		 sclk_logic <= 0;
		 idx <= idx - 1;
		 if (idx != 0)
		   state <= st_bit0;
		 else
		   state <= st_ack0;
	      end
	    st_ack0:
	      begin
		 if (dir_write)
		   sdata_logic <= 1; 
		 else
		   sdata_logic <= 0; 
		 save_direction <= !write_byte[0];
		 write_byte_valid <= 0;
		 state <= st_ack1;
	      end
	    st_ack1:
	      begin		  
		 if (!dir_write || !sdata_sample || stop_pending)
		   state <= st_ack2; 
	      end
	    st_ack2:
	      begin
		 sclk_logic <= 1;
		 if (stop_pending && dir_write)
		   state <= st_stop0;		
		 else if (stop_pending)
		   state <= st_stop2; 
		 else if (write_byte_valid)
		   begin
		      if (first)
			dir_write <= save_direction;
		      first <= 0;
		      state <= st_fetch;
		   end
	      end
	    st_stop0:
	      begin
		 sclk_logic <= 0;
		 state <= st_stop1;
	      end
	    st_stop1:
	      begin
		 sdata_logic <= 0;
		 state <= st_stop2;
	      end
	    default: 
	      begin
		 sclk_logic <= 1;
		 write_byte_valid <= 0;
		 state <= st_idle; 
	      end
	  endcase
	if (quiesce) 
	  begin
	     state <= st_idle;
	     stop_pending <= 0;
	     write_byte_valid <= 0;
	  end
     end
   fifo_8x2048 fifo 
     (
      .clk(bus_clk),
      .srst(!user_r_smb_open),
      .din(read_byte), 
      .wr_en(fifo_wr_en),
      .rd_en(user_r_smb_rden),
      .dout(user_r_smb_data), 
      .full(),
      .empty(user_r_smb_empty));
endmodule 
