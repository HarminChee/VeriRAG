module jpeg_encoder(
    clk,
    ena,
    dstrb,
    din,
    qnt_val,
    qnt_cnt,
    size,
    rlen,
    amp,
    douten,
    SE,
    SI,
    SO
);
    parameter coef_width = 11;
    parameter di_width = 8; 
    
    input clk;                      
    input ena;                      
    input dstrb;                    
    input [di_width-1:0] din;
    input [7:0]          qnt_val;
    input SE;
    input SI;

    output SO;
    output [ 5:0] qnt_cnt;          
    output [ 3:0] size;    
    output [ 3:0] rlen;    
    output [11:0] amp;     
    output        douten;  

    wire rst = 1'b0;                      
    wire fdct_doe, qnr_doe;
    wire [11:0] fdct_dout;
    reg  [11:0] dfdct_dout;
    wire [10:0] qnr_dout;
    reg         dqnr_doe;

    fdct #(coef_width, di_width)
    fdct_zigzag(
        .clk(clk),
        .ena(ena),
        .rst(rst),
        .dstrb(dstrb),
        .din(din),
        .dout(fdct_dout),
        .douten(fdct_doe)
    );

    always @(posedge clk)
      if(ena)
        dfdct_dout <= #1 fdct_dout;

    jpeg_qnr
    qnr(
        .clk(clk),
        .ena(ena),
        .rst(rst),
        .dstrb(fdct_doe),
        .din(dfdct_dout),
        .qnt_val(qnt_val),
        .qnt_cnt(qnt_cnt),
        .dout(qnr_dout),
        .douten(qnr_doe)
    );

    always @(posedge clk)
      if(ena)
        dqnr_doe <= #1 qnr_doe;

    wire [11:0] dc_diff_dout = {qnr_dout[10], qnr_dout};
    wire        dc_diff_doe = dqnr_doe;

    jpeg_rle
    rle(
        .clk(clk),
        .ena(ena),
        .rst(rst),
        .dstrb(dc_diff_doe),
        .din(dc_diff_dout),
        .size(size),
        .rlen(rlen),
        .amp(amp),
        .douten(douten)
    );

endmodule

module fdct(
    clk,
    ena,
    rst,
    dstrb,
    din,
    dout,
    douten
);
    parameter coef_width = 11;
    parameter di_width = 8;

    input clk;
    input ena;
    input rst;
    input dstrb;
    input [di_width-1:0] din;

    output [coef_width-1:0] dout;
    output douten;

    reg [coef_width-1:0] dout;
    reg douten;

    always @(posedge clk) begin
        if (rst) begin
            douten <= 1'b0;
            dout <= 0;
        end else if (ena && dstrb) begin
            douten <= 1'b1;
            dout <= din * 4; 
        end else begin
            douten <= 1'b0;
        end
    end

endmodule

module jpeg_qnr(
    clk,
    ena,
    rst,
    dstrb,
    din,
    qnt_val,
    qnt_cnt,
    dout,
    douten
);
    input clk;
    input ena;
    input rst;
    input dstrb;
    input [11:0] din;
    input [7:0] qnt_val;

    output [ 5:0] qnt_cnt;
    output [10:0] dout;
    output douten;

    reg [ 5:0] qnt_cnt;
    reg [10:0] dout;
    reg douten;

    always @(posedge clk) begin
        if (rst) begin
            douten <= 1'b0;
            dout <= 0;
            qnt_cnt <= 0;
        end else if (ena && dstrb) begin
            douten <= 1'b1;
            dout <= din / qnt_val;
            qnt_cnt <= qnt_cnt + 1;
        end else begin
            douten <= 1'b0;
        end
    end

endmodule

module jpeg_rle(
    clk,
    ena,
    rst,
    dstrb,
    din,
    size,
    rlen,
    amp,
    douten
);
    input clk;
    input ena;
    input rst;
    input dstrb;
    input [11:0] din;

    output [ 3:0] size;
    output [ 3:0] rlen;
    output [11:0] amp;
    output douten;

    reg [ 3:0] size;
    reg [ 3:0] rlen;
    reg [11:0] amp;
    reg douten;

    always @(posedge clk) begin
        if (rst) begin
            douten <= 1'b0;
            size <= 0;
            rlen <= 0;
            amp <= 0;
        end else if (ena && dstrb) begin
            douten <= 1'b1;
            size <= 4;
            rlen <= 2;
            amp <= din;
        end else begin
            douten <= 1'b0;
        end
    end

endmodule