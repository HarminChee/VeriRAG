module buffer (
	input wire [3:0] buff_in,
	input wire       buff_in_valid,
	output reg buff_out,
	output reg buff_out_valid,
	output wire buffer_full,
	input wire CLK,
	input wire Reset
);
	reg [31:0] buffer_array; 
	reg [31:0] sp;           
	assign buffer_full = sp[29]; 
	always @ (posedge CLK or negedge Reset) begin
		if(~Reset) begin
			buffer_array <= 32'b0;
		end
		else begin
			if (buff_in_valid) begin
				buffer_array <= (sp[28]) ? ({buff_in[3:0], buffer_array[28:1]}) : (
					(sp[27]) ? ({01'b0, buff_in[3:0], buffer_array[27:1]}) :
					(sp[26]) ? ({02'b0, buff_in[3:0], buffer_array[26:1]}) :
					(sp[25]) ? ({03'b0, buff_in[3:0], buffer_array[25:1]}) :
					(sp[24]) ? ({04'b0, buff_in[3:0], buffer_array[24:1]}) :
					(sp[23]) ? ({05'b0, buff_in[3:0], buffer_array[23:1]}) :
					(sp[22]) ? ({06'b0, buff_in[3:0], buffer_array[22:1]}) :
					(sp[21]) ? ({07'b0, buff_in[3:0], buffer_array[21:1]}) :
					(sp[20]) ? ({08'b0, buff_in[3:0], buffer_array[20:1]}) :
					(sp[19]) ? ({09'b0, buff_in[3:0], buffer_array[19:1]}) :
					(sp[18]) ? ({10'b0, buff_in[3:0], buffer_array[18:1]}) :
					(sp[17]) ? ({11'b0, buff_in[3:0], buffer_array[17:1]}) :
					(sp[16]) ? ({12'b0, buff_in[3:0], buffer_array[16:1]}) :
					(sp[15]) ? ({13'b0, buff_in[3:0], buffer_array[15:1]}) :
					(sp[14]) ? ({14'b0, buff_in[3:0], buffer_array[14:1]}) :
					(sp[13]) ? ({15'b0, buff_in[3:0], buffer_array[13:1]}) :
					(sp[12]) ? ({16'b0, buff_in[3:0], buffer_array[12:1]}) :
					(sp[11]) ? ({17'b0, buff_in[3:0], buffer_array[11:1]}) :
					(sp[10]) ? ({18'b0, buff_in[3:0], buffer_array[10:1]}) :
					(sp[09]) ? ({19'b0, buff_in[3:0], buffer_array[09:1]}) :
					(sp[08]) ? ({20'b0, buff_in[3:0], buffer_array[08:1]}) :
					(sp[07]) ? ({21'b0, buff_in[3:0], buffer_array[07:1]}) :
					(sp[06]) ? ({22'b0, buff_in[3:0], buffer_array[06:1]}) :
					(sp[05]) ? ({23'b0, buff_in[3:0], buffer_array[05:1]}) :
					(sp[04]) ? ({24'b0, buff_in[3:0], buffer_array[04:1]}) :
					(sp[03]) ? ({25'b0, buff_in[3:0], buffer_array[03:1]}) :
					(sp[02]) ? ({26'b0, buff_in[3:0], buffer_array[02:1]}) :
					(sp[01]) ? ({27'b0, buff_in[3:0], buffer_array[01:1]}) :
					(sp[00]) ? ({28'b0, buff_in[3:0]}) : {29'b0, buff_in[3:1]} );
			end
			else begin
				buffer_array <= {1'b0, buffer_array[31:1]};
			end
		end
	end
	always @ (posedge CLK or negedge Reset) begin
		if(~Reset) begin
			buff_out <= 0;
			buff_out_valid <= 0;
		end
		else begin
			if(buff_in_valid) begin
				buff_out_valid <= 1'b1;
				buff_out <= (sp[0]) ? (buffer_array[0]) : (buff_in);
			end else begin
				buff_out_valid <= sp[0];
				buff_out <= buffer_array[0];
			end
		end
	end	
	always @ (posedge CLK or negedge Reset) begin
		if(~Reset) begin
			sp <= 32'b0;
		end
		else begin
			if(buff_in_valid) begin
				sp <= {sp[28:0] ,3'b0};
			end
			else begin
				sp <= {1'b0, sp[31:1]};
			end
		end
	end	
endmodule
