`define ICARUS			
`timescale 1ns/1ps
`define ICARUS			
`timescale 1ns/1ps
module pbkdfengine
	(hash_clk, pbkdf_clk, data1, data2, data3, target, nonce_msb, nonce_out, golden_nonce_out, golden_nonce_match, loadnonce,
			salsa_din, salsa_dout, salsa_busy, salsa_result, salsa_reset, salsa_start, salsa_shift);
	input hash_clk;			
	input pbkdf_clk;
	input [255:0] data1;
	input [255:0] data2;
	input [127:0] data3;
	input [31:0] target;
	input [3:0] nonce_msb;
	output [31:0] nonce_out;
	output [31:0] golden_nonce_out;
	output golden_nonce_match;	
	input loadnonce;			
	input salsa_dout;
	output salsa_din;
	input salsa_busy, salsa_result;	
	output salsa_reset;
	output salsa_start;
	output reg salsa_shift = 1'b0;	
	reg [3:0]resetcycles = 4'd0;
	reg reset = 1'b0;
	assign salsa_reset = reset;		
`ifdef WANTCYCLICRESET		
	reg [23:0]cycresetcount = 24'd0;
`endif
	always @ (posedge pbkdf_clk)
	begin
		resetcycles <= resetcycles + 1'd1;
		if (resetcycles == 0)
			reset <= 1'b1;
		if (resetcycles == 15)
		begin
			reset <= 1'b0;
			resetcycles <= 15;
		end
`ifdef WANTCYCLICRESET		
		cycresetcount <= cycresetcount + 1'd1;
		if (cycresetcount == 2_500_000)	
		begin
			cycresetcount <= 24'd0;
			resetcycles <= 4'd0;
		end
`endif		
		if (loadnonce)
			resetcycles <= 4'd0;
	end
	`ifndef ICARUS
	reg [31:0] nonce_previous_load = 32'hffffffff;	
	`endif
	`ifndef NOMULTICORE
	`ifdef SIM
		reg [27:0] nonce_cnt = 28'h318f;	
	`else
		reg [27:0] nonce_cnt = 28'd0;		
	`endif
		wire [31:0] nonce;
		assign nonce = { nonce_msb, nonce_cnt };
	`else
		reg [31:0] nonce = 32'd0;			
	`endif
	assign nonce_out = nonce;
	reg [31:0] nonce_sr = 32'd0;		
	reg [31:0] golden_nonce = 32'd0;
	assign golden_nonce_out = golden_nonce;
	reg golden_nonce_match = 1'b0;
	reg [2:0] nonce_wait = 3'd0;
	reg [255:0] rx_state;
	reg [511:0] rx_input;
	wire [255:0] tx_hash;
	reg [255:0] khash = 256'd0;		
	reg [255:0] ihash = 256'd0;		
	reg [255:0] ohash = 256'd0;		
	`ifdef SIM
		reg [255:0] final_hash = 256'd0;	
	`endif
	reg [2:0] blockcnt = 3'd0;		
	reg [1023:0] Xbuf = 1024'd0;	
	reg [5:0] cnt = 6'd0;
	wire feedback;
	assign feedback = (cnt != 6'b0);
	assign salsa_din = Xbuf[1023];
	wire [1023:0] MixOutRewire;		
	`define IDX(x) (((x)+1)*(32)-1):((x)*(32))
	genvar i;
	generate
	for (i = 0; i < 32; i = i + 1) begin : Xrewire
		wire [31:0] mix;
		assign mix = Xbuf[`IDX(i)];		
		assign MixOutRewire[`IDX(i)] = { mix[7:0], mix[15:8], mix[23:16], mix[31:24] };
	end
	endgenerate
	reg SMixInRdy_state = 1'b0;		
	reg SMixOutRdy_state = 1'b0;	
	wire SMixInRdy;
	wire SMixOutRdy;
	reg Set_SMixInRdy = 1'b0;
	reg Clr_SMixOutRdy = 1'b0;
	reg [3:0]salsa_busy_d;			
	reg [3:0]salsa_result_d;
	wire Clr_SMixInRdy;
	assign Clr_SMixInRdy = SMixInRdy_state & salsa_busy_d[2] & ~salsa_busy_d[3];		
	wire Set_SMixOutRdy;
	assign Set_SMixOutRdy = ~SMixOutRdy_state & salsa_result_d[2] & ~salsa_result_d[3];	
	reg [3:0]Xbuf_load_request = 1'b0;
	reg [3:0]shift_request =  1'b0;
	reg [3:0]shift_acknowledge = 1'b0;
	always @ (posedge pbkdf_clk)
	begin
		salsa_busy_d[0] <= salsa_busy;			
		salsa_busy_d[3:1] <= salsa_busy_d[2:0];
		salsa_result_d[0] <= salsa_result;
		salsa_result_d[3:1] <= salsa_result_d[2:0];
		if (Set_SMixInRdy)
			SMixInRdy_state <= 1'b1;
		if (Clr_SMixInRdy)
			SMixInRdy_state <= 1'b0;	
		if (Set_SMixOutRdy)
			SMixOutRdy_state <= 1'b1;
		if (Clr_SMixOutRdy)
			SMixOutRdy_state <= 1'b0;	
		if (reset)
		begin							
			SMixInRdy_state <= 1'b0;
			SMixOutRdy_state <= 1'b0;
		end
	end
	assign SMixInRdy = Clr_SMixInRdy ? 1'b0 : Set_SMixInRdy ? 1'b1 : SMixInRdy_state;
	assign SMixOutRdy = Clr_SMixOutRdy ? 1'b0 : Set_SMixOutRdy ? 1'b1 : SMixOutRdy_state;
	assign salsa_start = SMixInRdy;
	parameter	S_IDLE=0,
				S_H1= 1, S_H2= 2, S_H3= 3, S_H4= 4, S_H5= 5, S_H6= 6,	
				S_I1= 7, S_I2= 8, S_I3= 9, S_I4=10, S_I5=11, S_I6=12,	
				S_O1=13, S_O2=14, S_O3=15,								
				S_B1=16, S_B2=17, S_B3=18, S_B4=19, S_B5=20, S_B6=21,	
				S_NONCE=22, S_SHIFT_IN=41, S_SHIFT_OUT=42,				
				S_R1=23, S_R2=24, S_R3=25, S_R4=26, S_R5=27, S_R6=28,	
				S_R7=29, S_R8=30, S_R9=31, S_R10=32, S_R11=33, S_R12=34,
				S_R13=35, S_R14=36, S_R15=37, S_R16=38, S_R17=39, S_R18=40;
	reg [5:0] state = S_IDLE;
	reg mode = 0;	
	reg start_output = 0;
	always @ (posedge pbkdf_clk)
	begin
		Set_SMixInRdy <= 1'b0;	
		Clr_SMixOutRdy <= 1'b0;
		golden_nonce_match <= 1'b0;	
		shift_acknowledge[3:1] <= shift_acknowledge[2:0];	
		`ifdef ICARUS
		if (loadnonce)				
		`else
		if (loadnonce || (nonce_previous_load != data3[127:96]))
		`endif
		begin
			`ifdef NOMULTICORE
				nonce <= data3[127:96];	
			`else
				nonce_cnt <= data3[123:96];	
			`endif
			`ifndef ICARUS
			nonce_previous_load <= data3[127:96];
			`endif
		end
		if (reset == 1'b1)
		begin
			state <= S_IDLE;
			start_output <= 1'b0;
		end
		else
		begin
			case (state)
				S_IDLE: begin
					if (SMixOutRdy & ~start_output)
					begin
						shift_request[0] <= ~shift_request[0];	
						state <= S_SHIFT_OUT;
					end
					else
					begin
						if (start_output ||	
							!SMixInRdy)		
						begin
							start_output <= 1'b0;
							mode <= 1'b0;
							rx_state <= 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
							rx_input <= { data2, data1 };	
							blockcnt <= 3'd1;
							cnt <= 6'd0;
							if (SMixOutRdy)					
								mode <= 1'b1;
							state <= S_H1;
						end
					end
				end
				S_H1: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_H2;
					end
				end
				S_H2: begin	
						state <= S_H3;
				end
				S_H3: begin	
						rx_state <= tx_hash;
						rx_input <= { 384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000,
										mode ? nonce_sr : nonce, data3[95:0] };
						state <= S_H4;
				end
				S_H4: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_H5;
					end
				end
				S_H5: begin	
						state <= S_H6;
				end
				S_H6: begin	
						khash <= tx_hash;	
						rx_state <= 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
						rx_input <= { 256'h3636363636363636363636363636363636363636363636363636363636363636 ,
										tx_hash ^ 256'h3636363636363636363636363636363636363636363636363636363636363636 };
						cnt <= 6'd0;
						if (mode)
							state <= S_R1;
						else
							state <= S_I1;
				end
				S_I1: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_I2;
					end
				end
				S_I2: begin	
						state <= S_I3;
				end
				S_I3: begin	
						rx_state <= tx_hash;
						rx_input <= { data2, data1 };	
						state <= S_I4;
				end
				S_I4: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_I5;
					end
				end
				S_I5: begin	
						state <= S_I6;
				end
				S_I6: begin	
						ihash <= tx_hash;				
						rx_state <= 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
						rx_input <= { 256'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c ,
										khash ^ 256'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c };
						cnt <= 6'd0;
						state <= S_O1;
				end
				S_O1: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_O2;
					end
				end
				S_O2: begin	
						state <= S_O3;
				end
				S_O3: begin	
						ohash <= tx_hash;				
						rx_state <= ihash;
						rx_input <= { 352'h000004a000000000000000000000000000000000000000000000000000000000000000000000000080000000,
										29'd0, blockcnt, nonce, data3[95:0] }; 
						blockcnt <= blockcnt + 1'd1;		
						cnt <= 6'd0;
						state <= S_B1;
				end
				S_B1: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_B2;
					end
				end
				S_B2: begin	
						state <= S_B3;
				end
				S_B3: begin	
						rx_state <= ohash;
						rx_input <= { 256'h0000030000000000000000000000000000000000000000000000000080000000, tx_hash };
						state <= S_B4;
				end
				S_B4: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_B5;
					end
				end
				S_B5: begin	
						state <= S_B6;
				end		
				S_B6: begin
						khash <= tx_hash;		
						Xbuf_load_request[0] <= ~Xbuf_load_request[0];	
						if (blockcnt == 3'd5)
						begin
							nonce_wait <= 3'd7;
							state <= S_NONCE;
						end
						else begin
							rx_state <= ihash;
							rx_input <= { 352'h000004a000000000000000000000000000000000000000000000000000000000000000000000000080000000,
											29'd0, blockcnt, nonce, data3[95:0] }; 
							blockcnt <= blockcnt + 1'd1;		
							cnt <= 6'd0;
							state <= S_B1;
						end
				end
				S_NONCE: begin
						nonce_wait <= nonce_wait - 1'd1;
						if (nonce_wait == 0)
						begin
							`ifndef NOMULTICORE
								nonce_cnt <= nonce_cnt + 1'd1;
							`else
								nonce <= nonce + 1'd1;
							`endif
							shift_request[0] <= ~shift_request[0];
							state <= S_SHIFT_IN;
						end
				end
				S_SHIFT_IN: begin							
						if (shift_acknowledge[3] != shift_acknowledge[2])
						begin
							Set_SMixInRdy <= 1'd1;				
							state <= S_IDLE;
						end
				end
				S_SHIFT_OUT: begin							
						if (shift_acknowledge[3] != shift_acknowledge[2])
						begin
							start_output <= 1'd1;				
							state <= S_IDLE;
						end
				end
				S_R1: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_R2;
					end
				end
				S_R2: begin	
						state <= S_R3;
				end
				S_R3: begin	
						rx_state <= tx_hash;
						rx_input <= MixOutRewire[511:0];		
						state <= S_R4;
				end
				S_R4: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_R5;
					end
				end
				S_R5: begin	
						state <= S_R6;
				end
				S_R6: begin	
						rx_state <= tx_hash;
						rx_input <= MixOutRewire[1023:512];		
						state <= S_R7;
				end
				S_R7: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_R8;
					end
				end
				S_R8: begin	
						state <= S_R9;
				end
				S_R9: begin	
						rx_state <= tx_hash;
						rx_input <= 512'h00000620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000001;
						state <= S_R10;
				end
				S_R10: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_R11;
					end
				end
				S_R11: begin	
						state <= S_R12;
				end
				S_R12: begin	
						ihash <= tx_hash;				
						rx_state <= 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
						rx_input <= { 256'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c ,
										khash ^ 256'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c };
						cnt <= 6'd0;
						state <= S_R13;
				end
				S_R13: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_R14;
					end
				end
				S_R14: begin	
						state <= S_R15;
				end
				S_R15: begin	
						rx_state <= tx_hash;
						rx_input <= { 256'h0000030000000000000000000000000000000000000000000000000080000000, ihash };
						state <= S_R16;
				end
				S_R16: begin	
					cnt <= cnt + 6'd1;
					if (cnt == 6'd63)
					begin
						cnt <= 6'd0;
						state <= S_R17;
					end
				end
				S_R17: begin	
						state <= S_R18;
				end
				S_R18: begin	
						`ifdef SIM
							final_hash <= tx_hash;		
						`endif
						if ( { tx_hash[231:224], tx_hash[239:232], tx_hash[247:240], tx_hash[255:248] } < target)
						begin
							golden_nonce <= nonce_sr;
							golden_nonce_match <= 1'b1;	
						end
						state <= S_IDLE;
						mode <= 1'b0;
						Clr_SMixOutRdy <= 1'b1;	
				end
			endcase	
		end
	end
	reg	[10:0]shift_count = 11'd0;	
	always @ (posedge hash_clk)
	begin
		if (reset)
		begin
			salsa_shift <= 1'b0;
			shift_count <= 11'd0;
		end
		Xbuf_load_request[3:1] <= Xbuf_load_request[2:0];
		if (Xbuf_load_request[3] != Xbuf_load_request[2])
		begin
			Xbuf[255:0] <= Xbuf[511:256];
			Xbuf[511:256] <= Xbuf[767:512];
			Xbuf[767:512] <= Xbuf[1023:768];
			Xbuf[1023:768] <= khash;
			nonce_sr <= nonce;	
		end
		shift_request[3:1] <= shift_request[2:0];
		if (shift_request[3] != shift_request[2])
		begin
			salsa_shift <= 1'b1;
		end
		if (salsa_shift)
		begin
			shift_count <= shift_count + 1'b1;
			Xbuf <= { Xbuf[1022:0], nonce_sr[31] };
			nonce_sr <= { nonce_sr[30:0], salsa_dout };
		end
		if (shift_count == 1024+32-1)
		begin
			shift_acknowledge[0] = ~shift_acknowledge[0];
			shift_count <= 0;
			salsa_shift <= 0;
		end
	end
	sha256_transform  # (.LOOP(64)) sha256_blk (
		.clk(pbkdf_clk),
		.feedback(feedback),
		.cnt(cnt),
		.rx_state(rx_state),
		.rx_input(rx_input),
		.tx_hash(tx_hash)
	);
endmodule
