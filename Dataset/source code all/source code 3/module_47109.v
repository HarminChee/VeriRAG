`timescale 1ns/1ps
`timescale 1ns/1ps
module  ahci_dma_rd_fifo#(
    parameter WCNT_BITS    = 21,
    parameter ADDRESS_BITS = 3
)(
    input                 mrst,
    input                 hrst,
    input                 mclk,
    input                 hclk,
    input [WCNT_BITS-1:0] wcnt,  
    input           [1:0] woffs, 
    input                 start, 
    input          [63:0] din,
    input                 din_av,
    input                 din_av_many,
    input                 last_prd, 
    output                din_re,
    output reg            done,        
    output                done_flush,  
    output         [31:0] dout,
    output                dout_vld,
    input                 dout_re,
    output                last_DW      
    ,output [31:0] debug_dma_h2d
);
    localparam ADDRESS_NUM = (1<<ADDRESS_BITS); 
    reg   [ADDRESS_BITS : 0] waddr; 
    reg   [ADDRESS_BITS+1:0] raddr_r; 
    wire  [ADDRESS_BITS+1:0] raddr_w; 
    reg              [63:16] din_prev; 
    reg      [WCNT_BITS-3:0] qwcntr;
    reg                      busy;
    wire               [2:0] end_offs = wcnt[1:0] + woffs;
    reg               [63:0] fifo_ram  [0: ADDRESS_NUM - 1];
    reg                [3:0] vld_ram   [0: ADDRESS_NUM - 1];
    reg [(1<<ADDRESS_BITS)-1:0] fifo_full;  
    reg [(1<<ADDRESS_BITS)-1:0] fifo_nempty;
    wire                     fifo_wr;
    wire                     fifo_rd;
    reg                [1:0] fifo_rd_r;
    reg                      mrst_hclk;
    wire [(1<<ADDRESS_BITS)-1:0] fifo_full2 =       {~fifo_full[0],fifo_full[ADDRESS_NUM-1:1]};
    reg                      fifo_dav;  
    wire                     fifo_dav2_w;   
    reg                      fifo_dav2; 
    reg                      fifo_half_hclk; 
    reg                [1:0] woffs_r;
    wire              [63:0] fifo_di= woffs_r[1]?(woffs_r[0] ? {din[47:0],din_prev[63:48]} : {din[31:0],din_prev[63:32]}):
                                                 (woffs_r[0] ? {din[15:0],din_prev[63:16]} : din[63:0]);
    wire               [3:0] fifo_di_vld;                                             
    reg               [63:0] fifo_do_r;
    reg                [3:0] fifo_do_vld_r;
    reg                      din_av_safe_r;
    reg                      en_fifo_wr;
    reg                [3:0] last_mask;
    wire                     done_flush_mclk;
    reg                      flushing_hclk; 
    reg                      flushing_mclk; 
    wire                     last_fifo_wr;
    assign din_re =  busy && fifo_half_hclk && din_av_safe_r;
    assign fifo_wr = en_fifo_wr && fifo_half_hclk && (din_av_safe_r || !busy);
    assign fifo_di_vld =    last_fifo_wr? last_mask : 4'hf;
    wire [2:0] debug_waddr = waddr[2:0];
    wire [2:0] debug_raddr = raddr_r[3:1];
    wire  [ADDRESS_BITS+1:0] raddr = raddr_r;       
    wire              [63:0] fifo_do =       fifo_do_r;
    wire               [3:0] fifo_do_vld =   fifo_do_vld_r;
    assign fifo_dav2_w = fifo_full2[raddr_w[ADDRESS_BITS:1]] ^ raddr_w[ADDRESS_BITS+1];
    assign last_fifo_wr = !busy || ((qwcntr == 0) && ((woffs == 0) || end_offs[2])); 
    always @ (posedge hclk) begin
        if      (hrst)                      mrst_hclk <= 0;
        else                                mrst_hclk <= mrst;
        if      (mrst_hclk)                 busy <= 0;
        else if (start)                     busy <= 1;
        else if (din_re && (qwcntr == 0))   busy <= 0;
        done <= busy && din_re && (qwcntr == 0);
        if      (mrst_hclk)                 en_fifo_wr <= 0;
        else if (start)                     en_fifo_wr <= (woffs == 0);
        else if (din_re || fifo_wr)         en_fifo_wr <= busy && ((qwcntr != 0) || ((woffs != 0) && !end_offs[2]));
        if       (start) qwcntr <= wcnt[WCNT_BITS-1:2] + end_offs[2];
        else if (din_re) qwcntr <= qwcntr - 1;
        if (start) woffs_r <= woffs;
        if    (mrst_hclk) fifo_full <= 0;
        else if (fifo_wr) fifo_full <= {fifo_full[ADDRESS_NUM-2:0],~waddr[ADDRESS_BITS]};
        if    (mrst_hclk) waddr <= 0;
        else if (fifo_wr) waddr <= waddr+1;
        fifo_half_hclk <= fifo_nempty [waddr[ADDRESS_BITS-1:0]] ^ waddr[ADDRESS_BITS];
        if (din_re) din_prev[63:16] <= din[63:16];
        if (fifo_wr) fifo_ram[waddr[ADDRESS_BITS-1:0]] <= fifo_di;
        if (fifo_wr) vld_ram [waddr[ADDRESS_BITS-1:0]] <= fifo_di_vld;
        if (mrst_hclk) din_av_safe_r <= 0;
        else           din_av_safe_r <= din_av && (din_av_many || !din_re);
        if (start) last_mask <= {&wcnt[1:0], wcnt[1], |wcnt[1:0], 1'b1}; 
        if      (mrst_hclk || done_flush)                                                          flushing_hclk <= 0;
        else if (fifo_wr && last_prd && (((qwcntr == 0) && ((woffs == 0) || !last_prd)) || !busy)) flushing_hclk <= 1;
    end
    assign raddr_w = mrst ? 0 : (raddr_r + fifo_rd);
    always @ (posedge mclk) begin
        fifo_rd_r <= {fifo_rd_r[0],fifo_rd};
        raddr_r <= raddr_w;
        if      (mrst)                fifo_nempty <= {{(ADDRESS_NUM>>1){1'b0}},{(ADDRESS_NUM>>1){1'b1}}};
        else if (fifo_rd && raddr_r[0]) fifo_nempty <= {fifo_nempty[ADDRESS_NUM-2:0], ~raddr_r[ADDRESS_BITS+1] ^ raddr_r[ADDRESS_BITS]};
        fifo_dav <=  fifo_full [raddr_w[ADDRESS_BITS:1]] ^ raddr_w[ADDRESS_BITS+1];
        fifo_dav2 <= fifo_dav2_w; 
        if      (mrst)   flushing_mclk <= 0;
        else             flushing_mclk <= flushing_hclk;
        fifo_do_r <=       fifo_ram [raddr_w[ADDRESS_BITS:1]];
        fifo_do_vld_r <=   vld_ram  [raddr_w[ADDRESS_BITS:1]];
    end
    ahci_dma_rd_stuff ahci_dma_rd_stuff_i (
        .rst      (mrst),                                       
        .clk      (mclk),                                       
        .din_av   (fifo_dav),                                   
        .din_avm_w(fifo_dav2_w),                                
        .din_avm  (fifo_dav2),                                  
        .flushing (flushing_mclk),                              
        .din      (raddr_r[0]?fifo_do_r[63:32]:  fifo_do_r[31:0]),    
        .dm       (raddr_r[0]?fifo_do_vld_r[3:2]:fifo_do_vld_r[1:0]), 
        .din_re   (fifo_rd),                                    
        .flushed  (done_flush_mclk),                            
        .dout     (dout),                                       
        .dout_vld (dout_vld),                                   
        .dout_re  (dout_re),                                    
        .last_DW  (last_DW)                                     
    );
    pulse_cross_clock #(
        .EXTRA_DLY(0)
    ) done_flush_i (
        .rst       (mrst),                               
        .src_clk   (mclk),                               
        .dst_clk   (hclk),                               
        .in_pulse  (done_flush_mclk),                    
        .out_pulse (done_flush),                         
        .busy()                                          
    );
    assign debug_dma_h2d = {
                            14'b0,
                            fifo_rd,
                            raddr_r[4:0],
                            fifo_do_vld_r[3:0],
                            fifo_dav,
                            fifo_dav2_w,
                            fifo_dav2,
                            flushing_mclk,
                            done_flush_mclk,
                            dout_vld,
                            dout_re,
                            last_DW
    };
endmodule
