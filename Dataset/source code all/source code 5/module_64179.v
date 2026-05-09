`timescale 1ns / 1ns
`timescale 1ns / 1ns
module main_sim();
    reg clk = 0;
    always begin 
        clk = 0; 
        #10; 
        clk = 1; 
        #10; 
    end
    wire clk_recv;
    wire data;
    wire cmd;
    wire reset;
    main tb(.clk_in(clk), .sclk(clk_recv), .sdata(data), .scmd(cmd), .reset(reset));
    reg [7 : 0] data_recv = 0;
    reg [2 : 0] data_cnt = 7;
    always @ (posedge clk_recv) begin
        data_recv[data_cnt] = data;
        data_cnt = data_cnt - 1;
    end
endmodule
