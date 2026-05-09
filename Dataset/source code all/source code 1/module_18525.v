`ifdef FPGA_SYN 
`define FPGA_SYN_RED
`endif
`ifdef FPGA_SYN 
`define FPGA_SYN_RED
`endif
module bw_r_l2d_32k (
   decc_out, so, l2d_fuse_data_out, 
   decc_in_l, decc_read_in, word_en_l, way_sel_l, set_l, 
   col_offset_l, wr_en_l, rclk, arst_l, mem_write_disable, 
   sehold, se, si, fuse_l2d_wren, fuse_l2d_rden, 
   fuse_l2d_rid, fuse_clk1, fuse_clk2, 
   fuse_l2d_data_in, fuse_read_data_in
   );
   input [155:0]	decc_in_l;
   input [155:0] 	decc_read_in;
   input [3:0] 		word_en_l;
   input [1:0] 		way_sel_l;
   input [9:0] 		set_l;
   input		col_offset_l;
   input		wr_en_l;
   input 		rclk;
   input 		arst_l;
   input  		mem_write_disable;
   input 		sehold;
   input 		se;
   input 		si;
   input 		fuse_l2d_wren;
   input 		fuse_l2d_rden;
   input [2:0] 		fuse_l2d_rid;
   input 		fuse_clk1;
   input 		fuse_clk2;
   input 		fuse_l2d_data_in;
   input 		fuse_read_data_in;
   output [155:0] 	decc_out ;
   output 		so;
   output 		l2d_fuse_data_out;
   reg [155:0] 		tmp_decc_out;
   reg [155:0] 		decc_out_tmp;
   reg [155:0] 		reg_decc_in;   
`ifdef DEFINE_0IN
`else
   reg [155:0] 		way0_decc[1023:0] ;
   reg [155:0] 		way1_decc[1023:0] ;
`endif
   wire			acc_en_d1;
   reg [1:0] 		way_sel_d1;
   reg [9:0] 		set_d1;
   reg [3:0] 		word_en_d1;
   reg 			wr_en_d1;
   reg [155:0] 		decc_in_d1;
   reg [155:0] 		decc_out_d1;
   reg 			col_offset_d1;
   wire	[1:0] 		way_sel_sehold;
   wire	[9:0] 		set_sehold;
   wire	[3:0] 		word_en_sehold;
   wire 		wr_en_sehold;
   wire [155:0] 	decc_in_sehold;
   wire 		col_offset;
   wire [155:0] 	decc_out ;
   reg			keep_rd_out;
   reg			stop_1_cyc;
   always @(posedge rclk) begin
      if (col_offset && (|way_sel_sehold)) begin
         stop_1_cyc <= 1'b1;
      end
      else stop_1_cyc <= 1'b0;
      if (acc_en_d1 & ~wr_en_d1) begin
	 keep_rd_out <= 1'b1;
      end
      else keep_rd_out <= 1'b0;
   end
   assign 		wr_en_sehold = (sehold) ? wr_en_d1 : ~wr_en_l;
   assign 		set_sehold = (sehold) ? set_d1 : ~set_l;
   assign 		way_sel_sehold = (sehold) ? way_sel_d1 : ~way_sel_l;
   assign 		word_en_sehold = (sehold) ? word_en_d1 : ~word_en_l;
   assign 		col_offset = (stop_1_cyc || mem_write_disable ) ? (1'b0) : ~col_offset_l ;
   assign acc_en_d1 = col_offset_d1 & (|way_sel_d1);   
   always @(posedge rclk) begin
      col_offset_d1 <= col_offset;
      way_sel_d1  <= way_sel_sehold;
      set_d1  <= set_sehold;
      word_en_d1 <= word_en_sehold;
      wr_en_d1  <= wr_en_sehold;
      decc_in_d1 <= ~decc_in_l;
      decc_out_d1 <= decc_out_tmp;
   end      
`ifdef DEFINE_0IN
   wire [155:0] decc_out0, decc_out1;
   wire [155:0] wm  = { {39{word_en_d1[3]}}, {39{word_en_d1[2]}}, {39{word_en_d1[1]}}, {39{word_en_d1[0]}} };
   wire         we0 = acc_en_d1 & wr_en_d1 & way_sel_d1[0];
   wire         we1 = acc_en_d1 & wr_en_d1 & way_sel_d1[1];
l2data_axis     data_array0 (.data_out  (decc_out0[155:0]),
                             .rclk      (rclk),
                             .adr       (set_d1[9:0]),
                             .data_in   (decc_in_d1[155:0]),
                             .we        (we0),
                             .wm        (wm[155:0]) );
l2data_axis     data_array1 (.data_out  (decc_out1[155:0]),
                             .rclk      (rclk),
                             .adr       (set_d1[9:0]),
                             .data_in   (decc_in_d1[155:0]),
                             .we        (we1),
                             .wm        (wm[155:0]) );
   always @(acc_en_d1 or decc_in_d1 or decc_out0
	    or decc_out1 or way_sel_d1 or word_en_d1 or wr_en_d1) begin
        if (acc_en_d1 & ~wr_en_d1) begin
           decc_out_tmp = way_sel_d1[0] ? decc_out0[155:0] : decc_out1[155:0];
        end
        if (acc_en_d1 & wr_en_d1) begin
           tmp_decc_out = way_sel_d1[0] ? decc_out0[155:0] : decc_out1[155:0];
           reg_decc_in[155:117] = (decc_in_d1[155:117] & {39{word_en_d1[3]}} |
                                   tmp_decc_out[155:117] & {39{~word_en_d1[3]}});
           reg_decc_in[116:78] = (decc_in_d1[116:78] & {39{word_en_d1[2]}} |
                                  tmp_decc_out[116:78] & {39{~word_en_d1[2]}});
           reg_decc_in[77:39] = (decc_in_d1[77:39] & {39{word_en_d1[1]}} |
                                 tmp_decc_out[77:39] & {39{~word_en_d1[1]}});
           reg_decc_in[38:0] = (decc_in_d1[38:0] & {39{word_en_d1[0]}} |
				tmp_decc_out[38:0] & {39{~word_en_d1[0]}});
	     decc_out_tmp[155:0] = 156'b0;
        end 
      if (~acc_en_d1) begin
         decc_out_tmp[155:0] = 156'b0;
      end
   end 
`else
   always @(acc_en_d1 or decc_in_d1 or set_d1
	    or way_sel_d1 or word_en_d1 or wr_en_d1) begin
`ifdef	INNO_MUXEX
`else
      if(wr_en_d1==1'bx) begin
	`ifdef MODELSIM
         $display("L2_DATA_ERR"," wr en error %b ", wr_en_d1);
	`else
         $error("L2_DATA_ERR"," wr en error %b ", wr_en_d1);
	`endif	
      end
`endif
      if (acc_en_d1) begin
`ifdef	INNO_MUXEX
`else
	 if(set_d1==10'bx) begin
	`ifdef MODELSIM 
            $error("L2_DATA_ERR"," index error %h ", set_d1[9:0]);
	`else
            $display("L2_DATA_ERR"," index error %h ", set_d1[9:0]);
	`endif
	 end
`endif
	if (~wr_en_d1) begin
	   decc_out_tmp = way_sel_d1[0] ? way0_decc[set_d1] : way1_decc[set_d1];
	end
	else begin
	   tmp_decc_out = way_sel_d1[0] ? way0_decc[set_d1] : way1_decc[set_d1];
	   reg_decc_in[155:117] = (decc_in_d1[155:117] & {39{word_en_d1[3]}} |
				   tmp_decc_out[155:117] & {39{~word_en_d1[3]}});
	   reg_decc_in[116:78] = (decc_in_d1[116:78] & {39{word_en_d1[2]}} |
				  tmp_decc_out[116:78] & {39{~word_en_d1[2]}});
	   reg_decc_in[77:39] = (decc_in_d1[77:39] & {39{word_en_d1[1]}} |
				 tmp_decc_out[77:39] & {39{~word_en_d1[1]}});
	   reg_decc_in[38:0] = (decc_in_d1[38:0] & {39{word_en_d1[0]}} |
				tmp_decc_out[38:0] & {39{~word_en_d1[0]}});
	   if (way_sel_d1[0]) way0_decc[set_d1] =  reg_decc_in;
	   if (way_sel_d1[1]) way1_decc[set_d1] =  reg_decc_in;
	     decc_out_tmp[155:0] = 156'b0;
	end 
      end
      else begin
	 decc_out_tmp[155:0] = 156'b0;
      end
   end 
`endif
   assign decc_out[155:0] = (acc_en_d1 & ~wr_en_d1) ? 156'bX : (keep_rd_out) ? 
			    (decc_out_d1[155:0] | decc_read_in[155:0]) : 
			    (decc_out_tmp[155:0] | decc_read_in[155:0]);
   reg [8:0] 	s_red_reg0;
   reg [8:0] 	s_red_reg1;
   reg [8:0] 	s_red_reg2;
   reg [8:0] 	s_red_reg3;
   reg [8:0] 	s_red_reg4;
   reg [8:0] 	s_red_reg5;
   reg [8:0] 	m_red_reg0;
   reg [8:0] 	m_red_reg1;
   reg [8:0] 	m_red_reg2;
   reg [8:0] 	m_red_reg3;
   reg [8:0] 	m_red_reg4;
   reg [8:0] 	m_red_reg5;
   wire	     l2d_fuse_data_out;
assign l2d_fuse_data_out = s_red_reg5[8];
   always @(arst_l or fuse_clk1 or fuse_l2d_rid or fuse_l2d_wren or fuse_l2d_rden 
            or fuse_l2d_data_in or fuse_read_data_in 
	    or s_red_reg0 or s_red_reg1 or s_red_reg2 
	    or s_red_reg3 or s_red_reg4 or s_red_reg5) begin
      if (!arst_l) begin
         m_red_reg0[8:0] = 9'b0;
         m_red_reg1[8:0] = 9'b0;
         m_red_reg2[8:0] = 9'b0;
         m_red_reg3[8:0] = 9'b0;
         m_red_reg4[8:0] = 9'b0;
         m_red_reg5[8:0] = 9'b0;
      end
      if (arst_l && fuse_clk1) begin
         if (fuse_l2d_wren) begin
	    case (fuse_l2d_rid) 
	      3'b101: m_red_reg0[8:0] = {s_red_reg0[7:0], fuse_l2d_data_in};
	      3'b011: m_red_reg1[8:0] = {s_red_reg1[7:0], fuse_l2d_data_in};
	      3'b010: m_red_reg2[8:0] = {s_red_reg2[7:0], fuse_l2d_data_in};
	      3'b100: m_red_reg3[8:0] = {s_red_reg3[7:0], fuse_l2d_data_in};
	      3'b001: m_red_reg4[8:0] = {s_red_reg4[7:0], fuse_l2d_data_in};
	      3'b000: m_red_reg5[8:0] = {s_red_reg5[7:0], fuse_l2d_data_in};
	      default: ;
	    endcase 
         end 
         else if (fuse_l2d_rden) begin
		      m_red_reg0[8:0] = {s_red_reg0[7:0], fuse_read_data_in};
		      m_red_reg1[8:0] = {s_red_reg1[7:0], s_red_reg0[8]};
		      m_red_reg2[8:0] = {s_red_reg2[7:0], s_red_reg1[8]};
		      m_red_reg3[8:0] = {s_red_reg3[7:0], s_red_reg2[8]};
		      m_red_reg4[8:0] = {s_red_reg4[7:0], s_red_reg3[8]};
		      m_red_reg5[8:0] = {s_red_reg5[7:0], s_red_reg4[8]};
              end 
      end 
   end 
   always @(arst_l or fuse_clk2 or fuse_l2d_rid or fuse_l2d_wren or fuse_l2d_rden 
	    or m_red_reg0 or m_red_reg1 or m_red_reg2 
	    or m_red_reg3 or m_red_reg4 or m_red_reg5) begin
`ifdef DEFINE_0IN
`else
  `ifdef FPGA_SYN_RED
  `else
      if (!arst_l) begin
         m_red_reg0[8:0] = 9'b0;
         m_red_reg1[8:0] = 9'b0;
         m_red_reg2[8:0] = 9'b0;
         m_red_reg3[8:0] = 9'b0;
         m_red_reg4[8:0] = 9'b0;
         m_red_reg5[8:0] = 9'b0;
      end
  `endif
`endif
      if (fuse_clk2) begin
         if (fuse_l2d_wren) begin
	    case (fuse_l2d_rid) 
	      3'b101: s_red_reg0[8:0] = m_red_reg0[8:0];
	      3'b011: s_red_reg1[8:0] = m_red_reg1[8:0];
	      3'b010: s_red_reg2[8:0] = m_red_reg2[8:0];
	      3'b100: s_red_reg3[8:0] = m_red_reg3[8:0];
	      3'b001: s_red_reg4[8:0] = m_red_reg4[8:0];
	      3'b000: s_red_reg5[8:0] = m_red_reg5[8:0];
	     default: ;
	    endcase 
         end 
         else if (fuse_l2d_rden) begin
	        s_red_reg0[8:0] = m_red_reg0[8:0];
	        s_red_reg1[8:0] = m_red_reg1[8:0];
	        s_red_reg2[8:0] = m_red_reg2[8:0];
	        s_red_reg3[8:0] = m_red_reg3[8:0];
	        s_red_reg4[8:0] = m_red_reg4[8:0];
	      	s_red_reg5[8:0] = m_red_reg5[8:0];
              end 
      end 
   end 
endmodule 
