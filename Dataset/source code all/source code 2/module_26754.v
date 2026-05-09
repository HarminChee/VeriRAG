module dct(
	clk,
	ena,
	rst,
	dstrb,
	din,
	dout_00, dout_01, dout_02, dout_03, dout_04, dout_05, dout_06, dout_07,
	dout_10, dout_11, dout_12, dout_13, dout_14, dout_15, dout_16, dout_17,
	dout_20, dout_21, dout_22, dout_23, dout_24, dout_25, dout_26, dout_27,
	dout_30, dout_31, dout_32, dout_33, dout_34, dout_35, dout_36, dout_37,
	dout_40, dout_41, dout_42, dout_43, dout_44, dout_45, dout_46, dout_47,
	dout_50, dout_51, dout_52, dout_53, dout_54, dout_55, dout_56, dout_57,
	dout_60, dout_61, dout_62, dout_63, dout_64, dout_65, dout_66, dout_67,
	dout_70, dout_71, dout_72, dout_73, dout_74, dout_75, dout_76, dout_77,
	douten
);
	parameter coef_width = 11;
	parameter di_width = 8;
	parameter do_width = 12;
	input clk;
	input ena;
	input rst;   
	input dstrb; 
	input  [di_width:1] din;
	output [do_width:1]
		dout_00, dout_01, dout_02, dout_03, dout_04, dout_05, dout_06, dout_07,
		dout_10, dout_11, dout_12, dout_13, dout_14, dout_15, dout_16, dout_17,
		dout_20, dout_21, dout_22, dout_23, dout_24, dout_25, dout_26, dout_27,
		dout_30, dout_31, dout_32, dout_33, dout_34, dout_35, dout_36, dout_37,
		dout_40, dout_41, dout_42, dout_43, dout_44, dout_45, dout_46, dout_47,
		dout_50, dout_51, dout_52, dout_53, dout_54, dout_55, dout_56, dout_57,
		dout_60, dout_61, dout_62, dout_63, dout_64, dout_65, dout_66, dout_67,
		dout_70, dout_71, dout_72, dout_73, dout_74, dout_75, dout_76, dout_77;
	output douten; 
	reg douten;
	reg go, dgo, ddgo, ddcnt, dddcnt;
	reg [di_width:1] ddin;
	reg  [5:0] sample_cnt;
	wire       dcnt     = &sample_cnt;
	always @(posedge clk or negedge rst)
	  if (~rst)
	     sample_cnt <= #1 6'h0;
	  else if (ena)
	    if(dstrb)
	      sample_cnt <= #1 6'h0;
	    else if(~dcnt)
	      sample_cnt <= #1 sample_cnt + 6'h1;
	always @(posedge clk or negedge rst)
	  if (~rst)
	  begin
	      go     <= #1 1'b0;
		  dgo    <= #1 1'b0;
		  ddgo   <= #1 1'b0;
		  ddin   <= #1 0;
	      douten <= #1 1'b0;
	      ddcnt  <= #1 1'b1;
	      dddcnt <= #1 1'b1;
	  end
	  else if (ena)
	  begin
	      go     <= #1 dstrb;
	      dgo    <= #1 go;
	      ddgo   <= #1 dgo;
	      ddin   <= #1 din;
	      ddcnt  <= #1 dcnt;
	      dddcnt <= #1 ddcnt;
	      douten <= #1 ddcnt & ~dddcnt;
	  end
	dctub #(coef_width, di_width, 3'h0)
	dct_block_0 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_00), 
		.dout1(dout_01), 
		.dout2(dout_02), 
		.dout3(dout_03), 
		.dout4(dout_04), 
		.dout5(dout_05), 
		.dout6(dout_06), 
		.dout7(dout_07)  
	);
	dctub #(coef_width, di_width, 3'h1)
	dct_block_1 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_10), 
		.dout1(dout_11), 
		.dout2(dout_12), 
		.dout3(dout_13), 
		.dout4(dout_14), 
		.dout5(dout_15), 
		.dout6(dout_16), 
		.dout7(dout_17)  
	);
	dctub #(coef_width, di_width, 3'h2)
	dct_block_2 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_20), 
		.dout1(dout_21), 
		.dout2(dout_22), 
		.dout3(dout_23), 
		.dout4(dout_24), 
		.dout5(dout_25), 
		.dout6(dout_26), 
		.dout7(dout_27)  
	);
	dctub #(coef_width, di_width, 3'h3)
	dct_block_3 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_30), 
		.dout1(dout_31), 
		.dout2(dout_32), 
		.dout3(dout_33), 
		.dout4(dout_34), 
		.dout5(dout_35), 
		.dout6(dout_36), 
		.dout7(dout_37)  
	);
	dctub #(coef_width, di_width, 3'h4)
	dct_block_4 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_40), 
		.dout1(dout_41), 
		.dout2(dout_42), 
		.dout3(dout_43), 
		.dout4(dout_44), 
		.dout5(dout_45), 
		.dout6(dout_46), 
		.dout7(dout_47)  
	);
	dctub #(coef_width, di_width, 3'h5)
	dct_block_5 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_50), 
		.dout1(dout_51), 
		.dout2(dout_52), 
		.dout3(dout_53), 
		.dout4(dout_54), 
		.dout5(dout_55), 
		.dout6(dout_56), 
		.dout7(dout_57)  
	);
	dctub #(coef_width, di_width, 3'h6)
	dct_block_6 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_60), 
		.dout1(dout_61), 
		.dout2(dout_62), 
		.dout3(dout_63), 
		.dout4(dout_64), 
		.dout5(dout_65), 
		.dout6(dout_66), 
		.dout7(dout_67)  
	);
	dctub #(coef_width, di_width, 3'h7)
	dct_block_7 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_70), 
		.dout1(dout_71), 
		.dout2(dout_72), 
		.dout3(dout_73), 
		.dout4(dout_74), 
		.dout5(dout_75), 
		.dout6(dout_76), 
		.dout7(dout_77)  
	);
endmodule
