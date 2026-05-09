<xaiArtifact artifact_id="f88decea-62e0-468a-a1b0-7d273914c9d9" artifact_version_id="bd4294fd-3d13-4ca1-8d71-611ef285634c" title="1_corrected_ffc.v" contentType="text/verilog">
module qdec(rst_n, freq_clk, enable, pha, phb, index, led);

input rst_n;
input freq_clk;
input enable;
output pha;
output phb;
output index;
output led;

reg pha_reg;
reg phb_reg;
reg index_reg;
reg[7:0] pha_count;

//debug led
reg led;

// generate 100 Hz from 50 MHz
reg [31:0] count_reg;
reg out_200hz;

always @(posedge freq_clk or negedge rst_n) begin
    if (!rst_n) begin
        count_reg <= 0;
        out_200hz <= 0;
    end 
    else if (enable) 
    begin
        if (count_reg < 124999) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            out_200hz <= ~out_200hz;
        end
    end
end

/* process the pha_count */
always @(posedge freq_clk or negedge rst_n) begin
    if (!rst_n) begin
        pha_count <= 8'd0;
        led <= 1'b0; 
    end
    else if (enable) begin
        if (out_200hz) begin
            led <= ~led; 
            if (pha_count > 8'd24)
                pha_count <= 8'd0;
            else
                pha_count <= pha_count + 8'd1;
        end
    end
end

reg[1:0] Phase90_Count;
/* process the pha signal */
always @(posedge freq_clk or negedge rst_n) begin
    if (!rst_n) begin
        Phase90_Count <= 2'b0;
    end
    else if (enable && out_200hz) begin
        case (Phase90_Count)
            2'd0:   
            begin
                pha_reg <= 1'd1;
                phb_reg <= 1'd1;
                Phase90_Count <= Phase90_Count + 2'd1;
            end
            2'd1: 
            begin
                Phase90_Count <= Phase90_Count + 2'd1;
            end         
            2'd2:   
            begin
                pha_reg <= 1'd0;
                phb_reg <= 1'd0;
                Phase90_Count <= Phase90_Count + 2'd1;
            end
            2'd3: 
            begin
                Phase90_Count <= 2'd0;
            end
        endcase
    end
end
assign pha = pha_reg;
assign phb = phb_reg;

/* process the index signal */
always @(posedge freq_clk or negedge rst_n) begin
    if (!rst_n) begin
        index_reg <= 1'b0;
    end
    else if (enable && out_200hz) begin
        case (pha_count)
            8'd23:  index_reg <= 1'd1;
            8'd24:  index_reg <= 1'd1;
            default: index_reg <= 1'd0;
        endcase
    end
end
assign index = index_reg;

endmodule
</xaiArtifact>