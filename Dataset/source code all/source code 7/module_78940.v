`timescale 1ns / 1ns
`timescale 1ns / 1ns
module altera_avalon_st_pipeline_base (
                                       clk,
                                       reset,
                                       in_ready,
                                       in_valid,
                                       in_data,
                                       out_ready,
                                       out_valid,
                                       out_data
                                       );
   parameter  SYMBOLS_PER_BEAT  = 1;
   parameter  BITS_PER_SYMBOL   = 8;
   parameter  PIPELINE_READY    = 1;
   localparam DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;
   input clk;
   input reset;
   output in_ready;
   input  in_valid;
   input [DATA_WIDTH-1:0] in_data;
   input                  out_ready;
   output                 out_valid;
   output [DATA_WIDTH-1:0] out_data;
   reg                     full0;
   reg                     full1;
   reg [DATA_WIDTH-1:0]    data0;
   reg [DATA_WIDTH-1:0]    data1;
   assign out_valid = full1;
   assign out_data  = data1;    
   generate if (PIPELINE_READY == 1) 
     begin : REGISTERED_READY_PLINE
        assign in_ready  = !full0;
        always @(posedge clk, posedge reset) begin
           if (reset) begin
              data0 <= {DATA_WIDTH{1'b0}};
              data1 <= {DATA_WIDTH{1'b0}};
           end else begin
              if (~full0)
                data0 <= in_data;
              if (~full1 || (out_ready && out_valid)) begin
                 if (full0)
                   data1 <= data0;
                 else
                   data1 <= in_data;
              end
           end
        end
        always @(posedge clk or posedge reset) begin
           if (reset) begin
              full0    <= 1'b0;
              full1    <= 1'b0;
           end else begin
              if (~full0 & ~full1) begin
                 if (in_valid) begin
                    full1 <= 1'b1;
                 end
              end 
              if (full1 & ~full0) begin
                 if (in_valid & ~out_ready) begin
                    full0 <= 1'b1;
                 end
                 if (~in_valid & out_ready) begin
                    full1 <= 1'b0;
                 end
              end 
              if (full1 & full0) begin
                 if (out_ready) begin
                    full0 <= 1'b0;
                 end
              end 
           end
        end
     end 
   else 
     begin : UNREGISTERED_READY_PLINE
	assign in_ready = (~full1) | out_ready;
	always @(posedge clk or posedge reset) begin
	   if (reset) begin
	      data1 <= 'b0;
	      full1 <= 1'b0;
	   end
	   else begin
	      if (in_ready) begin
		 data1 <= in_data;
		 full1 <= in_valid;
	      end
	   end
	end		
     end
   endgenerate
endmodule
