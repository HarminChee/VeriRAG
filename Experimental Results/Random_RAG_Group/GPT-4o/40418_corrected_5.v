module camera_init (
	input clk,
	input reset_n,
	input test_i, // Test input for DFT
	input scan_clk, // Scan clock for DFT
	input scan_reset_n, // Scan reset for DFT
	output reg ready,
	output wire sda_oe,
	output wire sda,
	input wire sda_in,
	output scl
);
parameter REGS_TO_INIT = 73;
localparam CAMERA_INIT_1 = 11;
localparam CAMERA_INIT_2 = 12;
localparam CAMERA_INIT_3 = 13;
localparam CAMERA_INIT_4 = 14;
localparam CAMERA_INIT_5 = 15;
localparam CAMERA_INIT_6 = 16;
localparam CAMERA_INIT_7 = 17;
localparam CAMERA_IDLE = 18;
localparam CONTROL_REG = 3'b000;
localparam SLAVE_ADDRESS = 3'b001;
localparam SLAVE_REG_ADDRESS = 3'b010;
localparam SLAVE_DATA_1 = 3'b011;
localparam SLAVE_DATA_2 = 3'b100;
reg[7:0] data_in_bus = 0;
reg [2:0] reg_address = 0;
reg bus_write = 0;
wire ready_out;
wire success_out;
i2c_module i2c_write_module(
    .clk(clk), 
    .reset_n(reset_n), 
    .scl_out(scl), 
	.writedata(data_in_bus), 
    .address(reg_address),
	.write(bus_write), 
    .ready(ready_out), 
    .success_out(success_out), 
    .sda_in(sda_in), 
    .sda(sda), 
    .sda_oe(sda_oe)
);
wire[7:0] regs_addr;
wire[7:0] data_to_write;
reg[7:0] counter = 0;
reg[7:0] state_next;
wire [15:0] regs_data = 
counter == 0 ? 16'h12_80 : 
counter == 1 ? 16'hFF_F0 : 
counter == 2 ? 16'h12_04 : 
counter == 3 ? 16'h11_80 : 
counter == 4 ? 16'h0C_00 : 
counter == 5 ? 16'h3E_00 : 
counter == 6 ? 16'h04_00 : 
counter == 7 ? 16'h40_d0 : 
counter == 8 ? 16'h3a_04 : 
counter == 9 ? 16'h14_18 : 
counter == 10 ? 16'h4F_B3 : 
counter == 11 ? 16'h50_B3 : 
counter == 12 ? 16'h51_00 : 
counter == 13 ? 16'h52_3d : 
counter == 14 ? 16'h53_A7 : 
counter == 15 ? 16'h54_E4 : 
counter == 16 ? 16'h58_9E : 
counter == 17 ? 16'h3D_C0 : 
counter == 18 ? 16'h17_14 : 
counter == 19 ? 16'h18_02 : 
counter == 20 ? 16'h32_80 : 
counter == 21 ? 16'h19_03 : 
counter == 22 ? 16'h1A_7B : 
counter == 23 ? 16'h03_0A : 
counter == 24 ? 16'h0F_41 : 
counter == 25 ? 16'h1E_00 : 
counter == 26 ? 16'h33_0B : 
counter == 27 ? 16'h3C_78 : 
counter == 28 ? 16'h69_00 : 
counter == 29 ? 16'h74_00 : 
counter == 30 ? 16'hB0_84 : 
counter == 31 ? 16'hB1_0c : 
counter == 32 ? 16'hB2_0e : 
counter == 33 ? 16'hB3_80 : 
counter == 34 ? 16'h70_3a :
counter == 35 ? 16'h71_35 :
counter == 36 ? 16'h72_11 :
counter == 37 ? 16'h73_f0 :
counter == 38 ? 16'ha2_02 :
counter == 39 ? 16'h7a_20 :
counter == 40 ? 16'h7b_10 :
counter == 41 ? 16'h7c_1e :
counter == 42 ? 16'h7d_35 :
counter == 43 ? 16'h7e_5a :
counter == 44 ? 16'h7f_69 :
counter == 45 ? 16'h80_76 :
counter == 46 ? 16'h81_80 :
counter == 47 ? 16'h82_88 :
counter == 48 ? 16'h83_8f :
counter == 49 ? 16'h84_96 :
counter == 50 ? 16'h85_a3 :
counter == 51 ? 16'h86_af :
counter == 52 ? 16'h87_c4 :
counter == 53 ? 16'h88_d7 :
counter == 54 ? 16'h89_e8 :
counter == 55 ? 16'h13_e0 : 
counter == 56 ? 16'h00_00 : 
counter == 57 ? 16'h10_00 : 
counter == 58 ? 16'h0d_40 : 
counter == 59 ? 16'h14_18 : 
counter == 60 ? 16'ha5_05 : 
counter == 61 ? 16'hab_07 : 
counter == 62 ? 16'h24_95 : 
counter == 63 ? 16'h25_33 : 
counter == 64 ? 16'h26_e3 : 
counter == 65 ? 16'h9f_78 : 
counter == 66 ? 16'ha0_68 : 
counter == 67 ? 16'ha1_03 : 
counter == 68 ? 16'ha6_d8 : 
counter == 69 ? 16'ha7_d8 : 
counter == 70 ? 16'ha8_f0 : 
counter == 71 ? 16'ha9_90 : 
counter == 72 ? 16'haa_94 : 
counter == 73 ? 16'h13_e5 : 
8'hFF;
assign regs_addr = 	counter == 0 ? 8'h12 :
							counter == 1 ? 8'h12 :
							counter == 2 ? 8'h12 :	
							counter == 3 ? 8'h40 :
							counter == 4 ? 8'h58 :
							counter == 5 ? 8'h1e :
							counter == 6 ? 8'h3c :
							8'hFF;
assign data_to_write = 	counter == 0 ? 8'h80 :
								counter == 1 ? 8'h04 :
								counter == 2 ? 8'h04 :	
								counter == 3 ? 8'hd0 :
								counter == 4 ? 8'h9e :
								counter == 5 ? 8'h01 :
								counter == 6 ? 8'h78 :
								8'hFF;
always @(posedge (test_i ? scan_clk : clk)) // Modified for DFT
begin
		if(state_next == CAMERA_IDLE)
			ready <= 1'b1;
		else
			ready <= 1'b0;
end
always @(posedge (test_i ? scan_clk : clk) or negedge (test_i ? scan_reset_n : reset_n)) // Modified for DFT
begin
	if((test_i ? scan_reset_n : reset_n) == 1'b0)
	begin
		state_next <= CAMERA_INIT_1;	
	end
	else
	begin
		case(state_next)
			CAMERA_INIT_1:
				begin 
					state_next <= CAMERA_INIT_2;		
				end
			CAMERA_INIT_2:
				begin
						state_next <= CAMERA_INIT_3;
				end
			CAMERA_INIT_3:
				begin
					state_next <= CAMERA_INIT_4;
				end
			CAMERA_INIT_4:
				begin
					state_next <= CAMERA_INIT_7;
				end
			CAMERA_INIT_7:
			begin
				if(ready_out == 1'b0)
					state_next <= CAMERA_INIT_5;
			end
			CAMERA_INIT_5:
				begin
					if(ready_out == 1'b1)
					begin
						if(success_out == 1'b1)
						begin
							if(counter == REGS_TO_INIT - 1)
							begin
								state_next <= CAMERA_IDLE;
							}
							else
							state_next <= CAMERA_INIT_6;
						end
						else
						state_next <= CAMERA_INIT_2;
					end	
				end
			CAMERA_INIT_6:
				begin
					state_next <= CAMERA_INIT_2;
				end
			CAMERA_IDLE:
				begin
					state_next <= CAMERA_IDLE;
				end
		endcase
	end
end
always @(posedge (test_i ? scan_clk : clk) or negedge (test_i ? scan_reset_n : reset_n)) // Modified for DFT
begin
	if((test_i ? scan_reset_n : reset_n) == 1'b0)
	begin
		reg_address <= 0;
		data_in_bus <= 0;
		bus_write <= 1'b0;
		counter <= 0;
	end
	else
	begin
		case(state_next)
			CAMERA_INIT_1:
				begin
					reg_address <= SLAVE_ADDRESS;
					data_in_bus <= 8'h42; 
					bus_write <= 1'b1;
				end
			CAMERA_INIT_2:
				begin
					reg_address <= SLAVE_REG_ADDRESS;
					data_in_bus <= regs_data[15:8];
					bus_write <= 1'b1;	
				end
			CAMERA_INIT_3:
				begin
					reg_address <= SLAVE_DATA_1;
					data_in_bus <= regs_data[7:0];
					bus_write <= 1'b1;			
				end
			CAMERA_INIT_4:
				begin
					reg_address <= CONTROL_REG;
					data_in_bus <= 3'b001;
					bus_write <= 1'b1;
				end
			CAMERA_INIT_5:
				begin
					reg_address <= 0;
					data_in_bus <= 0;
					bus_write <= 1'b0;
				end
			CAMERA_INIT_6:
				begin
					bus_write <= 1'b0;
					reg_address <= 0;
					data_in_bus <= 0;
					counter <= counter + 1'b1;
				end
			CAMERA_INIT_7:
				begin
					reg_address <= 0;
					data_in_bus <= 0;
					bus_write <= 1'b0;
				end
			CAMERA_IDLE:
				begin
					reg_address <= 0;
					data_in_bus <= 0;
					bus_write <= 1'b0;
				end
			default:
				begin
					bus_write <= 1'b0;
					reg_address <= 3'd0;
					data_in_bus <= 8'd0;
				end
		endcase
	end
end
endmodule