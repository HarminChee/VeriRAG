`timescale 1ns / 1ps
`timescale 1ns / 1ps
module DECO_CORDIC_EXT #(parameter W = 32)(
   input wire [W-1:0] data_i,
   input wire         operation,
   input wire [1:0]   shift_region_flag,
   output reg         sel_mux_3,
   output reg [W-1:0] data_out_CORDECO
   );
   always @(*) begin
     if(operation == 1'b0)
        begin  
          case (shift_region_flag)
            2'b00  : begin
                        sel_mux_3 = 1'b0;
                        data_out_CORDECO = data_i;
                     end
            2'b01  : begin
                        sel_mux_3 = 1'b1;
                        data_out_CORDECO = {~data_i[W-1],data_i[W-2:0]};
                     end
            2'b10  : begin
                        sel_mux_3 = 1'b1;
                        data_out_CORDECO = data_i;
                     end
            2'b11  : begin
                        sel_mux_3 = 1'b0;
                        data_out_CORDECO = data_i;
                     end
          endcase
        end
      else begin  
          case (shift_region_flag)
            2'b00  : begin
                        sel_mux_3 = 1'b1;
                        data_out_CORDECO = data_i;
                     end
            2'b01  : begin
                        sel_mux_3 = 1'b0;
                        data_out_CORDECO = data_i;
                     end
            2'b10  : begin
                        sel_mux_3 = 1'b0;
                        data_out_CORDECO = {~data_i[W-1],data_i[W-2:0]};;
                     end
            2'b11  : begin
                        sel_mux_3 = 1'b1;
                        data_out_CORDECO = data_i;
                     end 
          endcase
      end
   end
endmodule
