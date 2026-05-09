`timescale 1ns / 10ps
`timescale 1ns / 10ps
module  debouncer # (
	parameter C_CLK_PERIOD_NS = 10,
	parameter C_DEBOUNCE_TIME_MSEC = 20
	) 
	(
	input clk, reset_n, data_in,				
	output reg 	debounced_out						
	);
    function integer clogb2;
        input [31:0] value;
        begin
            value = value - 1;
            for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
                value = value >> 1;
            end
        end
    endfunction    
	localparam N = clogb2((C_DEBOUNCE_TIME_MSEC*(10**6))/(C_CLK_PERIOD_NS)); 		
	reg  [N-1 : 0]	reg_q;						
	reg  [N-1 : 0]	next_q;
	reg DFF1, DFF2;								
	wire add_q;									
	wire reset_q;
	assign reset_q = (DFF1  ^ DFF2);		    
	assign add_q = ~(reg_q[N-1]);			    
	always @ (reset_q, add_q, reg_q)
		begin
			case( {reset_q , add_q})
				2'b00 :
						next_q <= reg_q;
				2'b01 :
						next_q <= reg_q + 1;
				default :
						next_q <= { N {1'b0} };
			endcase 	
		end
	always @ ( posedge clk )
		begin
			if(reset_n ==  1'b0)
				begin
					DFF1 <= 1'b0;
					DFF2 <= 1'b0;
					reg_q <= { N {1'b0} };
				end
			else
				begin
					DFF1 <= data_in;
					DFF2 <= DFF1;
					reg_q <= next_q;
				end
		end
	always @ ( posedge clk )
		begin
			if(reg_q[N-1] == 1'b1)
					debounced_out <= DFF2;
			else
					debounced_out <= debounced_out;
		end
endmodule
