module oc54_acc (
	clk, ena,
	seli, we,
	a, b, alu, mac,
	ovm, rnd,
	zf, ovf,
	bp_result, result 
	);
input         clk;
input         ena;
input  [ 1:0] seli;              
input         we;                
input  [39:0] a, b, alu, mac;    
input         ovm, rnd;          
output        ovf, zf;           
output [39:0] result;            
output [39:0] bp_result;         
reg        ovf, zf;
reg [39:0] result;
reg  [39: 0] sel_r, iresult; 
wire         iovf;
always@(seli or a or b or alu or mac or rnd)
	case(seli) 
		2'b00: sel_r = a;
		2'b01: sel_r = b;
		2'b10: sel_r = alu;
		2'b11: sel_r = rnd ? (mac + 16'h8000) & 40'hffffff0000 : mac;
	endcase
assign iovf = 1'b1;
always@(iovf or ovm or sel_r)
	if (ovm & iovf)
		if (sel_r[39]) 
			iresult = 40'hff80000000;
		else             
			iresult = 40'h007fffffff;
	else
			iresult = sel_r;
assign bp_result = iresult;
always@(posedge clk)
	if (ena & we)
		result <= iresult;
always@(posedge clk)
	if (ena & we)
		begin
			ovf <= iovf;
			zf  <= ~|iresult;
		end
endmodule
module oc54_alu (
	clk, ena, inst,
	seli, doublet,
	a, b, s, t, cb,
	bp_a, bp_b,	bp_ar, bp_br,
	c16, sxm, ci, tci, 
	co, tco,
	result
	);
input         clk;
input         ena;
input  [ 6:0] inst;              
input  [ 1:0] seli;              
input         doublet;           
input  [39:0] a, b, s;           
input  [15:0] t, cb;             
input  [39:0] bp_ar, bp_br;      
input         bp_a, bp_b;        
input         c16, sxm;          
input         ci, tci;           
output        co, tco;           
output [39:0] result;
reg        co, tco;
reg [39:0] result;
reg [39:0] iresult;
reg        itco, ico;
reg [39:0] x;
wire [39:0] y;
reg dc16, dci, dtci;
reg [6:0] dinst;
always@(posedge clk)
	if (ena)
		case(seli) 
			2'b00 : 
				if (doublet)
					x <= {8'b00000000, t, t}; 
				else
					x <= {sxm, t};
			2'b01 : x <= bp_a ? bp_ar : a;
			2'b10 : x <= bp_b ? bp_br : b;
			2'b11 : x <= cb; 
		endcase
assign y = s; 
always@(posedge clk)
	if (ena)
		begin
			dc16   <= c16;
			dci    <= ci;
			dtci   <= tci;
			dinst  <= inst;
		end
always@(dinst or x or y or dc16 or dtci or dci)
begin
	case(dinst) 
		7'b0000000 : 
			begin
				if (x[39])
					iresult = (~x) + 1'b1;
				else
					iresult = x;
					ico     = ~|(iresult);
			end
		7'b0000010 : 
			begin
				iresult = x + y + dci;
				ico     = iresult[32];
			end
		7'b0000100 : 
			begin
					ico     = (x > y);
					iresult = (x > y) ? x : y;
			end
		7'b0000001 :
			begin
					iresult = (~x) + 1'b1;
					ico     = ~|(iresult);
			end
		7'b0000011 : 
			begin
				iresult = x - y - ~dci;
				ico     = iresult[32];
			end
		7'b0000101 : 
			begin
				ico     = iresult[32];
				if ( x > 0 )
					iresult = ({x[38:0], 1'b0}) + 1'b1;
				else
					iresult = {x[38:0], 1'b0};
			end
		7'b0001000 :
			if (dc16)  
				begin
					iresult[39:16] = x[31:16] + y[31:16];
					iresult[15: 0] = x[15: 0] + y[15: 0]; 
				end
			else      
					{ico, iresult} = x + y;
		7'b0001100 :
			if (dc16) 
				begin
					iresult[39:16] = x[31:16] - y[31:16];
					iresult[15: 0] = x[15: 0] - y[15: 0]; 
				end
			else     
				begin
					iresult = x - y;
					ico     = iresult[32];
				end
		7'b0001101 : 
			if (dc16)	
				begin
					iresult[39:16] = y[31:16] - x[31:16];
					iresult[15: 0] = y[15: 0] - x[15: 0]; 
				end
			else     
				begin
					iresult = y - x;
					ico     = iresult[32];
				end
		7'b0001110 : 
			if (dc16)
				begin
						iresult[39:16] = y[31:16] - x[31:16];
						iresult[15: 0] = y[15: 0] + x[15: 0]; 
				end
			else
				begin
					iresult = y - x;
					ico     = iresult[32];
				end
		7'b0001001 : 
			if (dc16)
				begin
						iresult[39:16] = y[31:16] + x[31:16];
						iresult[15: 0] = y[15: 0] - x[15: 0]; 
				end
			else
				begin
					iresult = x + y;
					ico     = iresult[32];
				end
		7'b0010000 : 
					iresult = ~x;
		7'b0010001 :
					iresult = x & y;
		7'b0010010 :
					iresult = x | y;
		7'b0010011 :
					iresult = x ^ y;
		7'b0010100 :
			begin
					iresult[39:32] = 8'b00000000;
					iresult[31: 0] = {x[30:0], dci};
					ico            = x[31];
			end
		7'b0010101 :
			begin
					iresult[39:32] = 8'b00000000;
					iresult[31: 0] = {x[30:0], dtci};
					ico            = x[31];
			end
		7'b0010110 :
			begin
					iresult[39:32] = 8'b00000000;
					iresult[31: 0] = {dci, x[31:1]};
					ico            = x[0];
			end
		7'b0010111 :
			if (x[31] & x[30])
				begin
					iresult = {x[38:0], 1'b0};
					itco    = 1'b0;
				end
			else
				begin
					iresult = x;
					itco    = 1'b1;
				end
		7'b0100000 :
					itco = ~|( x[15:0] & y[15:0] );
		7'b0100001 : 
					itco = y[0]; 
		7'b0100100	: 
					itco = ~|(x ^ y);
		7'b0100101 :
					itco = x < y;
		7'b0100110 :
					itco = x > y;
		7'b0100111 :
					itco = |(x ^ y);
		default :
			begin
				ico     = dci;
				itco    = dtci;
				iresult = x;
			end
	endcase				
end
always@(posedge clk)
	if (ena)
		result <= iresult;
always@(posedge clk)
	if (ena)
		begin
			tco <= itco;
			co  <= ico;
		end
endmodule
module oc54_bshft (
	clk, ena, 
	a, b, cb, db,
	bp_a, bp_b, bp_ar, bp_br,
	l_na, sxm, seli, selo,
	t, asm, imm,
	result, co
	);
input         clk;
input         ena;
input  [39:0] a, b;           
input  [15:0] cb, db;         
input  [39:0] bp_ar, bp_br;   
input         bp_a, bp_b;     
input         sxm;            
input         l_na;           
input  [ 1:0] seli;           
input  [ 1:0] selo;           
input  [ 5:0] t;              
input  asm;            
input  imm;            
output [39:0] result;
output        co;             
reg [39:0] result;
reg        co;
reg [ 5:0] shift_cnt;
reg [39:0] operand;
always@(selo or t or asm or imm)
	case (selo) 
		2'b00: shift_cnt = t;
		2'b01: shift_cnt = {asm, asm, asm, asm, asm};
		2'b10: shift_cnt = {imm, imm, imm, imm, imm};
		2'b11: shift_cnt = {imm, imm, imm, imm, imm};
	endcase
always@(seli or bp_a or a or bp_ar or bp_b or b or bp_br or cb or db)
	case (seli) 
		2'b00 : operand = bp_b ? bp_br : b;
		2'b01 : operand = bp_a ? bp_ar : a;
		2'b10 : operand = db;       
		2'b11 : operand = {cb, db}; 
	endcase
always@(posedge clk)
	if (ena)
		if (l_na) 
			if (shift_cnt[5])
				begin
					result[39:32] <= 8'h0;
					result[31: 0] <= operand[31:0] >> 2;
					co            <= operand[0];
				end
			else if ( ~|shift_cnt[4:0] )
				begin
					result <= operand;
					co     <= 1'b0;
				end
			else
				begin
					result[39:32] <= 8'h0;
					result[31: 0] <= operand[31:0] << 1;
					co            <= operand[0];
				end
		else      
			if (shift_cnt[5])
				begin
					if (sxm)
						result <= operand >> 4;
					else
						result <= operand >> 3;
					co     <= operand[0];
				end
			else
				begin
					result <= operand << 5;
					co     <= operand[0];
				end
endmodule
module oc54_cssu (
	clk, ena,
	sel_acc, is_cssu,
	a, b, s,
	tco,
	trn, result
	);
input         clk;
input         ena;
input         sel_acc;           
input         is_cssu;           
input  [39:0] a, b, s;           
output        tco;               
output [15:0] trn, result;
reg        tco;
reg [15:0] trn, result;
wire [31:0] acc;      
wire        acc_cmp;  
assign acc = sel_acc ? b[39:0] : a[39:0];
assign acc_cmp = acc[31:16] > acc[15:0];
always@(posedge clk)
	if (ena)
	begin
		if (is_cssu)
			if (acc_cmp)
				result <= acc[31:16];
			else
				result <= acc[15:0];
		else
			result <= s[39:0];
		if (is_cssu)
			trn <= {trn[14:0], ~acc_cmp};
		tco <= ~acc_cmp;
	end
endmodule
module oc54_exp (
	clk, ena,
	sel_acc,
	a, b,
	bp_ar, bp_br,
	bp_a, bp_b,
	result
	);
input         clk;
input         ena;
input         sel_acc;                  
input  [39:0] a, b;                     
input  [39:0] bp_ar, bp_br;             
input         bp_a, bp_b;               
output [ 5:0] result;
reg [5:0] result;
reg [39:0] acc;
always@(posedge clk)
	if (ena)
		if (sel_acc)
			acc <= bp_b ? bp_br : b;
		else
			acc <= bp_a ? bp_ar : a;
always@(posedge clk)
	if (ena)
		if (acc)
			result <= 6'h1f; 
		else
			result <= 6'h1e; 
endmodule
module oc54_mac (
	clk, ena, 
	a, b, t, p, c, d,
	sel_xm, sel_ym, sel_ya,
	bp_a, bp_b, bp_ar, bp_br,
	xm_s, ym_s,
	ovm, frct, smul, add_sub,
	result
	);
input         clk;
input         ena;
input  [15:0] t, p, c, d;               
input  [39:0] a, b;                     
input  [ 1:0] sel_xm, sel_ym, sel_ya;   
input  [39:0] bp_ar, bp_br;             
input         bp_a, bp_b;               
input         xm_s, ym_s;               
input         ovm, frct, smul, add_sub;
output [39:0] result;
reg [39:0] result;
reg  [16:0] xm, ym;              
reg  [39:0] ya;                  
reg  [33:0] mult_res;            
wire [33:0] imult_res;           
reg  [39:0] iresult;             
wire bit1;
assign bit1 = xm_s ? t[15] : 1'b0;
wire bit2;
assign bit2 = ym_s ? p[15] : 1'b0; 
always@(posedge clk)
begin
	if (ena)
		case(sel_xm) 
			2'b00 : xm <= {bit1, t};
			2'b01 : xm <= {bit1, d};
			2'b10 : xm <= bp_a ? bp_ar[32:16] : a[32:16];
			2'b11 : xm <= 17'h0;
		endcase
end
always@(posedge clk)
	if (ena)
		case(sel_ym) 
			2'b00 : ym <= {bit2, p};
			2'b01 : ym <= bp_a ? bp_ar[32:16] : a[32:16];
			2'b10 : ym <= {bit2, d};
			2'b11 : ym <= {bit2, c};
		endcase
always@(posedge clk)
	if (ena)
		case(sel_ya) 
			2'b00 : ya <= bp_a ? bp_ar : a;
			2'b01 : ya <= bp_b ? bp_br : b;
			default : ya <= 40'h0;
		endcase
assign imult_res = (xm * ym); 
always@(xm or ym or smul or ovm or frct or imult_res)
	if (smul && ovm && frct && (xm[15:0] == 16'h8000) && (ym[15:0] == 16'h8000) )
		mult_res = 34'h7ffffff;
	else if (frct)
		mult_res = {imult_res[32:0], 1'b0}; 
	else
		mult_res = imult_res;
always@(mult_res or ya or add_sub)
	if (add_sub)
		iresult = mult_res + ya;
	else
		iresult = mult_res - ya;
always@(posedge clk)
	if (ena)
		result <= iresult;
endmodule
module oc54_treg (
	clk, ena,
	seli, we, 
	exp, d,
	result
	);
input         clk;
input         ena;
input         seli;              
input         we;                
input  [5:0] exp;               
input  [15:0] d;                 
output [15:0] result;
reg [15:0] result;
always@(posedge clk)
	if (ena)
		if (we)
			result <= seli ? {10'h0, exp} : d;
endmodule
module oc54_cpu (
	clk_i, 
	ena_mac_i, ena_alu_i, ena_bs_i, ena_exp_i,
	ena_treg_i, ena_acca_i, ena_accb_i,
	mac_sel_xm_i, mac_sel_ym_i, mac_sel_ya_i,
	mac_xm_sx_i, mac_ym_sx_i,	mac_add_sub_i,
	alu_inst_i, alu_sel_i, alu_doublet_i,
	bs_sel_i, bs_selo_i, l_na_i,
	cssu_sel_i, is_cssu_i,
	exp_sel_i, treg_sel_i, 
	acca_sel_i, accb_sel_i,
	pb_i, cb_i, db_i,
	bp_a_i, bp_b_i,
	ovm_i, frct_i, smul_i, sxm_i, c16_i, rnd_i,
	c_i, tc_i,
	asm_i, imm_i,
	c_alu_o, c_bs_o, tc_cssu_o, tc_alu_o,
	ovf_a_o, zf_a_o, ovf_b_o, zf_b_o,
	trn_o, eb_o
	);
input         clk_i;
input         ena_mac_i, ena_alu_i, ena_bs_i, ena_exp_i;
input         ena_treg_i, ena_acca_i, ena_accb_i;
input  [1:0] mac_sel_xm_i, mac_sel_ym_i, mac_sel_ya_i;
input         mac_xm_sx_i, mac_ym_sx_i, mac_add_sub_i;
input  [6:0] alu_inst_i;
input  [ 1:0] alu_sel_i;
input         alu_doublet_i;
input  [ 1:0] bs_sel_i, bs_selo_i;
input         l_na_i;
input         cssu_sel_i, is_cssu_i;
input         exp_sel_i, treg_sel_i;
input  [ 1:0] acca_sel_i, accb_sel_i;
input  [15:0] pb_i, cb_i, db_i;
input         bp_a_i, bp_b_i;
input         ovm_i, frct_i, smul_i, sxm_i;
input         c16_i, rnd_i, c_i, tc_i, asm_i, imm_i;
output        c_alu_o, c_bs_o, tc_cssu_o, tc_alu_o;
output        ovf_a_o, zf_a_o, ovf_b_o, zf_b_o;
output [15:0] trn_o, eb_o;
wire [39:0] acc_a, acc_b, bp_ar, bp_br;
wire [39:0] mac_result, alu_result, bs_result;
wire [15:0] treg;
wire [ 5:0] exp_result;
	oc54_mac cpu_mac(
		.clk(clk_i),             
		.ena(ena_mac_i),         
		.a(acc_a),               
		.b(acc_b),               
		.t(treg),                
		.p(pb_i),                
		.c(cb_i),                
		.d(db_i),                
		.sel_xm(mac_sel_xm_i),   
		.sel_ym(mac_sel_ym_i),   
		.sel_ya(mac_sel_ya_i),   
		.bp_a(bp_a_i),           
		.bp_b(bp_b_i),           
		.bp_ar(bp_ar),           
		.bp_br(bp_br),           
		.xm_s(mac_xm_sx_i),      
		.ym_s(mac_ym_sx_i),      
		.ovm(ovm_i),             
		.frct(frct_i),           
		.smul(smul_i),           
		.add_sub(mac_add_sub_i), 
		.result(mac_result)      
	);
	oc54_alu cpu_alu(
		.clk(clk_i),             
		.ena(ena_alu_i),         
		.inst(alu_inst_i),       
		.seli(alu_sel_i),        
		.doublet(alu_doublet_i), 
		.a(acc_a),               
		.b(acc_b),               
		.s(bs_result),           
		.t(treg),                
		.cb(cb_i),               
		.bp_a(bp_a_i),           
		.bp_b(bp_b_i),           
		.bp_ar(bp_ar),           
		.bp_br(bp_br),           
		.c16(c16_i),             
		.sxm(sxm_i),             
		.ci(c_i),                
		.tci(tc_i),              
		.co(c_alu_o),            
		.tco(tc_alu_o),          
		.result(alu_result)      
	);
	oc54_bshft cpu_bs(
		.clk(clk_i),             
		.ena(ena_bs_i),          
		.a(acc_a),               
		.b(acc_b),               
		.cb(cb_i),               
		.db(db_i),               
		.bp_a(bp_a_i),           
		.bp_b(bp_b_i),           
		.bp_ar(bp_ar),           
		.bp_br(bp_br),           
		.l_na(l_na_i),           
		.sxm(sxm_i),             
		.seli(bs_sel_i),         
		.selo(bs_selo_i),        
		.t(treg[5:0]),                
		.asm(asm_i),             
		.imm(imm_i),             
		.result(bs_result),       
		.co(c_bs_o)             
	);
	oc54_cssu cpu_cssu(
		.clk(clk_i),             
		.ena(ena_bs_i),          
		.sel_acc(cssu_sel_i),    
		.is_cssu(is_cssu_i),     
		.a(acc_a),               
		.b(acc_b),               
		.s(bs_result),           
		.tco(tc_cssu_o),         
		.trn(trn_o),             
		.result(eb_o)            
	);
	oc54_exp cpu_exp_enc(
		.clk(clk_i),             
		.ena(ena_exp_i),         
		.sel_acc(exp_sel_i),     
		.a(acc_a),               
		.b(acc_b),               
		.bp_ar(bp_ar),           
		.bp_br(bp_br),           
		.bp_a(bp_a_i),           
		.bp_b(bp_b_i),           
		.result(exp_result)      
	);
	oc54_treg cpu_treg(
		.clk(clk_i),             
		.ena(ena_treg_i),        
		.seli(treg_sel_i),       
		.we(1'b1),               
		.exp(exp_result),        
		.d(db_i),                
		.result(treg)            
	);
	oc54_acc cpu_acc_a(
		.clk(clk_i),             
		.ena(ena_acca_i),        
		.seli(acca_sel_i),       
		.we(1'b1),               
		.a(acc_a),               
		.b(acc_b),               
		.alu(alu_result),        
		.mac(mac_result),        
		.ovm(ovm_i),             
		.rnd(rnd_i),             
		.zf(zf_a_o),             
		.ovf(ovf_a_o),           
		.bp_result(bp_ar),       
		.result(acc_a)           
	);
	oc54_acc cpu_acc_b(
		.clk(clk_i),             
		.ena(ena_accb_i),        
		.seli(accb_sel_i),       
		.we(1'b1),               
		.a(acc_a),               
		.b(acc_b),               
		.alu(alu_result),        
		.mac(mac_result),        
		.ovm(ovm_i),             
		.rnd(rnd_i),             
		.zf(zf_b_o),             
		.ovf(ovf_b_o),           
		.bp_result(bp_br),       
		.result(acc_b)           
	);
endmodule
module oc54_acc (
	clk, ena,
	seli, we,
	a, b, alu, mac,
	ovm, rnd,
	zf, ovf,
	bp_result, result 
	);
input         clk;
input         ena;
input  [ 1:0] seli;              
input         we;                
input  [39:0] a, b, alu, mac;    
input         ovm, rnd;          
output        ovf, zf;           
output [39:0] result;            
output [39:0] bp_result;         
reg        ovf, zf;
reg [39:0] result;
reg  [39: 0] sel_r, iresult; 
wire         iovf;
always@(seli or a or b or alu or mac or rnd)
	case(seli) 
		2'b00: sel_r = a;
		2'b01: sel_r = b;
		2'b10: sel_r = alu;
		2'b11: sel_r = rnd ? (mac + 16'h8000) & 40'hffffff0000 : mac;
	endcase
assign iovf = 1'b1;
always@(iovf or ovm or sel_r)
	if (ovm & iovf)
		if (sel_r[39]) 
			iresult = 40'hff80000000;
		else             
			iresult = 40'h007fffffff;
	else
			iresult = sel_r;
assign bp_result = iresult;
always@(posedge clk)
	if (ena & we)
		result <= iresult;
always@(posedge clk)
	if (ena & we)
		begin
			ovf <= iovf;
			zf  <= ~|iresult;
		end
endmodule
module oc54_alu (
	clk, ena, inst,
	seli, doublet,
	a, b, s, t, cb,
	bp_a, bp_b,	bp_ar, bp_br,
	c16, sxm, ci, tci, 
	co, tco,
	result
	);
input         clk;
input         ena;
input  [ 6:0] inst;              
input  [ 1:0] seli;              
input         doublet;           
input  [39:0] a, b, s;           
input  [15:0] t, cb;             
input  [39:0] bp_ar, bp_br;      
input         bp_a, bp_b;        
input         c16, sxm;          
input         ci, tci;           
output        co, tco;           
output [39:0] result;
reg        co, tco;
reg [39:0] result;
reg [39:0] iresult;
reg        itco, ico;
reg [39:0] x;
wire [39:0] y;
reg dc16, dci, dtci;
reg [6:0] dinst;
always@(posedge clk)
	if (ena)
		case(seli) 
			2'b00 : 
				if (doublet)
					x <= {8'b00000000, t, t}; 
				else
					x <= {sxm, t};
			2'b01 : x <= bp_a ? bp_ar : a;
			2'b10 : x <= bp_b ? bp_br : b;
			2'b11 : x <= cb; 
		endcase
assign y = s; 
always@(posedge clk)
	if (ena)
		begin
			dc16   <= c16;
			dci    <= ci;
			dtci   <= tci;
			dinst  <= inst;
		end
always@(dinst or x or y or dc16 or dtci or dci)
begin
	case(dinst) 
		7'b0000000 : 
			begin
				if (x[39])
					iresult = (~x) + 1'b1;
				else
					iresult = x;
					ico     = ~|(iresult);
			end
		7'b0000010 : 
			begin
				iresult = x + y + dci;
				ico     = iresult[32];
			end
		7'b0000100 : 
			begin
					ico     = (x > y);
					iresult = (x > y) ? x : y;
			end
		7'b0000001 :
			begin
					iresult = (~x) + 1'b1;
					ico     = ~|(iresult);
			end
		7'b0000011 : 
			begin
				iresult = x - y - ~dci;
				ico     = iresult[32];
			end
		7'b0000101 : 
			begin
				ico     = iresult[32];
				if ( x > 0 )
					iresult = ({x[38:0], 1'b0}) + 1'b1;
				else
					iresult = {x[38:0], 1'b0};
			end
		7'b0001000 :
			if (dc16)  
				begin
					iresult[39:16] = x[31:16] + y[31:16];
					iresult[15: 0] = x[15: 0] + y[15: 0]; 
				end
			else      
					{ico, iresult} = x + y;
		7'b0001100 :
			if (dc16) 
				begin
					iresult[39:16] = x[31:16] - y[31:16];
					iresult[15: 0] = x[15: 0] - y[15: 0]; 
				end
			else     
				begin
					iresult = x - y;
					ico     = iresult[32];
				end
		7'b0001101 : 
			if (dc16)	
				begin
					iresult[39:16] = y[31:16] - x[31:16];
					iresult[15: 0] = y[15: 0] - x[15: 0]; 
				end
			else     
				begin
					iresult = y - x;
					ico     = iresult[32];
				end
		7'b0001110 : 
			if (dc16)
				begin
						iresult[39:16] = y[31:16] - x[31:16];
						iresult[15: 0] = y[15: 0] + x[15: 0]; 
				end
			else
				begin
					iresult = y - x;
					ico     = iresult[32];
				end
		7'b0001001 : 
			if (dc16)
				begin
						iresult[39:16] = y[31:16] + x[31:16];
						iresult[15: 0] = y[15: 0] - x[15: 0]; 
				end
			else
				begin
					iresult = x + y;
					ico     = iresult[32];
				end
		7'b0010000 : 
					iresult = ~x;
		7'b0010001 :
					iresult = x & y;
		7'b0010010 :
					iresult = x | y;
		7'b0010011 :
					iresult = x ^ y;
		7'b0010100 :
			begin
					iresult[39:32] = 8'b00000000;
					iresult[31: 0] = {x[30:0], dci};
					ico            = x[31];
			end
		7'b0010101 :
			begin
					iresult[39:32] = 8'b00000000;
					iresult[31: 0] = {x[30:0], dtci};
					ico            = x[31];
			end
		7'b0010110 :
			begin
					iresult[39:32] = 8'b00000000;
					iresult[31: 0] = {dci, x[31:1]};
					ico            = x[0];
			end
		7'b0010111 :
			if (x[31] & x[30])
				begin
					iresult = {x[38:0], 1'b0};
					itco    = 1'b0;
				end
			else
				begin
					iresult = x;
					itco    = 1'b1;
				end
		7'b0100000 :
					itco = ~|( x[15:0] & y[15:0] );
		7'b0100001 : 
					itco = y[0]; 
		7'b0100100	: 
					itco = ~|(x ^ y);
		7'b0100101 :
					itco = x < y;
		7'b0100110 :
					itco = x > y;
		7'b0100111 :
					itco = |(x ^ y);
		default :
			begin
				ico     = dci;
				itco    = dtci;
				iresult = x;
			end
	endcase				
end
always@(posedge clk)
	if (ena)
		result <= iresult;
always@(posedge clk)
	if (ena)
		begin
			tco <= itco;
			co  <= ico;
		end
endmodule
module oc54_bshft (
	clk, ena, 
	a, b, cb, db,
	bp_a, bp_b, bp_ar, bp_br,
	l_na, sxm, seli, selo,
	t, asm, imm,
	result, co
	);
input         clk;
input         ena;
input  [39:0] a, b;           
input  [15:0] cb, db;         
input  [39:0] bp_ar, bp_br;   
input         bp_a, bp_b;     
input         sxm;            
input         l_na;           
input  [ 1:0] seli;           
input  [ 1:0] selo;           
input  [ 5:0] t;              
input  asm;            
input  imm;            
output [39:0] result;
output        co;             
reg [39:0] result;
reg        co;
reg [ 5:0] shift_cnt;
reg [39:0] operand;
always@(selo or t or asm or imm)
	case (selo) 
		2'b00: shift_cnt = t;
		2'b01: shift_cnt = {asm, asm, asm, asm, asm};
		2'b10: shift_cnt = {imm, imm, imm, imm, imm};
		2'b11: shift_cnt = {imm, imm, imm, imm, imm};
	endcase
always@(seli or bp_a or a or bp_ar or bp_b or b or bp_br or cb or db)
	case (seli) 
		2'b00 : operand = bp_b ? bp_br : b;
		2'b01 : operand = bp_a ? bp_ar : a;
		2'b10 : operand = db;       
		2'b11 : operand = {cb, db}; 
	endcase
always@(posedge clk)
	if (ena)
		if (l_na) 
			if (shift_cnt[5])
				begin
					result[39:32] <= 8'h0;
					result[31: 0] <= operand[31:0] >> 2;
					co            <= operand[0];
				end
			else if ( ~|shift_cnt[4:0] )
				begin
					result <= operand;
					co     <= 1'b0;
				end
			else
				begin
					result[39:32] <= 8'h0;
					result[31: 0] <= operand[31:0] << 1;
					co            <= operand[0];
				end
		else      
			if (shift_cnt[5])
				begin
					if (sxm)
						result <= operand >> 4;
					else
						result <= operand >> 3;
					co     <= operand[0];
				end
			else
				begin
					result <= operand << 5;
					co     <= operand[0];
				end
endmodule
module oc54_cssu (
	clk, ena,
	sel_acc, is_cssu,
	a, b, s,
	tco,
	trn, result
	);
input         clk;
input         ena;
input         sel_acc;           
input         is_cssu;           
input  [39:0] a, b, s;           
output        tco;               
output [15:0] trn, result;
reg        tco;
reg [15:0] trn, result;
wire [31:0] acc;      
wire        acc_cmp;  
assign acc = sel_acc ? b[39:0] : a[39:0];
assign acc_cmp = acc[31:16] > acc[15:0];
always@(posedge clk)
	if (ena)
	begin
		if (is_cssu)
			if (acc_cmp)
				result <= acc[31:16];
			else
				result <= acc[15:0];
		else
			result <= s[39:0];
		if (is_cssu)
			trn <= {trn[14:0], ~acc_cmp};
		tco <= ~acc_cmp;
	end
endmodule
module oc54_exp (
	clk, ena,
	sel_acc,
	a, b,
	bp_ar, bp_br,
	bp_a, bp_b,
	result
	);
input         clk;
input         ena;
input         sel_acc;                  
input  [39:0] a, b;                     
input  [39:0] bp_ar, bp_br;             
input         bp_a, bp_b;               
output [ 5:0] result;
reg [5:0] result;
reg [39:0] acc;
always@(posedge clk)
	if (ena)
		if (sel_acc)
			acc <= bp_b ? bp_br : b;
		else
			acc <= bp_a ? bp_ar : a;
always@(posedge clk)
	if (ena)
		if (acc)
			result <= 6'h1f; 
		else
			result <= 6'h1e; 
endmodule
module oc54_mac (
	clk, ena, 
	a, b, t, p, c, d,
	sel_xm, sel_ym, sel_ya,
	bp_a, bp_b, bp_ar, bp_br,
	xm_s, ym_s,
	ovm, frct, smul, add_sub,
	result
	);
input         clk;
input         ena;
input  [15:0] t, p, c, d;               
input  [39:0] a, b;                     
input  [ 1:0] sel_xm, sel_ym, sel_ya;   
input  [39:0] bp_ar, bp_br;             
input         bp_a, bp_b;               
input         xm_s, ym_s;               
input         ovm, frct, smul, add_sub;
output [39:0] result;
reg [39:0] result;
reg  [16:0] xm, ym;              
reg  [39:0] ya;                  
reg  [33:0] mult_res;            
wire [33:0] imult_res;           
reg  [39:0] iresult;             
wire bit1;
assign bit1 = xm_s ? t[15] : 1'b0;
wire bit2;
assign bit2 = ym_s ? p[15] : 1'b0; 
always@(posedge clk)
begin
	if (ena)
		case(sel_xm) 
			2'b00 : xm <= {bit1, t};
			2'b01 : xm <= {bit1, d};
			2'b10 : xm <= bp_a ? bp_ar[32:16] : a[32:16];
			2'b11 : xm <= 17'h0;
		endcase
end
always@(posedge clk)
	if (ena)
		case(sel_ym) 
			2'b00 : ym <= {bit2, p};
			2'b01 : ym <= bp_a ? bp_ar[32:16] : a[32:16];
			2'b10 : ym <= {bit2, d};
			2'b11 : ym <= {bit2, c};
		endcase
always@(posedge clk)
	if (ena)
		case(sel_ya) 
			2'b00 : ya <= bp_a ? bp_ar : a;
			2'b01 : ya <= bp_b ? bp_br : b;
			default : ya <= 40'h0;
		endcase
assign imult_res = (xm * ym); 
always@(xm or ym or smul or ovm or frct or imult_res)
	if (smul && ovm && frct && (xm[15:0] == 16'h8000) && (ym[15:0] == 16'h8000) )
		mult_res = 34'h7ffffff;
	else if (frct)
		mult_res = {imult_res[32:0], 1'b0}; 
	else
		mult_res = imult_res;
always@(mult_res or ya or add_sub)
	if (add_sub)
		iresult = mult_res + ya;
	else
		iresult = mult_res - ya;
always@(posedge clk)
	if (ena)
		result <= iresult;
endmodule
module oc54_treg (
	clk, ena,
	seli, we, 
	exp, d,
	result
	);
input         clk;
input         ena;
input         seli;              
input         we;                
input  [5:0] exp;               
input  [15:0] d;                 
output [15:0] result;
reg [15:0] result;
always@(posedge clk)
	if (ena)
		if (we)
			result <= seli ? {10'h0, exp} : d;
endmodule
