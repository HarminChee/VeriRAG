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
    input SE;
    input SI;
    output SO;
    input clk;                      
    input ena;                      
    input dstrb;                    
    input [di_width-1:0] din;
    input [7:0] qnt_val;   
    output reg [5:0] qnt_cnt;          
    output [3:0] size;    
    output [3:0] rlen;    
    output [11:0] amp;     
    output douten;  
    wire rst = 1'b1;                      
    wire fdct_doe, qnr_doe;
    wire [11:0] fdct_dout;
    reg  [11:0] dfdct_dout;
    wire [10:0] qnr_dout;
    reg  dqnr_doe;

    fdct #(coef_width, di_width, 12)
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
        dfdct_dout <= fdct_dout;

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
        dqnr_doe <= qnr_doe;

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
        .douten(douten),
        .bstart(1'b0)
    );
endmodule