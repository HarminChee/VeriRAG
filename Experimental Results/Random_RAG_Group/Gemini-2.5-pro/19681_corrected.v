module qdec(
    input test_i, // Added test input for DFT
    input rst_n,
    input freq_clk,
    input enable,
    output pha,
    output phb,
    output index,
    output led
);

reg pha_reg;
reg phb_reg;
reg index_reg;
reg[7:0] pha_count;

//debug led
reg led;

// generate 100 Hz from 50 MHz using clock enable
reg [31:0] count_reg;
reg clk_enable_200hz; // Clock enable signal

// Generate clock enable signal pulsed for one freq_clk cycle at 200 Hz rate
always @(posedge freq_clk or negedge rst_n) begin
    if (!rst_n) begin
        count_reg <= 32'd0;
        clk_enable_200hz <= 1'b0;
    end
    else if (enable) begin
        clk_enable_200hz <= 1'b0; // Default to low
        if (count_reg < 124999) begin // Count cycles of freq_clk (50MHz / 2 / 125000 = 200Hz)
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 32'd0;
            clk_enable_200hz <= 1'b1; // Pulse enable high
        end
    end else begin
         // If not enabled, hold the counter and keep enable low
         count_reg <= count_reg;
         clk_enable_200hz <= 1'b0;
    end
end

/*
  we will be generating waveform like below
        _   _
  pha  | |_| |_
         _   _
  phb  _| |_| |_
                                 _
  home <every 12 clock of pha> _| |_
                                  _
  index <every 12 clock of pha> _| |_
*/

/* process the pha_count - clocked by primary clock, enabled by clk_enable_200hz */
always @ (posedge freq_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		pha_count <= 8'd0;
		led <= 1'b0;
	end
	else if (clk_enable_200hz) // Use clock enable
	begin
	   led <= ~led;
		if(pha_count > 8'd24)
			pha_count <= 8'd0;
		else
			pha_count <= pha_count + 8'd1;
	end
end

reg[1:0] Phase90_Count;
/* process the pha signal - clocked by primary clock, enabled by clk_enable_200hz */
always @ (posedge freq_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		Phase90_Count <= 2'b0;
        // Explicitly reset outputs controlled by this block
        pha_reg <= 1'b0;
        phb_reg <= 1'b0;
	end
	else if (clk_enable_200hz) // Use clock enable
	begin
		case (Phase90_Count)
			2'd0:
			begin
                pha_reg <=  1'd1;
                phb_reg <=  1'd1;
                Phase90_Count <= Phase90_Count + 2'd1;
			end
			2'd1:
			begin
                // Hold pha_reg, phb_reg
                Phase90_Count <= Phase90_Count + 2'd1;
			end
			2'd2:
			begin
                pha_reg <=  1'd0;
                phb_reg <=  1'd0;
                Phase90_Count <= Phase90_Count + 2'd1;
			end
			2'd3:
			begin
                // Hold pha_reg, phb_reg
                Phase90_Count <= 2'd0;
			end
            default: Phase90_Count <= 2'b0; // Avoid latch
		endcase
	end
end
assign pha = pha_reg;
assign phb = phb_reg;


/* process the index signal - clocked by primary clock, enabled by clk_enable_200hz */
always @ (posedge freq_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		index_reg <= 1'b0;
	end
	else if (clk_enable_200hz) // Use clock enable
	begin
        // index_reg depends on the value of pha_count updated in the same enabled cycle
        // Due to non-blocking assignments, pha_count used here is the value *before* the update in this cycle.
		case (pha_count)
			8'd23:	index_reg <=  1'd1;
			8'd24:	index_reg <=  1'd1;
			default: index_reg <=  1'd0;
		endcase
	end
end
assign index = index_reg;

endmodule