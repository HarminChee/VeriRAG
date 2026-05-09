`timescale 1ns / 1ps
`timescale 1ns / 1ps
module i2s_rx #
(
    parameter WIDTH = 16
)
(
    input  wire              clk,
    input  wire              rst,
    input  wire              sck,
    input  wire              ws,
    input  wire              sd,
    output wire [WIDTH-1:0]  output_l_tdata,
    output wire [WIDTH-1:0]  output_r_tdata,
    output wire              output_tvalid,
    input  wire              output_tready
);
reg [WIDTH-1:0] l_data_reg = 0;
reg [WIDTH-1:0] r_data_reg = 0;
reg l_data_valid_reg = 0;
reg r_data_valid_reg = 0;
reg [WIDTH-1:0] sreg = 0;
reg [$clog2(WIDTH)-1:0] bit_cnt = 0;
reg last_sck = 0;
reg last_ws = 0;
reg last_ws2 = 0;
assign output_l_tdata = l_data_reg;
assign output_r_tdata = r_data_reg;
assign output_tvalid = l_data_valid_reg & r_data_valid_reg;
always @(posedge clk) begin
    if (rst) begin
        l_data_reg <= 0;
        r_data_reg <= 0;
        l_data_valid_reg <= 0;
        r_data_valid_reg <= 0;
        sreg <= 0;
        bit_cnt <= 0;
        last_sck <= 0;
        last_ws <= 0;
        last_ws2 <= 0;
    end else begin
        if (output_tready & output_tvalid) begin
            l_data_valid_reg <= 0;
            r_data_valid_reg <= 0;
        end
        last_sck <= sck;
        if (~last_sck & sck) begin
            last_ws <= ws;
            last_ws2 <= last_ws;
            if (last_ws2 != last_ws) begin
                bit_cnt <= WIDTH-1;
                sreg <= {{WIDTH-1{1'b0}}, sd};
            end else begin
                if (bit_cnt > 0) begin
                    bit_cnt <= bit_cnt - 1;
                    if (bit_cnt > 1) begin
                        sreg <= {sreg[WIDTH-2:0], sd};
                    end else if (last_ws2) begin
                        r_data_reg <= {sreg[WIDTH-2:0], sd};
                        r_data_valid_reg <= l_data_valid_reg;
                    end else begin
                        l_data_reg <= {sreg[WIDTH-2:0], sd};
                        l_data_valid_reg <= 1;
                    end
                end
            end
        end
    end
end
endmodule
