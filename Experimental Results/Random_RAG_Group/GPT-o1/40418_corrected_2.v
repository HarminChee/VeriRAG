`timescale 1ns/1ps
module camera_init (
	input clk,
	input reset_n,
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
reg [7:0] data_in_bus;
reg [2:0] reg_address;
reg bus_write;
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
wire [7:0] regs_addr;
wire [7:0] data_to_write;
reg [7:0] counter;
reg [7:0] state_next;
wire [15:0] regs_data =
	counter == 0  ? 16'h1280 :
	counter == 1  ? 16'hfff0 :
	counter == 2  ? 16'h1204 :
	counter == 3  ? 16'h1180 :
	counter == 4  ? 16'h0c00 :
	counter == 5  ? 16'h3e00 :
	counter == 6  ? 16'h0400 :
	counter == 7  ? 16'h40d0 :
	counter == 8  ? 16'h3a04 :
	counter == 9  ? 16'h1418 :
	counter == 10 ? 16'h4fb3 :
	counter == 11 ? 16'h50b3 :
	counter == 12 ? 16'h5100 :
	counter == 13 ? 16'h523d :
	counter == 14 ? 16'h53a7 :
	counter == 15 ? 16'h54e4 :
	counter == 16 ? 16'h589e :
	counter == 17 ? 16'h3dc0 :
	counter == 18 ? 16'h1714 :
	counter == 19 ? 16'h1802 :
	counter == 20 ? 16'h3280 :
	counter == 21 ? 16'h1903 :
	counter == 22 ? 16'h1a7b :
	counter == 23 ? 16'h030a :
	counter == 24 ? 16'h0f41 :
	counter == 25 ? 16'h1e00 :
	counter == 26 ? 16'h330b :
	counter == 27 ? 16'h3c78 :
	counter == 28 ? 16'h6900 :
	counter == 29 ? 16'h7400 :
	counter == 30 ? 16'hb084 :
	counter == 31 ? 16'hb10c :
	counter == 32 ? 16'hb20e :
	counter == 33 ? 16'hb380 :
	counter == 34 ? 16'h703a :
	counter == 35 ? 16'h7135 :
	counter == 36 ? 16'h7211 :
	counter == 37 ? 16'h73f0 :
	counter == 38 ? 16'ha202 :
	counter == 39 ? 16'h7a20 :
	counter == 40 ? 16'h7b10 :
	counter == 41 ? 16'h7c1e :
	counter == 42 ? 16'h7d35 :
	counter == 43 ? 16'h7e5a :
	counter == 44 ? 16'h7f69 :
	counter == 45 ? 16'h8076 :
	counter == 46 ? 16'h8180 :
	counter == 47 ? 16'h8288 :
	counter == 48 ? 16'h838f :
	counter == 49 ? 16'h8496 :
	counter == 50 ? 16'h85a3 :
	counter == 51 ? 16'h86af :
	counter == 52 ? 16'h87c4 :
	counter == 53 ? 16'h88d7 :
	counter == 54 ? 16'h89e8 :
	counter == 55 ? 16'h13e0 :
	counter == 56 ? 16'h0000 :
	counter == 57 ? 16'h1000 :
	counter == 58 ? 16'h0d40 :
	counter == 59 ? 16'h1418 :
	counter == 60 ? 16'ha505 :
	counter == 61 ? 16'hab07 :
	counter == 62 ? 16'h2495 :
	counter == 63 ? 16'h2533 :
	counter == 64 ? 16'h26e3 :
	counter == 65 ? 16'h9f78 :
	counter == 66 ? 16'ha068 :
	counter == 67 ? 16'ha103 :
	counter == 68 ? 16'ha6d8 :
	counter == 69 ? 16'ha7d8 :
	counter == 70 ? 16'ha8f0 :
	counter == 71 ? 16'ha990 :
	counter == 72 ? 16'haa94 :
	16'hffff;
assign regs_addr =
	counter == 0 ? 8'h12 :
	counter == 1 ? 8'h12 :
	counter == 2 ? 8'h12 :
	counter == 3 ? 8'h40 :
	counter == 4 ? 8'h58 :
	counter == 5 ? 8'h1e :
	counter == 6 ? 8'h3c :
	8'hff;
assign data_to_write =
	counter == 0 ? 8'h80 :
	counter == 1 ? 8'h04 :
	counter == 2 ? 8'h04 :
	counter == 3 ? 8'hd0 :
	counter == 4 ? 8'h9e :
	counter == 5 ? 8'h01 :
	counter == 6 ? 8'h78 :
	8'hff;
always @(posedge clk) begin
	if (state_next == CAMERA_IDLE)
		ready <= 1'b1;
	else
		ready <= 1'b0;
end
always @(posedge clk) begin
	if (reset_n == 1'b0) begin
		state_next <= CAMERA_INIT_1;
	end
	else begin
		case(state_next)
			CAMERA_INIT_1: state_next <= CAMERA_INIT_2;
			CAMERA_INIT_2: state_next <= CAMERA_INIT_3;
			CAMERA_INIT_3: state_next <= CAMERA_INIT_4;
			CAMERA_INIT_4: state_next <= CAMERA_INIT_7;
			CAMERA_INIT_7: if(ready_out == 1'b0) state_next <= CAMERA_INIT_5;
			CAMERA_INIT_5: begin
				if(ready_out == 1'b1) begin
					if(success_out == 1'b1) begin
						if(counter == REGS_TO_INIT - 1)
							state_next <= CAMERA_IDLE;
						else
							state_next <= CAMERA_INIT_6;
					end
					else
						state_next <= CAMERA_INIT_2;
				end
			end
			CAMERA_INIT_6: state_next <= CAMERA_INIT_2;
			CAMERA_IDLE:   state_next <= CAMERA_IDLE;
			default:       state_next <= CAMERA_IDLE;
		endcase
	end
end
always @(posedge clk) begin
	if (reset_n == 1'b0) begin
		reg_address <= 0;
		data_in_bus <= 0;
		bus_write <= 1'b0;
		counter <= 0;
	end
	else begin
		case(state_next)
			CAMERA_INIT_1: begin
				reg_address <= SLAVE_ADDRESS;
				data_in_bus <= 8'h42;
				bus_write <= 1'b1;
			end
			CAMERA_INIT_2: begin
				reg_address <= SLAVE_REG_ADDRESS;
				data_in_bus <= regs_data[15:8];
				bus_write <= 1'b1;
			end
			CAMERA_INIT_3: begin
				reg_address <= SLAVE_DATA_1;
				data_in_bus <= regs_data[7:0];
				bus_write <= 1'b1;
			end
			CAMERA_INIT_4: begin
				reg_address <= CONTROL_REG;
				data_in_bus <= 3'b001;
				bus_write <= 1'b1;
			end
			CAMERA_INIT_5: begin
				reg_address <= 0;
				data_in_bus <= 0;
				bus_write <= 1'b0;
			end
			CAMERA_INIT_6: begin
				bus_write <= 1'b0;
				reg_address <= 0;
				data_in_bus <= 0;
				counter <= counter + 1'b1;
			end
			CAMERA_INIT_7: begin
				reg_address <= 0;
				data_in_bus <= 0;
				bus_write <= 1'b0;
			end
			CAMERA_IDLE: begin
				reg_address <= 0;
				data_in_bus <= 0;
				bus_write <= 1'b0;
			end
			default: begin
				bus_write <= 1'b0;
				reg_address <= 3'd0;
				data_in_bus <= 8'd0;
			end
		endcase
	end
end
endmodule