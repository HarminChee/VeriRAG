module Counter_1_corrected_clk(clk, rst, dout, dout_fabric);
    input wire clk;
    output wire dout;
    output wire dout_fabric;
    input wire rst;
    
    localparam COUNT_MAX = 31;
    reg[7:0] count = COUNT_MAX;
    
    always @(posedge clk, posedge rst) begin
        if(rst)
            count <= 0;
        else begin
            if(count == 0)
                count <= COUNT_MAX;
            else
                count <= count - 1'd1;
        end
    end
    
    assign dout = (count == 0);
    
    reg[5:0] count_fabric = COUNT_MAX;
    
    always @(posedge clk, posedge rst) begin
        if(rst)
            count_fabric <= 0;
        else begin
            if(count_fabric == 0)
                count_fabric <= COUNT_MAX;
            else
                count_fabric <= count_fabric - 1'd1;
        end
    end
    
    assign dout_fabric = (count_fabric == 0);
endmodule