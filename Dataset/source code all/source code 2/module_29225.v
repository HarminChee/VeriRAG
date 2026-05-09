`define SALU_SOPP_FORMAT 8'h01
`define SALU_SOP1_FORMAT 8'h02
`define SALU_SOPC_FORMAT 8'h04
`define SALU_SOP2_FORMAT 8'h08
`define SALU_SOPK_FORMAT 8'h10
`define SALU_SOPP_FORMAT 8'h01
`define SALU_SOP1_FORMAT 8'h02
`define SALU_SOPC_FORMAT 8'h04
`define SALU_SOP2_FORMAT 8'h08
`define SALU_SOPK_FORMAT 8'h10
module salu_controller(
	control_en,
	dst_reg,
	opcode,
	alu_control,
	branch_on_cc,
	exec_en,
	vcc_en,
	scc_en,
	m0_en,
	sgpr_en,
	vcc_wordsel,
	exec_wordsel,
	exec_sgpr_cpy,
	snd_src_imm,
	bit64_op,
	rst,
        clk,
        salu2sgpr_req,
        rfa2salu_req_hold,
        control_en_fw,
        dst_reg_fw
);
input rfa2salu_req_hold;
input clk;
input control_en_fw;
input [11:0] dst_reg_fw;
output salu2sgpr_req;
input [11:0] dst_reg;
input [31:0] opcode;
input control_en, rst;
output exec_en, vcc_en, scc_en, m0_en, exec_sgpr_cpy,
		snd_src_imm, bit64_op;
output [1:0] vcc_wordsel, exec_wordsel, sgpr_en;
output [5:0] branch_on_cc;
output [31:0] alu_control;
reg exec_en_dreg, vcc_en, scc_en, m0_en, exec_sgpr_cpy,
	snd_src_imm, bit64_op;
reg [1:0] vcc_ws_dreg, exec_ws_dreg, vcc_ws_op, exec_ws_op, sgpr_en;
reg [5:0] branch_on_cc;
reg [31:0] alu_control;
reg salu2sgpr_req;
reg salu2sgpr_req_trig;
wire sgpr_fw_check;
assign sgpr_fw_check = {control_en_fw, dst_reg_fw[11:9]} && 4'b1110;
always@ (control_en or dst_reg or bit64_op or clk or rst) begin
        if(~control_en | rst ) begin
              salu2sgpr_req <= 1'b0; 
           end
        else
        if(salu2sgpr_req_trig | sgpr_fw_check) begin
              salu2sgpr_req <= 1'b1; 
        end
        else
        begin
              salu2sgpr_req <= salu2sgpr_req;
        end
   end
always@ (control_en or opcode or rst) begin
	if(~control_en | rst) begin
		alu_control <= 'd0;
		scc_en <= 1'b0;
		vcc_ws_op <= 2'b00;
		exec_ws_op <= 2'b00;
		exec_sgpr_cpy <= 1'b0;
		branch_on_cc <= 6'b000000;
		snd_src_imm <= 1'b0;
		bit64_op <= 1'b0;
	end
	else if(control_en) begin
		scc_en <= 1'b0;
		alu_control <= opcode;
		bit64_op <= 1'b0;
		exec_sgpr_cpy <= 1'b0;
		snd_src_imm <= 1'b0;
		branch_on_cc <= 6'b000000;
		vcc_ws_op <= 2'b00;
		exec_ws_op <= 2'b00;
		casex(opcode[31:24])
			{`SALU_SOPP_FORMAT} : begin
				snd_src_imm <= 1'b1;
				casex(opcode[23:0])
					24'h000002 : begin branch_on_cc <= 6'b111111; end
					24'h000004 : begin branch_on_cc <= 6'b000001; end
					24'h000005 : begin branch_on_cc <= 6'b000010; end
					24'h000006 : begin branch_on_cc <= 6'b000100; end
					24'h000007 : begin branch_on_cc <= 6'b001000; end
					24'h000008 : begin branch_on_cc <= 6'b010000; end
					24'h000009 : begin branch_on_cc <= 6'b100000; end
				endcase
			end
			{`SALU_SOP1_FORMAT} : begin
				casex(opcode[23:0])
					24'h000004 : begin
						bit64_op <= 1'b1;
					end
					24'h000007 : begin
						scc_en <= 1'b1;
					end
					24'h000024 : begin
						scc_en <= 1'b1;
						exec_ws_op <= 2'b11;
						exec_sgpr_cpy <= 1'b1;
						bit64_op <= 1'b1;
					end
				endcase
			end
			{`SALU_SOP2_FORMAT} : begin
				casex(opcode[23:0])
					24'h000000 : begin
						scc_en <= 1'b1;
					end
					24'h000001 : begin
						scc_en <= 1'b1;
					end
					24'h000002 : begin
						scc_en <= 1'b1;
					end
					24'h000003 : begin
						scc_en <= 1'b1;
					end
					24'h000007 : begin
						scc_en <= 1'b1;
					end
					24'h000009 : begin
						scc_en <= 1'b1;
					end
					24'h000008 : begin
						scc_en <= 1'b1;
					end
					24'h00000E : begin
						scc_en <= 1'b1;
					end
					24'h00000F : begin
						scc_en <= 1'b1;
						bit64_op <= 1'b1;
					end
					24'h000011 : begin
						scc_en <= 1'b1;
						bit64_op <= 1'b1;
					end
					24'h000010 : begin
						scc_en <= 1'b1;
					end
					24'h000015 : begin
						scc_en <= 1'b1;
						bit64_op <= 1'b1;
					end
					24'h00001E : begin
						scc_en <= 1'b1;
					end
					24'h000020 : begin
						scc_en <= 1'b1;
					end
					24'h000022 : begin
						scc_en <= 1'b1;
					end
				endcase
			end
			{`SALU_SOPC_FORMAT} : begin
				casex(opcode[23:0])
					24'h000000 : begin scc_en <= 1'b1; end
					24'h000001 : begin scc_en <= 1'b1; end
					24'h000002 : begin scc_en <= 1'b1; end
					24'h000003 : begin scc_en <= 1'b1; end
					24'h000004 : begin scc_en <= 1'b1; end
					24'h000005 : begin scc_en <= 1'b1; end
					24'h000006 : begin scc_en <= 1'b1; end
					24'h000007 : begin scc_en <= 1'b1; end
					24'h000008 : begin scc_en <= 1'b1; end
					24'h000009 : begin scc_en <= 1'b1; end
					24'h00000A : begin scc_en <= 1'b1; end
					24'h00000B : begin scc_en <= 1'b1; end
					default : begin  end
				endcase
			end
			{`SALU_SOPK_FORMAT} : begin
				snd_src_imm <= 1'b1;
				casex(opcode[23:0])
					24'h00000F : begin scc_en <= 1'b1; end
					24'h000010 : begin scc_en <= 1'b1; end
				endcase
			end
		endcase
	end
end
always@(control_en or dst_reg or bit64_op) begin
	exec_en_dreg <= 1'b0;
	exec_ws_dreg <= 2'b00;
	vcc_en  <= 1'b0;
	vcc_ws_dreg  <= 2'b00;
	m0_en   <= 1'b0;
	sgpr_en <= 2'b00;
	casex({control_en, dst_reg})
		{1'b1, 12'b110xxxxxxxxx} : begin
			sgpr_en <= bit64_op ? 2'b11 : 2'b01;
			salu2sgpr_req_trig <= 1'b1; 
		end
		{1'b1, 12'b111000000001} : begin
			vcc_en  <= 1'b1;
			vcc_ws_dreg <= bit64_op ? 2'b11 : 2'b01;
		end
		{1'b1, 12'b111000000010} : begin
			vcc_en  <= 1'b1;
			vcc_ws_dreg <= bit64_op ? 2'b11 : 2'b10;
		end
		{1'b1, 12'b111000001000} : begin
			exec_en_dreg <= 1'b1;
			exec_ws_dreg <= bit64_op ? 2'b11 : 2'b01;
		end
		{1'b1, 12'b111000010000} : begin
			exec_en_dreg <= 1'b1;
			exec_ws_dreg <= bit64_op ? 2'b11 : 2'b10;
		end
		{1'b1, 12'b111000000100} : begin
			m0_en <= 1'b1;
		end
	endcase
end
assign exec_wordsel = exec_ws_dreg | exec_ws_op;
assign vcc_wordsel = vcc_ws_dreg | vcc_ws_op;
assign exec_en = |exec_wordsel;
endmodule
