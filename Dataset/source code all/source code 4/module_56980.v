module edidmaster (rst_n,clk,sda,scl,stop_reading,address_w,start,address_r,reg0,sdadata,out_en);
input clk;
input stop_reading;
input rst_n;
output reg scl;
inout sda;
input start;
input [7:0] address_w;
input [7:0] address_r;
input [7:0] reg0;
output reg [7:0] sdadata;
output reg out_en;
wire sdain;
reg sdaout;
assign sda = (sdaout == 1'b0) ? 1'b0 : 1'bz;
assign sdain = sda;
parameter INI = 0;
parameter WAIT_FOR_START = 1;
parameter GEN_START = 2;
parameter WRITE_BYTE_ADD_W = 3;
parameter FREE_SDA_ADD_W = 4;
parameter WAIT_WRITE_BYTE_ACK_ADD = 5;
parameter WRITE_BYTE_REG = 6;
parameter FREE_SDA_REG = 7;
parameter WAIT_WRITE_BYTE_ACK_REG = 8;
parameter WRITE_BYTE_ADD_R = 9;
parameter FREE_SDA_ADD_R = 10;
parameter WAIT_WRITE_BYTE_ACK_ADD_R = 11;
parameter READ_DATA = 12;
parameter SEND_READ_ACK = 13;
parameter RELESASE_ACK = 14;
parameter GEN_START2 = 15;
parameter SKIP1 = 16;
reg [4:0] state;
reg [8:0] scl_counter;
reg scl_q,middle_scl;
reg [2:0] bitcount;
assign scl_risingedge = (scl_q ^ scl) & scl;
assign scl_fallingedge = (scl_q ^ scl) & (~scl);
always @(posedge clk) begin
	if (~rst_n) begin		
		scl_counter <=0;
		scl <= 0;
		middle_scl <= 0;
		scl_q <= 0;
		state <= INI;
		bitcount <= 7;
		sdadata <=0;
		sdaout <= 1;			
		out_en <=0;
	end else begin 
	out_en <=0;
	scl_counter <= scl_counter +1;
	if (scl_counter == 499) begin
		scl <= ~ scl;
		scl_counter <= 0;
	end
	scl_q <= scl;
	middle_scl <= 0;
	if ((scl_counter == 256) & scl) begin
		middle_scl <= 1;
	end
	case (state)
			INI: begin 
				state <= WAIT_FOR_START;
				scl_q <= 0;
				bitcount <=7;
				sdadata <=0;
				sdaout <= 1;	
			end
			WAIT_FOR_START: begin 
				if (start) begin
					state <= GEN_START;
				end
			end
			GEN_START : begin 
				if (middle_scl) begin
					sdaout <= 0;
					scl_counter <= 0;
					state <= WRITE_BYTE_ADD_W;
				end
			end
			WRITE_BYTE_ADD_W: begin
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					sdaout <= address_w[bitcount];
					if (bitcount==0) begin
						state <= FREE_SDA_ADD_W;
					end 
				end				
			end
			FREE_SDA_ADD_W: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK_ADD;
				end
			end
			WAIT_WRITE_BYTE_ACK_ADD: begin
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= WRITE_BYTE_REG;
					end else begin
						state <= INI;
					end
				end
			end
			WRITE_BYTE_REG: begin
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					sdaout <= reg0[bitcount];
					if (bitcount==0) begin
						state <= FREE_SDA_REG;
					end 
				end				
			end
			FREE_SDA_REG: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK_REG;
				end
			end
			WAIT_WRITE_BYTE_ACK_REG: begin
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= SKIP1;
					end else begin
						state <= INI;
					end
				end
			end
			SKIP1 : begin
				if (scl_risingedge) begin
					state <= GEN_START2;
				end
			end
			GEN_START2 : begin 
				if (middle_scl) begin
					sdaout <= 0;
					scl_counter <= 0;
					state <= WRITE_BYTE_ADD_R;
				end
			end						
			WRITE_BYTE_ADD_R: begin
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					sdaout <= address_r[bitcount];
					if (bitcount==0) begin
						state <= FREE_SDA_ADD_R;
					end 
				end				
			end
			FREE_SDA_ADD_R: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK_ADD_R;
				end
			end
			WAIT_WRITE_BYTE_ACK_ADD_R: begin
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= READ_DATA;
					end else begin
						state <= INI;
					end
				end
			end
			READ_DATA: begin 
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						out_en <= 1;
						state <= SEND_READ_ACK;
					end 
				end 
			end
			SEND_READ_ACK: begin
				if (scl_fallingedge) begin
					if (stop_reading) begin
						state <= INI;
						sdaout <= 1; 
					end else begin
						sdaout <= 0;
						state <= RELESASE_ACK;
					end
				end
			end
			RELESASE_ACK: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= READ_DATA;
				end
			end
			default : begin
				state <= INI;
			end
		endcase		
	end
end
endmodule
