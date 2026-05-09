`timescale 1ns / 1ns
`timescale 1ns / 1ns
module altera_tse_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in ,
    input   clk,
    output  reset_out
);
    (* ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \" set_false_path -to [get_pins -compatibility_mode -nocase *altera_tse_reset_synchronizer_chain*|aclr]; set_false_path -to [get_pins -compatibility_mode -nocase *altera_tse_reset_synchronizer_chain*|clrn] \"" *) (*preserve*) reg [DEPTH-1:0] altera_tse_reset_synchronizer_chain;
    generate if (ASYNC_RESET) begin
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_tse_reset_synchronizer_chain <= {DEPTH{1'b1}};
            end
            else begin
                altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
                altera_tse_reset_synchronizer_chain[DEPTH-1] <= 0;
            end
        end
        assign reset_out = altera_tse_reset_synchronizer_chain[0];
    end else begin
        always @(posedge clk) begin
            altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
            altera_tse_reset_synchronizer_chain[DEPTH-1] <= reset_in;
        end
        assign reset_out = altera_tse_reset_synchronizer_chain[0];
    end
    endgenerate
endmodule
