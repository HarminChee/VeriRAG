`timescale 1ns / 1ps
module colour_gen(input clk, input[9:0] x, input[9:0] y, input[0:13] d, output reg[4:0] addr_row,
                  output reg[9:0] r, output reg[9:0] g, output reg[9:0] b, input rst);
reg[0:13] row_buf;
reg[4:0] ycount;
always @(posedge clk)
    row_buf <= d;
always @(posedge clk)
begin
    if(x == 640 && y < 480)
        ycount <= ycount+5'd1;
    if(ycount == 24) begin
        ycount <= 0;
        addr_row <= addr_row+5'd1;
    end
    if(addr_row == 19 && ycount == 24)
        addr_row <= 0;
    if(rst) begin
        addr_row <= 0;
        ycount <= 0;
    end
end
always @(posedge clk)
begin
    if(x > 639 || y > 479) begin
        r <= 0;
        g <= 0;
        b <= 0;
    end
    else if(x < 152 || x >= 488) begin
        r <= {8'd136,2'b0};
        g <= {8'd138,2'b0};
        b <= {8'd133,2'b0};
    end
    else if(x < 176) begin
        if(row_buf[0]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 200) begin
        if(row_buf[1]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 224) begin
        if(row_buf[2]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 248) begin
        if(row_buf[3]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 272) begin
        if(row_buf[4]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 296) begin
        if(row_buf[5]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 320) begin
        if(row_buf[6]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 344) begin
        if(row_buf[7]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 368) begin
        if(row_buf[8]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 392) begin
        if(row_buf[9]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 416) begin
        if(row_buf[10]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 440) begin
        if(row_buf[11]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 464) begin
        if(row_buf[12]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 488) begin
        if(row_buf[13]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
end
endmodule
`timescale 1ns / 1ps
module sync_gen(input clk, output h_sync, output v_sync, output blank,
                input gfx_clk, output[9:0] x, output[9:0] y, input rst);
reg[9:0] hcount, vcount;
assign h_sync = hcount < 96 ? 1'b0 : 1'b1;
assign v_sync = vcount < 2 ? 1'b0 : 1'b1;
assign blank = h_sync & v_sync;
assign x = hcount - 10'd144; 
assign y = vcount - 10'd34;
always @(posedge gfx_clk)
begin
    if(hcount < 800)
        hcount <= hcount+10'd1;
    else begin
        hcount <= 0;
        vcount <= vcount+10'd1;
    end
    if(vcount == 525)
        vcount <= 0;
    if(rst) begin
        hcount <= 0;
        vcount <= 0;
    end
end
endmodule
module colour_gen(input clk, input[9:0] x, input[9:0] y, input[0:13] d, output reg[4:0] addr_row,
                  output reg[9:0] r, output reg[9:0] g, output reg[9:0] b, input rst);
reg[0:13] row_buf;
reg[4:0] ycount;
always @(posedge clk)
    row_buf <= d;
always @(posedge clk)
begin
    if(x == 640 && y < 480)
        ycount <= ycount+5'd1;
    if(ycount == 24) begin
        ycount <= 0;
        addr_row <= addr_row+5'd1;
    end
    if(addr_row == 19 && ycount == 24)
        addr_row <= 0;
    if(rst) begin
        addr_row <= 0;
        ycount <= 0;
    end
end
always @(posedge clk)
begin
    if(x > 639 || y > 479) begin
        r <= 0;
        g <= 0;
        b <= 0;
    end
    else if(x < 152 || x >= 488) begin
        r <= {8'd136,2'b0};
        g <= {8'd138,2'b0};
        b <= {8'd133,2'b0};
    end
    else if(x < 176) begin
        if(row_buf[0]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 200) begin
        if(row_buf[1]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 224) begin
        if(row_buf[2]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 248) begin
        if(row_buf[3]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 272) begin
        if(row_buf[4]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 296) begin
        if(row_buf[5]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 320) begin
        if(row_buf[6]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 344) begin
        if(row_buf[7]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 368) begin
        if(row_buf[8]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 392) begin
        if(row_buf[9]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 416) begin
        if(row_buf[10]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 440) begin
        if(row_buf[11]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 464) begin
        if(row_buf[12]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
    else if(x < 488) begin
        if(row_buf[13]) begin
            r <= {8'd115,2'b0}; g <= {8'd210,2'b0}; b <= {8'd22,2'b0};
        end
        else begin
            r <= {8'd85,2'b0}; g <= {8'd87,2'b0}; b <= {8'd83,2'b0};
        end
    end
end
endmodule
