`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module flt_add_sub_comb
	(
	input		sub,
	input	[31:0]	afl,
	input	[31:0]	bfl,
	output reg	[31:0]	fl
	);
reg	[24:0]	ai_0;		
reg	[24:0]	bi_0;		
reg		sub_0;
reg	[7:0]	aefl_0;		
reg	[24:0]	n_ai_0;		
reg	[24:0]	n_bi_0;		
reg	[24:0]	n_mfl_0;	
reg		sfl_0;		
reg	[24:0]	nn_mfl_0;	
reg	[31:0]  afl_0;
reg	[31:0]  bfl_0;
reg	      	afl_eq_bfl_0;
reg	      	afl_eqz_0;
reg	      	bfl_eqz_0;
reg	[24:0]	nn_mfl_1;	
reg	[7:0]	nom_shft_1;	
reg	[24:0]	nmfl_1;		
reg	[7:0]	n_efl_1;	
reg		sub_1;
reg	      	afl_eqz_1;
reg	      	bfl_eqz_1;
reg	      	afl_eq_bfl_1;
reg	[7:0]	aefl_1;		
reg		sfl_1;		
reg	[31:0]  afl_1;
reg	[31:0]  bfl_1;
reg	[8:0]	agb;		
reg	[8:0]	bga;		
always @* agb = bfl[30:23] - afl[30:23];
always @* bga = afl[30:23] - bfl[30:23];
always @*
	begin
		sub_0 = sub;
                afl_0 = afl;
                bfl_0 = bfl;
                afl_eq_bfl_0 = (afl==bfl);
		afl_eqz_0 = ~|afl[30:0];
		bfl_eqz_0 = ~|bfl[30:0];
		if(agb[8]) 
			begin
				bi_0   = {(sub ^ bfl[31]), ({1'b1,bfl[22:0]} >> (bga[7:0]))};
				ai_0   = {afl[31], {1'b1,afl[22:0]}};
				aefl_0 = afl[30:23];
			end
		else 
			begin
				ai_0   = {afl[31], ({1'b1,afl[22:0]} >> (agb[7:0]))};
				aefl_0 = bfl[30:23];
				bi_0   = {(sub ^ bfl[31]), {1'b1,bfl[22:0]}};
			end
	end
always @*
	begin
		case({ai_0[24],bi_0[24]})
			2'b00:begin
					n_ai_0 = ai_0;
					n_bi_0 = bi_0;
			      end
			2'b11:begin
					n_ai_0 = {1'b0,ai_0[23:0]};
					n_bi_0 = {1'b0,bi_0[23:0]};
			      end
			2'b10:begin
					n_ai_0 = {ai_0[24],~ai_0[23:0]};
					n_bi_0 = bi_0;
			      end
			2'b01:begin
					n_ai_0 = ai_0;
					n_bi_0 = {bi_0[24],~bi_0[23:0]};
			      end
		endcase
      end
always @* n_mfl_0 = n_ai_0 + n_bi_0;
always @*     
	begin
		casex({ai_0[24],bi_0[24],n_mfl_0[24]})
			3'b00x:sfl_0 = 1'b0;
			3'b11x:sfl_0 = 1'b1;
			3'b100:sfl_0 = 1'b0;
			3'b101:sfl_0 = 1'b1;
			3'b010:sfl_0 = 1'b0;
			3'b011:sfl_0 = 1'b1;
		endcase
	end
always @*     
        begin
                casex({ai_0[24],bi_0[24],n_mfl_0[24]})
                        3'b00x:nn_mfl_0 =  n_mfl_0[24:0];
                        3'b11x:nn_mfl_0 =  n_mfl_0[24:0];
                        3'b100:begin
                                        nn_mfl_0[23:0] =  n_mfl_0[23:0]+24'h1;
                                        nn_mfl_0[24] = 1'b0; 
                                end
                        3'b101:begin
                                        nn_mfl_0[23:0] = ~n_mfl_0[23:0];
                                        nn_mfl_0[24] = 1'b0;
                                end
                        3'b010:begin
                                        nn_mfl_0[23:0] =  n_mfl_0[23:0]+24'h1;
                                        nn_mfl_0[24] = 1'b0;
                                end
                        3'b011:begin
                                        nn_mfl_0[23:0] = ~n_mfl_0[23:0];
                                        nn_mfl_0[24] = 1'b0;
                                end
                endcase
	end
always @*
	begin
		sub_1 = sub_0; 
		sfl_1 = sfl_0; 
		afl_eqz_1 = afl_eqz_0; 
		bfl_eqz_1 = bfl_eqz_0; 
                afl_eq_bfl_1 = afl_eq_bfl_0;
		aefl_1 = aefl_0;
                afl_1 = afl_0;
                bfl_1 = bfl_0;
                nn_mfl_1 = nn_mfl_0;
		nom_shft_1 = 0;
		casex(nn_mfl_0) 
		25'b1xxxxxxxxxxxxxxxxxxxxxxxx: nom_shft_1 <=24;
		25'b01xxxxxxxxxxxxxxxxxxxxxxx: nom_shft_1 <=0;
		25'b001xxxxxxxxxxxxxxxxxxxxxx: nom_shft_1 <=1;
		25'b0001xxxxxxxxxxxxxxxxxxxxx: nom_shft_1 <=2;
		25'b00001xxxxxxxxxxxxxxxxxxxx: nom_shft_1 <=3;
		25'b000001xxxxxxxxxxxxxxxxxxx: nom_shft_1 <=4;
		25'b0000001xxxxxxxxxxxxxxxxxx: nom_shft_1 <=5;
		25'b00000001xxxxxxxxxxxxxxxxx: nom_shft_1 <=6;
		25'b000000001xxxxxxxxxxxxxxxx: nom_shft_1 <=7;
		25'b0000000001xxxxxxxxxxxxxxx: nom_shft_1 <=8;
		25'b00000000001xxxxxxxxxxxxxx: nom_shft_1 <=9;
		25'b000000000001xxxxxxxxxxxxx: nom_shft_1 <=10;
		25'b0000000000001xxxxxxxxxxxx: nom_shft_1 <=11;
		25'b00000000000001xxxxxxxxxxx: nom_shft_1 <=12;
		25'b000000000000001xxxxxxxxxx: nom_shft_1 <=13;
		25'b0000000000000001xxxxxxxxx: nom_shft_1 <=14;
		25'b00000000000000001xxxxxxxx: nom_shft_1 <=15;
		25'b000000000000000001xxxxxxx: nom_shft_1 <=16;
		25'b0000000000000000001xxxxxx: nom_shft_1 <=17;
		25'b00000000000000000001xxxxx: nom_shft_1 <=18;
		25'b000000000000000000001xxxx: nom_shft_1 <=19;
		25'b0000000000000000000001xxx: nom_shft_1 <=20;
		25'b00000000000000000000001xx: nom_shft_1 <=21;
		25'b000000000000000000000001x: nom_shft_1 <=22;
		25'b0000000000000000000000001: nom_shft_1 <=23;
		default: nom_shft_1 <=0;
		endcase
	end
always @(nn_mfl_1 or nom_shft_1)
	begin
		if(nom_shft_1[4] & nom_shft_1[3])nmfl_1 = nn_mfl_1 >> 1;
		else nmfl_1 = nn_mfl_1 << nom_shft_1;
	end
always @*	
	begin
		if(nom_shft_1[4] & nom_shft_1[3])n_efl_1 = aefl_1+8'h1;
		else n_efl_1 = aefl_1 - nom_shft_1;
	end
always @*
        begin
                casex({sub_1,afl_eqz_1,bfl_eqz_1,afl_eq_bfl_1})
                        4'b000x: fl = {sfl_1,n_efl_1,nmfl_1[22:0]};
                        4'b001x: fl = afl_1;
                        4'b010x: fl = bfl_1;
                        4'b011x: fl = 0;
                        4'b1xx1: fl = 0;
                        4'b1xx0: fl = {sfl_1,n_efl_1,nmfl_1[22:0]};
                endcase
        end
endmodule
