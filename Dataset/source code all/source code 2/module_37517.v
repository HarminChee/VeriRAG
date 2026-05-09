`timescale 1ns / 1ps
`timescale 1ns / 1ps
module SHDCluster #(parameter DNA_DATA_WIDTH = 128, NUM_PES = 8) (
        input clk,
        input rst,
        input[DNA_DATA_WIDTH - 1:0] dna_in,
        input[DNA_DATA_WIDTH*NUM_PES - 1:0] dna_ref_in,
        input dna_valid_in,
        output dna_rd_en,
        input coll_clk,
        input coll_rd_en,
        output[NUM_PES - 1:0] coll_dna_err,
        output coll_valid
    );
    reg[DNA_DATA_WIDTH - 1:0] dna_r;
    reg dna_valid_r;
    wire pe_fifo_full, pe_fifo_empty;
    always@(posedge clk) begin
        if(rst) begin
            dna_valid_r <= 1'b0;
            dna_r <= 0;
        end
        else begin
            if(~pe_fifo_full) begin
                dna_valid_r <= dna_valid_in;
                dna_r <= dna_in;
            end
        end
    end
    wire[NUM_PES - 1:0] dna_err;
    genvar i;
    generate
        for(i = 0; i < NUM_PES; i = i + 1) begin
            SHD	#(.LENGTH(DNA_DATA_WIDTH)) i_SHD(
                .DNA_read(dna_r),
                .DNA_ref(dna_ref_in[DNA_DATA_WIDTH*i +: DNA_DATA_WIDTH]),    
                .DNA_MinErrors(dna_err[i])
            );
        end
    endgenerate
    shd_pe_fifo i_pe_fifo (
      .wr_clk(clk),      
      .rd_clk(coll_clk),
      .rst(rst),    
      .din(dna_err),      
      .wr_en(~pe_fifo_full && dna_valid_r),  
      .rd_en(coll_rd_en & coll_valid),  
      .dout(coll_dna_err),    
      .full(pe_fifo_full),    
      .empty(pe_fifo_empty)  
    );
    assign dna_rd_en = ~pe_fifo_full;
    assign coll_valid = ~pe_fifo_empty;
endmodule
