`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpcie_phasefifo (
			  npor, 
			  wclk, 
			  wdata, 
			  rclk, 
			  rdata
			  );
   parameter DATA_SIZE  = 20;
   parameter DDR_MODE  = 0;
   input npor; 
   input wclk; 
   input[DATA_SIZE - 1:0] wdata; 
   input rclk; 
   output [DATA_SIZE - 1:0] rdata;
   wire [DATA_SIZE - 1:0] rdata; 
   reg rerror;
   reg[3-DDR_MODE:0] waddr; 
   reg[3:0] raddr; 
   reg strobe_r; 
   reg strobe_rr;
   reg npor_rd_r  ; 
   reg npor_rd_rr  ; 
   reg npor_wr_r  ; 
   reg npor_wr_rr  ; 
   altsyncram #(
   .intended_device_family ( "Stratix GX"),
		.operation_mode ( "DUAL_PORT"),
		.width_a (DATA_SIZE),
		.widthad_a (4-DDR_MODE),
		.numwords_a (2**(4-DDR_MODE)),
		.width_b (DATA_SIZE / (DDR_MODE + 1)),
		.widthad_b (4),
		.numwords_b (16),
		.lpm_type ( "altsyncram"),
		.width_byteena_a ( 1),
		.outdata_reg_b ( "CLOCK1"),
		.indata_aclr_a ( "NONE"),
		.wrcontrol_aclr_a ( "NONE"),
		.address_aclr_a ( "NONE"),
		.address_reg_b ( "CLOCK1"),
		.address_aclr_b ( "NONE"),
		.outdata_aclr_b ( "NONE"),
		.ram_block_type ( "AUTO")
   ) altsyncram_component(
      .wren_a(1'b1), 
      .wren_b(1'b0), 
      .rden_b(1'b1), 
      .data_a(wdata), 
      .data_b({(DATA_SIZE / (DDR_MODE + 1)){1'b1}}), 
      .address_a(waddr), 
      .address_b(raddr), 
      .clock0(wclk), 
      .clock1(rclk), 
      .clocken0(1'b1), 
      .clocken1(1'b1), 
      .aclr0(1'b0), 
      .aclr1(1'b0), 
      .addressstall_a(1'b0), 
      .addressstall_b(1'b0), 
      .byteena_a({{1'b1}}), 
      .byteena_b({{1'b1}}), 
      .q_a(), 
      .q_b(rdata[(DATA_SIZE / (DDR_MODE + 1))-1:0])
   );
   always @(negedge npor or posedge rclk)
   begin
      if (npor == 1'b0)
	begin
	npor_rd_r <= 0;
	npor_rd_rr <= 0;
	end
      else
	begin
	npor_rd_r <= 1;
	npor_rd_rr <= npor_rd_r;
	end
   end
   always @(negedge npor or posedge wclk)
   begin
      if (npor == 1'b0)
	begin
	npor_wr_r <= 0;
	npor_wr_rr <= 0;
	end
      else
	begin
	npor_wr_r <= 1;
	npor_wr_rr <= npor_wr_r;
	end
   end
   always @(negedge npor_rd_rr or posedge rclk)
   begin
      if (npor_rd_rr == 1'b0)
      begin
         raddr <= 4'h0 ; 
         strobe_r <= 1'b0 ; 
         strobe_rr <= 1'b0 ; 
         rerror <= 1'b0 ; 
      end
      else
      begin
         strobe_r <= DDR_MODE ? waddr[2] : waddr[3] ; 
         strobe_rr <= strobe_r ; 
         raddr <= raddr + 1'b1 ; 
         if (strobe_r == 1'b1 & strobe_rr == 1'b0 & (raddr > 4'h9))
         begin
            rerror <= 1'b1 ;
         end
         if (rerror == 1'b1)
	   begin
	   $display("PhaseFIFO Frequency mismatch Error!\n");
	   $stop;
	   end
      end 
   end 
   always @(negedge npor_wr_rr or posedge wclk)
   begin
      if (npor_wr_rr == 1'b0)
      begin
         waddr <= DDR_MODE ? 3'h2 : 4'h4 ; 
      end
      else
	begin
	waddr <= waddr + 1'b1;
	end 
   end 
endmodule
