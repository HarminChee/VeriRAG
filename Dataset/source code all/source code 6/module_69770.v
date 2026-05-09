`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_data_fifo_v2_1_7_ndeep_srl #
  (
   parameter         C_FAMILY  = "rtl", 
   parameter         C_A_WIDTH = 1          
   )
  (
   input  wire                 CLK, 
   input  wire [C_A_WIDTH-1:0] A,   
   input  wire                 CE,  
   input  wire                 D,   
   output wire                 Q    
   );
  localparam integer P_SRLASIZE = 5;
  localparam integer P_SRLDEPTH = 32;
  localparam integer P_NUMSRLS  = (C_A_WIDTH>P_SRLASIZE) ? (2**(C_A_WIDTH-P_SRLASIZE)) : 1;
  localparam integer P_SHIFT_DEPTH  = 2**C_A_WIDTH;
  wire [P_NUMSRLS:0]   d_i;
  wire [P_NUMSRLS-1:0] q_i;
  wire [(C_A_WIDTH>P_SRLASIZE) ? (C_A_WIDTH-1) : (P_SRLASIZE-1) : 0] a_i;
  genvar i;
  assign d_i[0] = D;
  assign a_i = A;
  generate
    if (C_FAMILY == "rtl") begin : gen_rtl_shifter
      if (C_A_WIDTH <= P_SRLASIZE) begin : gen_inferred_srl
        reg [P_SRLDEPTH-1:0] shift_reg = {P_SRLDEPTH{1'b0}};
        always @(posedge CLK)
          if (CE)
            shift_reg <= {shift_reg[P_SRLDEPTH-2:0], D};
        assign Q = shift_reg[a_i];
      end else begin : gen_logic_shifter  
        reg [P_SHIFT_DEPTH-1:0] shift_reg = {P_SHIFT_DEPTH{1'b0}};
        always @(posedge CLK)
          if (CE)
            shift_reg <= {shift_reg[P_SHIFT_DEPTH-2:0], D};
        assign Q = shift_reg[a_i];
      end
    end else begin : gen_primitive_shifter
      for (i=0;i<P_NUMSRLS;i=i+1) begin : gen_srls
        SRLC32E
          srl_inst
            (
             .CLK (CLK),
             .A   (a_i[P_SRLASIZE-1:0]),
             .CE  (CE),
             .D   (d_i[i]),
             .Q   (q_i[i]),
             .Q31 (d_i[i+1])
             );
      end
      if (C_A_WIDTH>P_SRLASIZE) begin : gen_srl_mux
        generic_baseblocks_v2_1_0_nto1_mux #
        (
          .C_RATIO         (2**(C_A_WIDTH-P_SRLASIZE)),
          .C_SEL_WIDTH     (C_A_WIDTH-P_SRLASIZE),
          .C_DATAOUT_WIDTH (1),
          .C_ONEHOT        (0)
        )
        srl_q_mux_inst
        (
          .SEL_ONEHOT ({2**(C_A_WIDTH-P_SRLASIZE){1'b0}}),
          .SEL        (a_i[C_A_WIDTH-1:P_SRLASIZE]),
          .IN         (q_i),
          .OUT        (Q)
        );
      end else begin : gen_no_srl_mux
        assign Q = q_i[0];
      end
    end
  endgenerate
endmodule
`default_nettype wire
