`timescale 1ns / 1ps
`timescale 1ns / 1ps
module uart_rx #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    input  wire                   rxd,
    output wire                   busy,
    output wire                   overrun_error,
    output wire                   frame_error,
    input  wire [3:0]            uart_data_width,
    input  wire [1:0]            uart_parity,
	input  wire [1:0]            uart_stopbit,
    input  wire [15:0]            prescale
);
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0;
reg output_axis_tvalid_reg = 0;
reg rxd_reg = 1;
reg busy_reg = 0;
reg overrun_error_reg = 0;
reg frame_error_reg = 0;
reg [DATA_WIDTH-1:0] data_reg = 0;
reg [18:0] prescale_reg = 0;
reg [3:0] bit_cnt = 0;
reg parity;
assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign busy = busy_reg;
assign overrun_error = overrun_error_reg;
assign frame_error = frame_error_reg;
always @(posedge clk) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tvalid_reg <= 0;
        rxd_reg <= 1;
        prescale_reg <= 0;
        bit_cnt <= 0;
        busy_reg <= 0;
        overrun_error_reg <= 0;
        frame_error_reg <= 0;
		parity <= 1'b0;
    end else begin
        rxd_reg <= rxd;
        overrun_error_reg <= 0;
        frame_error_reg <= 0;
        if (output_axis_tvalid & output_axis_tready) begin
            output_axis_tvalid_reg <= 0;
        end
        if (prescale_reg > 0) begin
            prescale_reg <= prescale_reg - 1;
        end else if (bit_cnt > 0) begin
            if (bit_cnt > uart_data_width+(uart_stopbit?2:1)) begin
                if (~rxd_reg) begin
                    bit_cnt <= bit_cnt - 1;
                    prescale_reg <= (prescale << 3)-1;
                end else begin
                    bit_cnt <= 0;
                    prescale_reg <= 0;
                end
            end else if (bit_cnt > (uart_stopbit?2:1)) begin
				bit_cnt <= bit_cnt - 1;
				if (bit_cnt == (uart_stopbit?3:2) && uart_stopbit[1] == 1'b1) prescale_reg <= (prescale << 2)-1;
				else prescale_reg <= (prescale << 3)-1;
				if (bit_cnt == (uart_stopbit?3:2) && uart_parity == 2'b01) begin
					parity <= ~(parity ^ rxd_reg);	
				end else if (bit_cnt == (uart_stopbit?3:2) && uart_parity == 2'b10) begin
					parity <= parity ^ rxd_reg;		
				end else begin
					parity <= parity ^ rxd_reg;
					data_reg <= {rxd_reg, data_reg[DATA_WIDTH-1:1]};
				end
            end else if (bit_cnt == 1) begin
                bit_cnt <= bit_cnt - 1;
                if (rxd_reg == 1'b1 && ((parity == 1'b1 && uart_parity != 2'b00) || uart_parity == 2'b00)) begin
                    output_axis_tdata_reg <= data_reg;
                    output_axis_tvalid_reg <= 1;
                    overrun_error_reg <= output_axis_tvalid_reg;
                end else begin
                    frame_error_reg <= 1;
                end
            end
        end else begin
            busy_reg <= 0;
            if (~rxd_reg) begin
                prescale_reg <= (prescale << 2)-2;
                bit_cnt <= uart_data_width+(uart_stopbit?3:2);
                data_reg <= 0;
                busy_reg <= 1;
				parity <= 1'b0;
            end
        end
    end
end
endmodule
