`default_nettype none
`default_nettype wire
`default_nettype none
module gci_std_display_sync_fifo #(
		parameter P_N = 16,
		parameter P_DEPTH = 4,
		parameter P_DEPTH_N = 2
	)(
		input iCLOCK,
		input inRESET,
		input iREMOVE,
		output [P_DEPTH_N:0] oCOUNT,
		input iWR_EN,
		input [P_N-1:0] iWR_DATA,
		output oWR_FULL,
		output oWR_ALMOST_FULL,
		input iRD_EN,
		output [P_N-1:0] oRD_DATA,
		output oRD_EMPTY,
		output oRD_ALMOST_EMPTY
	);
	reg [P_DEPTH_N:0] b_write_pointer;
	reg [P_DEPTH_N:0] b_read_pointer;
	reg [P_N-1:0] b_memory [0:P_DEPTH-1];
	wire [P_DEPTH_N:0] count = b_write_pointer - b_read_pointer;
	wire full = count[P_DEPTH_N];
	wire empty = (count == {P_DEPTH_N+1{1'b0}})? 1'b1 : 1'b0;
	wire almost_full = full || (count[P_DEPTH_N-1:0] == {P_DEPTH_N{1'b1}});
	wire almost_empty = empty || (count[P_DEPTH_N:0] == {{P_DEPTH_N{1'b0}}, 1'b1});
	wire read_condition = iRD_EN && !empty;
	wire write_condition = iWR_EN && !full;
	always@(posedge iCLOCK)begin
		if(write_condition)begin
			b_memory [b_write_pointer[P_DEPTH_N-1:0]] <= iWR_DATA;
		end
	end 
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_write_pointer <= {P_DEPTH_N+1{1'b0}};
		end
		else if(iREMOVE)begin
			b_write_pointer <= {P_DEPTH_N+1{1'b0}};
		end
		else begin
			if(write_condition)begin
				b_write_pointer <= b_write_pointer + {{P_DEPTH_N-1{1'b0}}, 1'b1};				
			end
		end
	end 
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_read_pointer <= {P_DEPTH_N+1{1'b0}};
		end
		else if(iREMOVE)begin
			b_read_pointer <= {P_DEPTH_N+1{1'b0}};
		end
		else begin
			if(read_condition)begin
				b_read_pointer <= b_read_pointer + {{P_DEPTH_N-1{1'b0}}, 1'b1};
			end
		end
	end 
	assign oRD_DATA = b_memory[b_read_pointer[P_DEPTH_N-1:0]];
	assign oRD_EMPTY = empty;
	assign oRD_ALMOST_EMPTY = almost_empty;
	assign oWR_FULL = full;
	assign oWR_ALMOST_FULL = almost_full;
	assign oCOUNT = count[P_DEPTH_N:0];
endmodule
`default_nettype wire
