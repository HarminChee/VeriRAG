module qdec (
    input  wire       test_i,
    input  wire       rst_n,
    input  wire       freq_clk,
    input  wire       enable,
    output wire       pha,
    output wire       phb,
    output wire       index,
    output wire       led
);

reg pha_reg;
reg phb_reg;
reg index_reg;
reg [7:0] pha_count;
reg led;
reg [31:0] count_reg;
reg out_200hz;
wire dft_rst_n;
wire dft_freq_clk;

assign dft_rst_n = test_i ? rst_n : rst_n;
assign dft_freq_clk = test_i ? freq_clk : freq_clk;

always @(posedge dft_freq_clk or negedge dft_rst_n) begin
    if (!dft_rst_n) begin
        count_reg <= 0;
        out_200hz <= 0;
    end 
    else if (enable) begin
        if (count_reg < 124999) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            out_200hz <= ~out_200hz;
        end
    end
end

always @(posedge out_200hz or negedge dft_rst_n) begin
    if (!dft_rst_n) begin
        pha_count <= 8'd0;
        led <= 1'b0; 
    end
    else if (out_200hz) begin
        led <= ~led; 
        if (pha_count > 8'd24)
            pha_count <= 8'd0;
        else
            pha_count <= pha_count + 8'd1;
    end
end

reg [1:0] Phase90_Count;

always @(posedge out_200hz or negedge dft_rst_n) begin
    if (!dft_rst_n) begin
        Phase90_Count <= 2'b0;
    end
    else if (out_200hz) begin
        case (Phase90_Count)
            2'd0: begin
                pha_reg <= 1'd1;
                phb_reg <= 1'd1;
                Phase90_Count <= Phase90_Count + 2'd1;
            end
            2'd1: begin
                Phase90_Count <= Phase90_Count + 2'd1;
            end
            2'd2: begin
                pha_reg <= 1'd0;
                phb_reg <= 1'd0;
                Phase90_Count <= Phase90_Count + 2'd1;
            end
            2'd3: begin
                Phase90_Count <= 2'd0;
            end
        endcase
    end
end

assign pha = pha_reg;
assign phb = phb_reg;

always @(posedge out_200hz or negedge dft_rst_n) begin
    if (!dft_rst_n) begin
        index_reg <= 1'b0;
    end
    else if (out_200hz) begin
        case (pha_count)
            8'd23: index_reg <= 1'd1;
            8'd24: index_reg <= 1'd1;
            default: index_reg <= 1'd0;
        endcase
    end
end

assign index = index_reg;

endmodule