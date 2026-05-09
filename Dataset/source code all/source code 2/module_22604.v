module bw_r_rf32x108(
   dout, so, 
   din, rd_adr1, rd_adr2, sel_rdaddr1, wr_adr, read_en, wr_en, 
   word_wen, rst_tri_en, rclk, se, si, reset_l, sehold
   );
   input [107:0]  din; 
   input [4:0]    rd_adr1;   
   input [4:0]    rd_adr2;   
   input	  sel_rdaddr1; 
   input [4:0]	  wr_adr;  
   input          read_en;  
   input	  wr_en ;	
   input [3:0]    word_wen; 
   input	  rst_tri_en ; 
   input          rclk;
   input          se, si ;
   input	  reset_l;
   input	  sehold; 
   output [107:0] dout;
   output         so;
   reg [107:0]   wrdata_d1 ;
   reg [3:0]     word_wen_d1;
   reg [4:0]     rdptr_d1, wrptr_d1;
   reg           ren_d1;
   reg		  wr_en_d1;
   reg		rst_tri_en_d1;
`ifdef DEFINE_0IN
   reg          so;
`else
   reg [107:0] dout;
   wire	[122:0] scan_out ;
   reg [107:0]  inq_ary [31:0];
`endif
   integer      i;
   reg [107:0]  temp, data_in, tmp_dout;
`ifdef DEFINE_0IN
   wire	[107:0]	bit_en_d1;
		assign	bit_en_d1[0] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[1] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[2] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[3] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[4] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[5] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[6] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[7] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[8] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[9] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[10] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[11] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[12] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[13] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[14] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[15] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[16] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[17] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[18] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[19] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[20] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[21] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[22] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[23] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[24] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[25] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[26] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[27] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[28] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[29] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[30] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[31] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[32] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[33] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[34] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[35] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[36] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[37] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[38] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[39] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[40] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[41] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[42] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[43] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[44] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[45] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[46] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[47] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[48] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[49] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[50] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[51] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[52] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[53] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[54] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[55] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[56] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[57] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[58] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[59] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[60] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[61] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[62] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[63] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[64] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[65] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[66] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[67] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[68] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[69] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[70] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[71] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[72] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[73] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[74] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[75] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[76] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[77] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[78] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[79] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[80] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[81] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[82] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[83] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[84] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[85] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[86] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[87] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[88] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[89] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[90] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[91] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[92] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[93] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[94] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[95] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[96] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[97] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[98] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[99] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[100] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[101] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[102] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[103] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[104] = word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[105] = word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[106] = word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ;
		assign	bit_en_d1[107] = word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ;
`else
`endif
always	@(posedge rclk ) begin
      	wrdata_d1 <= (sehold)? wrdata_d1 :din;
	word_wen_d1 <= (sehold)? word_wen_d1 : word_wen ;
       	wrptr_d1 <= (sehold)? wrptr_d1 :wr_adr;
       	ren_d1 <= (sehold)? ren_d1 : read_en;
       	wr_en_d1 <= (sehold)? wr_en_d1 : wr_en;
       	rdptr_d1 <= (sehold)? rdptr_d1 : ( (sel_rdaddr1)?  rd_adr1: rd_adr2 ) ;
	rst_tri_en_d1 <= rst_tri_en ;  
end
`ifdef DEFINE_0IN
rf32x108 rf32x108 ( .rclk(rclk), .radr(rdptr_d1), .wadr(wrptr_d1), .ren(ren_d1),
                        .we(reset_l), .wm(bit_en_d1), .din(wrdata_d1), .dout(dout) ); 
`else
always @( rdptr_d1 or ren_d1 or reset_l
         or rst_tri_en_d1 or word_wen_d1 or wr_en_d1 or wrptr_d1)
     begin
             if (reset_l)
               begin
                  if (ren_d1 )
                    begin
`ifdef	INNO_MUXEX
`else
			if(rdptr_d1 == 5'bx) begin
			`ifdef MODELSIM
				$display("rf_error"," read pointer error %h ", rdptr_d1[4:0]);
			`else
				$error("rf_error"," read pointer error %h ", rdptr_d1[4:0]);
			`endif
			end
`endif
			tmp_dout = inq_ary[rdptr_d1] ;
			for(i=0; i< 108; i=i+4) begin
				if((rdptr_d1 == wrptr_d1)) begin
			 		dout[i] =   ( word_wen_d1[0] & wr_en_d1 & ~rst_tri_en )? 
							1'bx : tmp_dout[i] ;
			 		dout[i+1] = ( word_wen_d1[1] & wr_en_d1 & ~rst_tri_en )? 
                                                        1'bx : tmp_dout[i+1] ;
			 		dout[i+2] = ( word_wen_d1[2] & wr_en_d1 & ~rst_tri_en )? 
                                                        1'bx : tmp_dout[i+2] ;
			 		dout[i+3] = ( word_wen_d1[3] & wr_en_d1 & ~rst_tri_en )? 
                                                        1'bx : tmp_dout[i+3] ;
				end
				else begin
					dout[i] = tmp_dout[i] ;
					dout[i+1] = tmp_dout[i+1] ;
					dout[i+2] = tmp_dout[i+2] ;
					dout[i+3] = tmp_dout[i+3] ;
				end
			end 
                    end
     	    end 
	    else dout  = 108'b0 ;
end 
always @(reset_l or rst_tri_en_d1 or word_wen_d1 or wr_en_d1
         or wrdata_d1 or wrptr_d1)
     begin
        if ( reset_l)
	 begin    
`ifdef	INNO_MUXEX
`else
		if((word_wen_d1 & {4{wr_en_d1 & ~rst_tri_en}}) == 4'bx ) begin
		`ifdef MODELSIM
			$display("rf_error"," write enable error %h ", word_wen_d1[3:0]);
		`else
			$error("rf_error"," write enable error %h ", word_wen_d1[3:0]);
		`endif	
		end
`endif
		if(wr_en_d1 & ~rst_tri_en)   begin
`ifdef	INNO_MUXEX
`else
			if(wrptr_d1 == 5'bx) begin
			`ifdef MODELSIM
				$display("rf_error"," read pointer error %h ", wrptr_d1[4:0]);
			`else
				$error("rf_error"," read pointer error %h ", wrptr_d1[4:0]);
			`endif
			end
`endif
             		temp = 	inq_ary[wrptr_d1];
             		for (i=0; i<108; i=i+4) begin
                		data_in[i] = ( word_wen_d1[0] & wr_en_d1 & ~rst_tri_en ) ? 
							wrdata_d1[i] : temp[i] ;
                		data_in[i+1] = ( word_wen_d1[1] & wr_en_d1 & ~rst_tri_en ) ? 
							wrdata_d1[i+1] : temp[i+1] ;
                		data_in[i+2] = ( word_wen_d1[2] & wr_en_d1 & ~rst_tri_en ) ? 
							wrdata_d1[i+2] : temp[i+2] ;
                		data_in[i+3] = ( word_wen_d1[3] & wr_en_d1 & ~rst_tri_en ) ? 
							wrdata_d1[i+3] : temp[i+3] ;
             		end
             		inq_ary[wrptr_d1] = data_in ;
		end
          end
end 
`endif
endmodule 
