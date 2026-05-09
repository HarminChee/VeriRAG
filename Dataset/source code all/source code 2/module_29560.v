module bw_r_rf16x128d(
   dout, so, 
   din, rd_wl, wr_wl, read_en, wr_en, rst_tri_en, rclk, se, si, 
   reset_l, sehold
   );
   input [127:0]  din; 
   input [15:0]    rd_wl;   
   input [15:0]	  wr_wl;  
   input          read_en;  
   input	  wr_en;	
   input	  rst_tri_en ; 
   input          rclk;
   input          se, si ;
   input	  reset_l;
   input	  sehold; 
   output [127:0] dout;
   output         so;
   reg [127:0] dout;
   reg [127:0]  inq_ary [15:0];
   integer      i;
   reg [127:0]  temp, data_in;
   reg [3:0]	rdptr_d1, wrptr_d1;
   wire	[160:0]	scan_out;
reg [127:0]  wrdata_d1 ;
reg          ren_d1;
reg		 wr_en_d1;
reg [15:0]	 rd_wl_d1, wr_wl_d1;
 reg	rst_tri_en_d1;
always	@(posedge rclk ) begin
  wrdata_d1 <= ( sehold)? wrdata_d1 : din;
  wr_en_d1 <= ( sehold)? wr_en_d1 : wr_en ;
  wr_wl_d1 <= (sehold) ? wr_wl_d1 : wr_wl ;
  ren_d1 <= (sehold)? ren_d1 : read_en;
  rd_wl_d1 <= (sehold) ? rd_wl_d1 : rd_wl ;
  rst_tri_en_d1 <= rst_tri_en ; 
end 
   always @( rd_wl_d1 or ren_d1 or reset_l
            or rst_tri_en_d1 or wr_en_d1 or wr_wl_d1)
     begin
         if (reset_l)
               begin
                  if (ren_d1)
                    begin
			case(rd_wl_d1 & {16{~rst_tri_en}})
	  			16'b0000_0000_0000_0000: ; 
          			16'b0000_0000_0000_0001: rdptr_d1	= 4'b0000;
          			16'b0000_0000_0000_0010: rdptr_d1     = 4'b0001;
          			16'b0000_0000_0000_0100: rdptr_d1     = 4'b0010;
          			16'b0000_0000_0000_1000: rdptr_d1     = 4'b0011;
          			16'b0000_0000_0001_0000: rdptr_d1     = 4'b0100;
          			16'b0000_0000_0010_0000: rdptr_d1     = 4'b0101;
          			16'b0000_0000_0100_0000: rdptr_d1     = 4'b0110;
          			16'b0000_0000_1000_0000: rdptr_d1     = 4'b0111;
          			16'b0000_0001_0000_0000: rdptr_d1     = 4'b1000;
          			16'b0000_0010_0000_0000: rdptr_d1     = 4'b1001;
          			16'b0000_0100_0000_0000: rdptr_d1     = 4'b1010;
          			16'b0000_1000_0000_0000: rdptr_d1     = 4'b1011;
          			16'b0001_0000_0000_0000: rdptr_d1     = 4'b1100;
          			16'b0010_0000_0000_0000: rdptr_d1     = 4'b1101;
          			16'b0100_0000_0000_0000: rdptr_d1     = 4'b1110;
          			16'b1000_0000_0000_0000: rdptr_d1     = 4'b1111;
          			default: rdptr_d1 = 4'bx ; 
        		endcase
`ifdef  INNO_MUXEX
`else
                       if(rdptr_d1 == 4'bx) begin
					`ifdef MODELSIM
                                $display("rf_error"," read pointer error %h ", rdptr_d1[3:0]);
					`else
                                $error("rf_error"," read pointer error %h ", rdptr_d1[3:0]);
					`endif		
                       end
`endif
		       if(rst_tri_en_d1) begin 
				dout[127:0] = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF ;
		       end
                       else if ((( wr_en_d1 & ~rst_tri_en ) && (rd_wl_d1 == wr_wl_d1))||
				((rd_wl_d1 & {16{~rst_tri_en}}) == 16'b0 )) begin
			 	dout[127:0] = 128'bx ;
                       end
                       else dout = inq_ary[rdptr_d1];
                    end 
          end 
	  else dout  = 128'b0 ;
     end 
   always @ (reset_l or rst_tri_en_d1 or wr_en_d1
             or wr_wl_d1 or wrdata_d1)
     begin
        if ( reset_l) begin
`ifdef  INNO_MUXEX
		if(wr_en_d1==1'bx) begin
		end
`else
	 	if(wr_en_d1==1'bx) begin
		`ifdef MODELSIM
			$display("rf_error"," write enable error %b ", wr_en_d1);
		`else
			$error("rf_error"," write enable error %b ", wr_en_d1);
		`endif	
         	end
`endif
	 	else if(wr_en_d1 & ~rst_tri_en )  begin
			case(wr_wl_d1)
	  			16'b0000_0000_0000_0000: ; 
          			16'b0000_0000_0000_0001: wrptr_d1	= 4'b0000;
          			16'b0000_0000_0000_0010: wrptr_d1     = 4'b0001;
          			16'b0000_0000_0000_0100: wrptr_d1     = 4'b0010;
          			16'b0000_0000_0000_1000: wrptr_d1     = 4'b0011;
          			16'b0000_0000_0001_0000: wrptr_d1     = 4'b0100;
          			16'b0000_0000_0010_0000: wrptr_d1     = 4'b0101;
          			16'b0000_0000_0100_0000: wrptr_d1     = 4'b0110;
          			16'b0000_0000_1000_0000: wrptr_d1     = 4'b0111;
          			16'b0000_0001_0000_0000: wrptr_d1     = 4'b1000;
          			16'b0000_0010_0000_0000: wrptr_d1     = 4'b1001;
          			16'b0000_0100_0000_0000: wrptr_d1     = 4'b1010;
          			16'b0000_1000_0000_0000: wrptr_d1     = 4'b1011;
          			16'b0001_0000_0000_0000: wrptr_d1     = 4'b1100;
          			16'b0010_0000_0000_0000: wrptr_d1     = 4'b1101;
          			16'b0100_0000_0000_0000: wrptr_d1     = 4'b1110;
          			16'b1000_0000_0000_0000: wrptr_d1     = 4'b1111;
          			default:  wrptr_d1= 4'bx ; 
			endcase
`ifdef  INNO_MUXEX
			      if(wr_wl_d1!=16'b0)
             			inq_ary[wrptr_d1] = wrdata_d1 ;
`else
	 		if(wrptr_d1 == 4'bx) begin
			`ifdef MODELSIM
               			$display("rf_error"," write pointer error %h ", wrptr_d1[3:0]);
			`else
               			$error("rf_error"," write pointer error %h ", wrptr_d1[3:0]);
			`endif
         		end
	 		else  begin
			      if(wr_wl_d1!=16'b0)
             			inq_ary[wrptr_d1] = wrdata_d1 ;
         		end
`endif
	 	end
	 	else  begin
	 	end
	end 
     end 
endmodule 
