module edidslave (rst_n,clk,sda,scl,dvi_only);
input clk;
input rst_n;
input scl;
inout sda;
input dvi_only;
reg [7:0] adr;
wire [7:0] data;
edidrom edid_rom(clk,adr,data);
wire [7:0] data_hdmi;
hdmirom hdmi_rom(clk,adr,data_hdmi);
wire sdain;
reg sdaout;
assign sda = (sdaout == 1'b0) ? 1'b0 : 1'bz;
assign sdain = sda;
parameter INI = 0;
parameter WAIT_FOR_START = 1;
parameter READ_ADDRESS = 2;
parameter SEND_ADDRESS_ACK = 3; 
parameter READ_REGISTER_ADDRESS = 4;
parameter SEND_REGISTER_ADDRESS_ACK = 5;
parameter WAIT_FOR_START_AGAIN = 6;
parameter READ_ADDRESS_AGAIN = 7;
parameter SEND_ADDRESS_ACK_AGAIN = 8; 
parameter WRITE_BYTE = 9;
parameter FREE_SDA = 10;
parameter WAIT_WRITE_BYTE_ACK = 11; 
parameter RELEASE_SEND_REGISTER_ADDRESS_ACK = 12; 
parameter RELESASE_ADDRESS_ACK = 13; 
parameter RELEASE_SEND_ADDRESS_ACK_AGAIN = 14; 
reg [3:0] state;
wire scl_risingedge,scl_fallingedge, start, stop;
reg [2:0] bitcount;
reg [7:0] sdadata; 
reg [7:0] scl_debounce;
reg scl_stable;
reg sdain_q,scl_q;
assign scl_risingedge = (scl_q ^ scl_stable) & scl_stable;
assign scl_fallingedge = (scl_q ^ scl_stable) & (~scl_stable);
assign start = (sdain^sdain_q) & (~sdain) & scl_stable & scl_q;
assign stop = 1'b0;
always @(posedge clk) begin
	if (~rst_n) begin		
		scl_q <= 0;
		sdain_q <= 0;
		state <= INI;
		bitcount <=7;
		sdadata <=0;
		sdaout <= 1;	
		adr	<= 0;
		scl_stable <=0;
		scl_debounce <=0;
	end else begin 
		scl_debounce <= {scl_debounce[6:0],scl};
		if (scl_debounce == 8'd0) begin
			scl_stable <=0;
		end else if (scl_debounce == 8'b11111111 ) begin
			scl_stable <= 1;
		end
		scl_q <= scl_stable;
		sdain_q <= sdain;
		if (stop) begin
			state <= INI;
		end 
		case (state)
			INI: begin 
				state <= WAIT_FOR_START;
				scl_q <= 0;
				sdain_q <= 0;
				bitcount <=7;
				sdadata <=0;
				sdaout <= 1;	
				adr	<= 0;				
				scl_stable <=0;
			end
			WAIT_FOR_START: begin 
				if (start) begin
					state <= READ_ADDRESS;
				end
			end
			READ_ADDRESS: begin 
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						state <= SEND_ADDRESS_ACK;
					end 
				end 
			end
			SEND_ADDRESS_ACK: begin
				if (scl_fallingedge) begin
					sdaout <= 0;
					state <= RELESASE_ADDRESS_ACK;
				end
			end
			RELESASE_ADDRESS_ACK: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= READ_REGISTER_ADDRESS;
				end
			end
			READ_REGISTER_ADDRESS: begin
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						state <= SEND_REGISTER_ADDRESS_ACK;
					end 
				end 
			end
			SEND_REGISTER_ADDRESS_ACK: begin
				if (scl_fallingedge) begin
					sdaout <= 0;
					state <= RELEASE_SEND_REGISTER_ADDRESS_ACK;
				end
			end
			RELEASE_SEND_REGISTER_ADDRESS_ACK: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_FOR_START_AGAIN;
				end
			end
			WAIT_FOR_START_AGAIN: begin
				if (start) begin
					state <= READ_ADDRESS_AGAIN;
				end 
			end
			READ_ADDRESS_AGAIN: begin
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						state <= SEND_ADDRESS_ACK_AGAIN;
					end 
				end 		
			end
			SEND_ADDRESS_ACK_AGAIN: begin
				if (scl_fallingedge) begin
					sdaout <= 0;
					state <= WRITE_BYTE;
				end
			end
			WRITE_BYTE: begin
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					if (dvi_only) begin
						sdaout <= data[bitcount];
					end else begin
						sdaout <= data_hdmi[bitcount];
					end
					if (bitcount==0) begin
						state <= FREE_SDA;
						adr <= adr +1;
						if ((adr ==  127) & dvi_only) begin
							state <= INI;
						end else if (adr == 255) begin
							state <= INI;
						end
					end 
				end				
			end
			FREE_SDA: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK;
				end
			end
			WAIT_WRITE_BYTE_ACK: begin
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= WRITE_BYTE;
					end else begin
						state <= INI;
					end
				end
			end
			default : begin
				state <= INI;
			end
		endcase		
	end
end
endmodule
