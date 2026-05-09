`timescale 1 ns / 100 ps 
`timescale 1 ns / 100 ps 
module dec256sinc24b
(
    input                       reset_i,
    input                       mclkout_i,
    input                       mdata_i,
    input                       test_i,
    output                      data_rdy_o,     
    output reg  [15:0]          data_o          
);
reg [23:0]  ip_data1;
reg [23:0]  acc1;
reg [23:0]  acc2;
reg [23:0]  acc3;
reg [23:0]  acc3_d1;
reg [23:0]  acc3_d2;
reg [23:0]  diff1;
reg [23:0]  diff2;
reg [23:0]  diff3;
reg [23:0]  diff1_d;
reg [23:0]  diff2_d;
reg [7:0]   word_count;
reg         word_clk;
wire        dft_word_clk;
assign data_rdy_o = word_clk;
assign dft_word_clk = test_i ? mclkout_i : word_clk;

always @(posedge mclkout_i or posedge reset_i)
begin
    if(reset_i == 1'b1)
    begin
        ip_data1    <= 0;
    end
    else
    begin
        ip_data1    <= mdata_i ? 1 : 0;
    end
end

always @(posedge mclkout_i or posedge reset_i)
begin
    if( reset_i == 1'b1 )
    begin
        acc1    <= 0;
        acc2    <= 0;
        acc3    <= 0;
    end
    else
    begin
        acc1    <= acc1 + ip_data1;
        acc2    <= acc2 + acc1;
        acc3    <= acc3 + acc2;
    end
end

always@(posedge mclkout_i or posedge reset_i )
begin
    if(reset_i == 1'b1)
    begin
        word_count  <= 0;
        word_clk <= 0;
    end
    else
    begin
        word_count <= word_count + 1;
        word_clk <= word_count[7];
    end
end

always @(posedge dft_word_clk or posedge reset_i)
begin
    if(reset_i == 1'b1)
    begin
        acc3_d2 <= 0;
        diff1_d <= 0;
        diff2_d <= 0;
        diff1   <= 0;
        diff2   <= 0;
        diff3   <= 0;
    end
    else
    begin
        diff1   <= acc3 - acc3_d2;
        diff2   <= diff1 - diff1_d;
        diff3   <= diff2 - diff2_d;
        acc3_d2 <= acc3;
        diff1_d <= diff1;
        diff2_d <= diff2;
    end
end

always @(posedge dft_word_clk or posedge reset_i)
begin
    if(reset_i == 1'b1)
    begin
        data_o <= 0;
    end
    else
    begin
        data_o[15:0] <= diff3[23:8];
    end
end

endmodule