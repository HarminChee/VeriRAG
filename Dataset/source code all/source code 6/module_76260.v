module user_logic
(
	leds,
	hex_sda,
	hex_scl,
	pushbuttons,
	dipsw,
	Bus2IP_Clk,                     
	Bus2IP_Reset,                   
	Bus2IP_Data,                    
	Bus2IP_BE,                      
	Bus2IP_RdCE,                    
	Bus2IP_WrCE,                    
	IP2Bus_Data,                    
	IP2Bus_RdAck,                   
	IP2Bus_WrAck,                   
	IP2Bus_Error                    
); 
parameter C_ADDRESS_0					 = 8'h40;
parameter C_ADDRESS_1					 = 8'h50;
parameter C_I2C_DIVIDER					 = 8'h40;
parameter C_SLV_DWIDTH                   = 32;
parameter C_NUM_REG                      = 5;
output [0:7] leds;
output hex_sda;
output hex_scl;
input [0:3] pushbuttons;
input [0:3] dipsw;
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_SLV_DWIDTH-1]           Bus2IP_Data;
input      [0 : C_SLV_DWIDTH/8-1]         Bus2IP_BE;
input      [0 : C_NUM_REG-1]              Bus2IP_RdCE;
input      [0 : C_NUM_REG-1]              Bus2IP_WrCE;
output     [0 : C_SLV_DWIDTH-1]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
wire [0:7] addr0;
wire [0:7] addr1;
wire [0:7] divider;
assign addr0 = C_ADDRESS_0;
assign addr1 = C_ADDRESS_1;
assign divider = C_I2C_DIVIDER;
reg        [0 : C_SLV_DWIDTH-1]           slv_reg0;
reg        [0 : C_SLV_DWIDTH-1]           slv_reg1;
reg        [0 : C_SLV_DWIDTH-1]           slv_reg2;
reg        [0 : C_SLV_DWIDTH-1]           slv_reg3;
reg        [0 : C_SLV_DWIDTH-1]           slv_reg4;
wire       [0 : 4]                        slv_reg_write_sel;
wire       [0 : 4]                        slv_reg_read_sel;
reg        [0 : C_SLV_DWIDTH-1]           slv_ip2bus_data;
wire                                      slv_read_ack;
wire                                      slv_write_ack;
integer                                   byte_index, bit_index;
reg [0:3] push_de0;
reg [0:3] push_de1;
reg [0:3] push_de2;
reg [0:3] push_de3;
reg [0:3] dip_de0;
reg [0:3] dip_de1;
reg [0:3] dip_de2;
reg [0:3] dip_de3;
reg [0:7] hex_l_local;
wire [0:7] hex_l_hw;
reg [0:7] hex_m_local;
wire [0:7] hex_m_hw;
reg [0:7] hex_r_local;
wire [0:7] hex_r_hw;
wire [0:7] hex_led;
assign leds = slv_reg0[24:31];
always @( posedge Bus2IP_Clk )
	begin
		push_de0 <= (push_de0 << 1) | {3'b0, pushbuttons[0]};
		push_de1 <= (push_de1 << 1) | {3'b0, pushbuttons[1]};
		push_de2 <= (push_de2 << 1) | {3'b0, pushbuttons[2]};
		push_de3 <= (push_de3 << 1) | {3'b0, pushbuttons[3]};
		slv_reg1[28] <= &push_de0;
		slv_reg1[29] <= &push_de1;
		slv_reg1[30] <= &push_de2;
		slv_reg1[31] <= &push_de3;
		dip_de0 <= (dip_de0 << 1) | {3'b0, dipsw[0]};
		dip_de1 <= (dip_de1 << 1) | {3'b0, dipsw[1]};
		dip_de2 <= (dip_de2 << 1) | {3'b0, dipsw[2]};
		dip_de3 <= (dip_de3 << 1) | {3'b0, dipsw[3]};
		slv_reg1[24] <= &dip_de0;
		slv_reg1[25] <= &dip_de1;
		slv_reg1[26] <= &dip_de2;
		slv_reg1[27] <= &dip_de3;
		if (slv_reg4[31] == 1'b1)
			begin
				case ({slv_reg2[26], slv_reg2[28:31]})
					5'b00000:
						hex_r_local <= 8'b11111100;
					5'b00001:
						hex_r_local <= 8'b00011000;
					5'b00010:
						hex_r_local <= 8'b01101110;
					5'b00011:
						hex_r_local <= 8'b00111110;
					5'b00100:
						hex_r_local <= 8'b10011010;
					5'b00101:
						hex_r_local <= 8'b10110110;
					5'b00110:
						hex_r_local <= 8'b11110110;
					5'b00111:
						hex_r_local <= 8'b00011100;
					5'b01000:
						hex_r_local <= 8'b11111110;
					5'b01001:
						hex_r_local <= 8'b10111110;
					5'b01010:
						hex_r_local <= 8'b11011110;
					5'b01011:
						hex_r_local <= 8'b11111110;
					5'b01100:
						hex_r_local <= 8'b11100100;
					5'b01101:
						hex_r_local <= 8'b11111100;
					5'b01110:
						hex_r_local <= 8'b11100110;
					5'b01111:
						hex_r_local <= 8'b11000110;
					default:
						hex_r_local <= 8'b00000000;
				endcase
				hex_r_local[7] <= slv_reg2[27];
			end
		else
			begin
				hex_r_local <= slv_reg3[16:23];
			end
		if (slv_reg4[30] == 1'b1)
			begin
				case ({slv_reg2[18], slv_reg2[20:23]})
					5'b00000:
						hex_m_local <= 8'b11111100;
					5'b00001:
						hex_m_local <= 8'b00011000;
					5'b00010:
						hex_m_local <= 8'b01101110;
					5'b00011:
						hex_m_local <= 8'b00111110;
					5'b00100:
						hex_m_local <= 8'b10011010;
					5'b00101:
						hex_m_local <= 8'b10110110;
					5'b00110:
						hex_m_local <= 8'b11110110;
					5'b00111:
						hex_m_local <= 8'b00011100;
					5'b01000:
						hex_m_local <= 8'b11111110;
					5'b01001:
						hex_m_local <= 8'b10111110;
					5'b01010:
						hex_m_local <= 8'b11011110;
					5'b01011:
						hex_m_local <= 8'b11111110;
					5'b01100:
						hex_m_local <= 8'b11100100;
					5'b01101:
						hex_m_local <= 8'b11111100;
					5'b01110:
						hex_m_local <= 8'b11100110;
					5'b01111:
						hex_m_local <= 8'b11000110;
					default:
						hex_m_local <= 8'b00000000;
				endcase
				hex_m_local[7] <= slv_reg2[19];
			end
		else
			begin
				hex_m_local <= slv_reg3[8:15];
			end
		if (slv_reg4[29] == 1'b1)
			begin
				case ({slv_reg2[10], slv_reg2[12:15]})
					5'b00000:
						hex_l_local <= 8'b11111100;
					5'b00001:
						hex_l_local <= 8'b00011000;
					5'b00010:
						hex_l_local <= 8'b01101110;
					5'b00011:
						hex_l_local <= 8'b00111110;
					5'b00100:
						hex_l_local <= 8'b10011010;
					5'b00101:
						hex_l_local <= 8'b10110110;
					5'b00110:
						hex_l_local <= 8'b11110110;
					5'b00111:
						hex_l_local <= 8'b00011100;
					5'b01000:
						hex_l_local <= 8'b11111110;
					5'b01001:
						hex_l_local <= 8'b10111110;
					5'b01010:
						hex_l_local <= 8'b11011110;
					5'b01011:
						hex_l_local <= 8'b11111110;
					5'b01100:
						hex_l_local <= 8'b11100100;
					5'b01101:
						hex_l_local <= 8'b11111100;
					5'b01110:
						hex_l_local <= 8'b11100110;
					5'b01111:
						hex_l_local <= 8'b11000110;
					default:
						hex_l_local <= 8'b00000000;
				endcase
				hex_l_local[7] <= slv_reg2[11];
			end
		else
			begin
				hex_l_local <= slv_reg3[0:7];
			end
	end
assign hex_r_hw = {hex_r_local[0], hex_r_local[6], hex_r_local[1], hex_r_local[2], hex_r_local[7], hex_r_local[3], hex_r_local[4], hex_r_local[5]};
assign hex_m_hw = {hex_m_local[0], hex_m_local[6], hex_m_local[1], hex_m_local[2], hex_m_local[7], hex_m_local[3], hex_m_local[4], hex_m_local[5]};
assign hex_l_hw = {hex_l_local[5], hex_l_local[4], hex_l_local[3], hex_l_local[7], hex_l_local[2], hex_l_local[1], hex_l_local[6], hex_l_local[0]};
assign hex_led = slv_reg3[24:31];
assign
	slv_reg_write_sel = Bus2IP_WrCE[0:4],
	slv_reg_read_sel  = Bus2IP_RdCE[0:4],
	slv_write_ack     = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2] || Bus2IP_WrCE[3] || Bus2IP_WrCE[4],
	slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3] || Bus2IP_RdCE[4];
always @( posedge Bus2IP_Clk )
	begin: SLAVE_REG_WRITE_PROC
		if ( Bus2IP_Reset == 1 )
			begin
				slv_reg0 <= 0;
				slv_reg2 <= 0;
				slv_reg3 <= 0;
				slv_reg4 <= 0;
			end
		else
			case (slv_reg_write_sel)
				5'b10000 :
					for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
						if ( Bus2IP_BE[byte_index] == 1 )
							for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
								slv_reg0[bit_index] <= Bus2IP_Data[bit_index];
				5'b00100 :
					for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
						if ( Bus2IP_BE[byte_index] == 1 )
							for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
								slv_reg2[bit_index] <= Bus2IP_Data[bit_index];
				5'b00010 : 
					for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
						if ( Bus2IP_BE[byte_index] == 1 )
							for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
								slv_reg3[bit_index] <= Bus2IP_Data[bit_index];
				5'b00001 :
					for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
						if ( Bus2IP_BE[byte_index] == 1 )
							for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
								slv_reg4[bit_index] <= Bus2IP_Data[bit_index];
				default : ;
			endcase
	end 
always @( slv_reg_read_sel or slv_reg0 or slv_reg1 or slv_reg2 or slv_reg3 or slv_reg4 )
	begin: SLAVE_REG_READ_PROC
		case ( slv_reg_read_sel )
			5'b10000 : slv_ip2bus_data <= slv_reg0;
			5'b01000 : slv_ip2bus_data <= slv_reg1;
			5'b00100 : slv_ip2bus_data <= slv_reg2;
			5'b00010 : slv_ip2bus_data <= {hex_l_local, hex_m_local, hex_r_local, hex_led};
			5'b00001 : slv_ip2bus_data <= slv_reg4;
			default : slv_ip2bus_data <= 0;
		endcase
	end 
assign IP2Bus_Data    = slv_ip2bus_data;
assign IP2Bus_WrAck   = slv_write_ack;
assign IP2Bus_RdAck   = slv_read_ack;
assign IP2Bus_Error   = 0;
hex_out_cw hex_io (
	.clk(Bus2IP_Clk),
	.ce(1'b1),
	.address0(addr0),
	.address1(addr1),
	.divider(divider),
	.hex_l(hex_m_hw), 
	.hex_m(hex_l_hw), 
	.hex_r(hex_r_hw),
	.led8(hex_led),
	.reset(Bus2IP_Reset),
	.scl(hex_scl),
	.sda(hex_sda)
);
endmodule
