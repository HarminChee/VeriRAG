`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PmodGYRO (
		input wire clk,
		input wire RST,
		inout wire  [3:0] JA,
        output wire [15:0]  temp_data_out,
        output wire [15:0]  x_axis_out,
        output wire [15:0]  y_axis_out,
        output wire [15:0]  z_axis_out,
        output wire [7:0]   temp_data,
        output wire [15:0]  x_axis_data,
        output wire [15:0]  y_axis_data,
        output wire [15:0]  z_axis_data,
        output wire [15:0]  ang_x,
        output reg [ 7 : 0 ] out_data0,
        output reg [ 7 : 0 ] out_data1,
        output reg [ 7 : 0 ] out_data2,
        output reg [ 7 : 0 ] out_data3,
        output reg [ 7 : 0 ] out_data4,
        output reg [ 7 : 0 ] out_data5,
        output reg [ 7 : 0 ] out_data6,
        output reg [ 7 : 0 ] out_data7
);
   wire         begin_transmission;
   wire         end_transmission;
   wire [7:0]   send_data;
   wire [7:0]   recieved_data;
   wire         slave_select;
            always @(posedge clk) begin
                        out_data4 <= send_data;
                        out_data5 <= recieved_data;
            end
            always @(begin_transmission)
                        out_data6[0] <= begin_transmission;
            always @(end_transmission)
                        out_data6[1] <= end_transmission;
            always @(slave_select)
                        out_data6[2] <= slave_select;
			master_interface C0(
						.begin_transmission(begin_transmission),
						.end_transmission(end_transmission),
						.send_data(send_data),
						.recieved_data(recieved_data),
						.clk(clk),
						.rst(RST),
						.slave_select(slave_select),
						.start(1'b1),
						.temp_data(temp_data),
						.x_axis_data(x_axis_data),
						.y_axis_data(y_axis_data),
						.z_axis_data(z_axis_data)
			);
			spi_interface C1(
						.begin_transmission(begin_transmission),
						.slave_select(slave_select),
						.send_data(send_data),
						.recieved_data(recieved_data),
						.miso(JA[2]),
						.clk(clk),
						.rst(RST),
						.end_transmission(end_transmission),
						.mosi(JA[1]),
						.sclk(JA[3])
			);
            data_formatter DF0
                (
                .GCLK(clk),
                .RST(RST),
                .dec(1'b1),
                .temp_data_in(temp_data),
                .x_axis_in(x_axis_data[15:0]),
                .y_axis_in(y_axis_data[15:0]),
                .z_axis_in(z_axis_data[15:0]),
                .x_axis_out(x_axis_out),
                .y_axis_out(y_axis_out),
                .z_axis_out(z_axis_out),
                .temp_data_out(temp_data_out),
                .ang_x(ang_x)
                );
			assign JA[0] = slave_select;
endmodule
