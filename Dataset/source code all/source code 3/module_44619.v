`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif
`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif
`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif
`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif
module mkTLPCM(pfk,
	       CLK,
	       RST_N,
	       EN_c_request_get,
	       c_request_get,
	       RDY_c_request_get,
	       c_response_put,
	       EN_c_response_put,
	       RDY_c_response_put,
	       s0_request_put,
	       EN_s0_request_put,
	       RDY_s0_request_put,
	       EN_s0_response_get,
	       s0_response_get,
	       RDY_s0_response_get,
	       s1_request_put,
	       EN_s1_request_put,
	       RDY_s1_request_put,
	       EN_s1_response_get,
	       s1_response_get,
	       RDY_s1_response_get);
  input  [13 : 0] pfk;
  input  CLK;
  input  RST_N;
  input  EN_c_request_get;
  output [152 : 0] c_request_get;
  output RDY_c_request_get;
  input  [152 : 0] c_response_put;
  input  EN_c_response_put;
  output RDY_c_response_put;
  input  [152 : 0] s0_request_put;
  input  EN_s0_request_put;
  output RDY_s0_request_put;
  input  EN_s0_response_get;
  output [152 : 0] s0_response_get;
  output RDY_s0_response_get;
  input  [152 : 0] s1_request_put;
  input  EN_s1_request_put;
  output RDY_s1_request_put;
  input  EN_s1_response_get;
  output [152 : 0] s1_response_get;
  output RDY_s1_response_get;
  wire [152 : 0] c_request_get, s0_response_get, s1_response_get;
  wire RDY_c_request_get,
       RDY_c_response_put,
       RDY_s0_request_put,
       RDY_s0_response_get,
       RDY_s1_request_put,
       RDY_s1_response_get;
  wire [152 : 0] pktFork_iport_put, pktFork_oport0_get, pktFork_oport1_get;
  wire pktFork_EN_iport_put,
       pktFork_EN_oport0_get,
       pktFork_EN_oport1_get,
       pktFork_RDY_iport_put,
       pktFork_RDY_oport0_get,
       pktFork_RDY_oport1_get;
  wire [152 : 0] pktMerge_iport0_put, pktMerge_iport1_put, pktMerge_oport_get;
  wire pktMerge_EN_iport0_put,
       pktMerge_EN_iport1_put,
       pktMerge_EN_oport_get,
       pktMerge_RDY_iport0_put,
       pktMerge_RDY_iport1_put,
       pktMerge_RDY_oport_get;
  reg [1 : 0] CASE_pfk_BITS_13_TO_12_0_pfk_BITS_13_TO_12_1_p_ETC__q1;
  wire [13 : 0] x__h110;
  assign c_request_get = pktMerge_oport_get ;
  assign RDY_c_request_get = pktMerge_RDY_oport_get ;
  assign RDY_c_response_put = pktFork_RDY_iport_put ;
  assign RDY_s0_request_put = pktMerge_RDY_iport0_put ;
  assign s0_response_get = pktFork_oport0_get ;
  assign RDY_s0_response_get = pktFork_RDY_oport0_get ;
  assign RDY_s1_request_put = pktMerge_RDY_iport1_put ;
  assign s1_response_get = pktFork_oport1_get ;
  assign RDY_s1_response_get = pktFork_RDY_oport1_get ;
  mkPktFork pktFork(.pfk(x__h110),
		    .CLK(CLK),
		    .RST_N(RST_N),
		    .iport_put(pktFork_iport_put),
		    .EN_iport_put(pktFork_EN_iport_put),
		    .EN_oport0_get(pktFork_EN_oport0_get),
		    .EN_oport1_get(pktFork_EN_oport1_get),
		    .RDY_iport_put(pktFork_RDY_iport_put),
		    .oport0_get(pktFork_oport0_get),
		    .RDY_oport0_get(pktFork_RDY_oport0_get),
		    .oport1_get(pktFork_oport1_get),
		    .RDY_oport1_get(pktFork_RDY_oport1_get));
  mkPktMerge pktMerge(.CLK(CLK),
		      .RST_N(RST_N),
		      .iport0_put(pktMerge_iport0_put),
		      .iport1_put(pktMerge_iport1_put),
		      .EN_iport0_put(pktMerge_EN_iport0_put),
		      .EN_iport1_put(pktMerge_EN_iport1_put),
		      .EN_oport_get(pktMerge_EN_oport_get),
		      .RDY_iport0_put(pktMerge_RDY_iport0_put),
		      .RDY_iport1_put(pktMerge_RDY_iport1_put),
		      .oport_get(pktMerge_oport_get),
		      .RDY_oport_get(pktMerge_RDY_oport_get));
  assign pktFork_iport_put = c_response_put ;
  assign pktFork_EN_iport_put = EN_c_response_put ;
  assign pktFork_EN_oport0_get = EN_s0_response_get ;
  assign pktFork_EN_oport1_get = EN_s1_response_get ;
  assign pktMerge_iport0_put = s0_request_put ;
  assign pktMerge_iport1_put = s1_request_put ;
  assign pktMerge_EN_iport0_put = EN_s0_request_put ;
  assign pktMerge_EN_iport1_put = EN_s1_request_put ;
  assign pktMerge_EN_oport_get = EN_c_request_get ;
  assign x__h110 =
	     { CASE_pfk_BITS_13_TO_12_0_pfk_BITS_13_TO_12_1_p_ETC__q1,
	       pfk[11:0] } ;
  always@(pfk)
  begin
    case (pfk[13:12])
      2'd0, 2'd1, 2'd2:
	  CASE_pfk_BITS_13_TO_12_0_pfk_BITS_13_TO_12_1_p_ETC__q1 = pfk[13:12];
      2'd3: CASE_pfk_BITS_13_TO_12_0_pfk_BITS_13_TO_12_1_p_ETC__q1 = 2'd3;
    endcase
  end
endmodule  
