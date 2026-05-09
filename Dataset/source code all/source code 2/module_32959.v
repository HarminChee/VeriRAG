`timescale 1ns / 1ps
`define STOP_SW1 3
`define STOP_SW2 4
`timescale 1ns / 1ps
`define STOP_SW1 3
`define STOP_SW2 4
module Simple_KOA_STAGE_1
    #(parameter SW = 24)
    (
    input wire clk,
    input wire rst,
    input wire load_b_i,
    input wire [SW-1:0] Data_A_i,
    input wire [SW-1:0] Data_B_i,
    output wire [2*SW-1:0] sgf_result_o
    );
    wire [1:0] zero1;
    wire [3:0] zero2;
    assign zero1 = 2'b00;
    assign zero2 = 4'b0000;
    wire [SW/2-1:0] rightside1;
    wire [SW/2:0] rightside2;
    wire [SW/2-3:0] leftside1;
    wire [SW/2-4:0] leftside2;
 reg [4*(SW/2)+2:0] Result;
    reg [4*(SW/2)-1:0] sgf_r;
    assign rightside1 = {(SW/2){1'b0}};
    assign rightside2 = {(SW/2+1){1'b0}};
    assign leftside1 = {(SW/2-4){1'b0}}; 
    assign leftside2 = {(SW/2-5){1'b0}};
    localparam half = SW/2;
generate
    case (SW%2)
        0:begin : EVEN1
            reg [SW/2:0] result_A_adder;
            reg [SW/2:0] result_B_adder;
            wire [SW-1:0] Q_left;
            wire [SW-1:0] Q_right;
            wire [SW+1:0] Q_middle;
            reg [2*(SW/2+2)-1:0] S_A;
            reg [SW+1:0] S_B; 
          cmult #(.SW(SW/2)) left(
                .Data_A_i(Data_A_i[SW-1:SW-SW/2]),
                .Data_B_i(Data_B_i[SW-1:SW-SW/2]),
                .Data_S_o(Q_left)
            );
          cmult #(.SW(SW/2)) right(
                .Data_A_i(Data_A_i[SW-SW/2-1:0]),
                .Data_B_i(Data_B_i[SW-SW/2-1:0]),
                .Data_S_o(Q_right)
            );
          cmult #(.SW((SW/2)+1)) middle (
                .Data_A_i(result_A_adder),
                .Data_B_i(result_B_adder),
                .Data_S_o(Q_middle)
            );
           always @* begin : EVEN
                 result_A_adder <= (Data_A_i[((SW/2)-1):0] + Data_A_i[(SW-1) -: SW/2]);
                 result_B_adder <= (Data_B_i[((SW/2)-1):0] + Data_B_i[(SW-1) -: SW/2]);
                 S_B <= (Q_middle - Q_left - Q_right);
                 Result[4*(SW/2):0] <= {leftside1,S_B,rightside1} + {Q_left,Q_right};
           end
       RegisterAdd #(.W(4*(SW/2))) finalreg ( 
                .clk(clk), 
                .rst(rst), 
                .load(load_b_i), 
                .D(Result[4*(SW/2)-1:0]), 
                .Q({sgf_result_o})
            );
        end
    1:begin : ODD1
                reg [SW/2+1:0] result_A_adder;
                reg [SW/2+1:0] result_B_adder;
                wire [2*(SW/2)-1:0]   Q_left;
                wire [2*(SW/2+1)-1:0] Q_right;
                wire [2*(SW/2+2)-1:0] Q_middle;
                reg [2*(SW/2+2)-1:0] S_A;
                reg [SW+4-1:0] S_B;
          cmult #(.SW(SW/2)) left(
                .Data_A_i(Data_A_i[SW-1:SW-SW/2]),
                .Data_B_i(Data_B_i[SW-1:SW-SW/2]),
                .Data_S_o(Q_left)
            );
          cmult #(.SW(SW/2+1)) right(
                .Data_A_i(Data_A_i[SW-SW/2-1:0]),
                .Data_B_i(Data_B_i[SW-SW/2-1:0]),
                .Data_S_o(Q_right)
            );
          cmult #(.SW(SW/2+2)) middle (
                .Data_A_i(result_A_adder),
                .Data_B_i(result_B_adder),
                .Data_S_o(Q_middle)
            );
            always @* begin : ODD
                 result_A_adder <= (Data_A_i[SW-SW/2-1:0] + Data_A_i[SW-1:SW-SW/2]);
                 result_B_adder <= Data_B_i[SW-SW/2-1:0] + Data_B_i[SW-1:SW-SW/2];
                 S_B <= (Q_middle - Q_left - Q_right);
                 Result[4*(SW/2)+2:0]<= {leftside2,S_B,rightside2} + {Q_left,Q_right};
           end
        RegisterAdd #(.W(4*(SW/2)+2)) finalreg ( 
                    .clk(clk), 
                    .rst(rst), 
                    .load(load_b_i), 
                    .D(Result[2*SW-1:0]), 
                    .Q({sgf_result_o})
                );
        end
    endcase
endgenerate
endmodule
