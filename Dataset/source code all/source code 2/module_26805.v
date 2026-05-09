`timescale 1ns/1ps
`timescale 1ns/1ps
module dphy_lane
  (
   input 	    clk_i,
   input 	    rst_n_i,
   input 	    tick_i,
   input 	    hs_request_i,
   input [3:0]	    hs_valid_i,
   input [31:0]     hs_data_i,
   output reg 	    hs_ready_o,
   input 	    lp_request_i,
   input [7:0] 	    lp_data_i,
   input 	    lp_valid_i,
   output reg 	    lp_ready_o,
   output reg 	    idle_o,
   output reg [7:0] serdes_data_o,
   output reg 	    serdes_oe_o,
   input [1:0] 	    lane_sel_i,
   input 	    lane_invert_i,
   output 	    lp_txp_o,
   output 	    lp_txn_o,
   output reg 	    lp_oe_o
   );
`define LP_ACTIVE 0
`define LP_POWERUP 1
`define LP_REQUEST_LPDT0 2
`define LP_REQUEST_LPDT1 3
`define LP_REQUEST_LPDT2 4
`define LP_REQUEST_LPDT3 5
`define LP_WAIT_TX 6
`define LP_START_TX 7
`define LP_NEXT_BIT 8
`define LP_MARK_BIT 9
`define LP_EXIT0 10
`define LP_EXIT1 11
`define LP_SPACE 12
`define LP_REQUEST_HS0 13
`define LP_REQUEST_HS1 14
`define LP_HS_ACTIVE 15
`define LP_HS_EXIT0 16
`define LP_HS_EXIT1 17
`define LP_HS_EXIT2 23
   reg               lp_txp_int, lp_txn_int;
   reg [4:0] 	     lp_state;
   reg [7:0] 	     lp_sreg;
   reg [3:0] 	     tx_count;
   reg               lp_hs_entered;
   reg               serdes_data_lastbit;
   reg [7:0] 	     hs_data_muxed;
   reg 		     hs_valid_muxed;
   reg 		     hs_request_muxed;
   always@(posedge clk_i or negedge rst_n_i)
     if (!rst_n_i) begin
	hs_data_muxed <= 0;
	hs_valid_muxed <= 0;
	hs_request_muxed <= 0;
     end else begin
	case (lane_sel_i)
	  2'b00: begin hs_data_muxed <= hs_data_i[7:0]; hs_valid_muxed <= hs_valid_i[0]; end
	  2'b01: begin hs_data_muxed <= hs_data_i[15:8]; hs_valid_muxed <= hs_valid_i[1]; end
	  2'b10: begin hs_data_muxed <= hs_data_i[23:16]; hs_valid_muxed <= hs_valid_i[2]; end
	  2'b11: begin hs_data_muxed <= hs_data_i[31:24]; hs_valid_muxed <= hs_valid_i[3]; end
	endcase 
	hs_request_muxed <= hs_request_i;
     end
`define LP_TX(txp, txn, next_lp_state) \
   begin lp_oe_o <= 1;\
                    lp_txp_int <= txp;\
                    lp_txn_int <= txn;\
                      if(tick_i)\
                        lp_state <= next_lp_state; end
   always@(posedge clk_i or negedge rst_n_i)
     begin
	if (!rst_n_i) begin
	   lp_state <= `LP_ACTIVE;
           lp_txn_int <= 1;
           lp_txp_int <= 1;
           lp_oe_o <= 0;
           lp_hs_entered <= 0;
           lp_ready_o <= 0;
           idle_o <= 1;
	end else begin
	   case (lp_state)
	     `LP_ACTIVE : begin
                lp_hs_entered <= 0;
	        lp_oe_o <= 1;
                lp_txn_int <= 1;
                lp_txp_int <= 1;
                lp_ready_o <= 0;
                idle_o <= 1;
	        if(tick_i) begin
                   idle_o <= 0;
                   if(lp_request_i)
	             lp_state <= `LP_REQUEST_LPDT0;
                   else if(hs_request_muxed)
                     lp_state <= `LP_REQUEST_HS0;
                   else
                     idle_o <= 1;
                end
             end 
             `LP_REQUEST_HS0: 
               `LP_TX(0,1,`LP_REQUEST_HS1)
             `LP_REQUEST_HS1: 
               `LP_TX(0,0,`LP_HS_ACTIVE)
             `LP_HS_ACTIVE: begin
                lp_oe_o <= 0;
                lp_hs_entered <= 1;
                if(!hs_request_muxed)
                  lp_state <= `LP_HS_EXIT0;
             end
             `LP_HS_EXIT0: 
               if(tick_i) begin
                  lp_txn_int <= 1;
                  lp_txp_int <= 1;
                  lp_state <= `LP_ACTIVE;
               end
             `LP_HS_EXIT1:
               if(tick_i) begin
                  lp_hs_entered <= 0;
                  lp_state <= `LP_HS_EXIT2;
               end
             `LP_HS_EXIT2: begin
                lp_oe_o <= 1;
                lp_txn_int <= 1;
                lp_txp_int <= 1;
                lp_hs_entered <= 0;
                lp_state <= `LP_ACTIVE;
             end
             `LP_REQUEST_LPDT0:
               `LP_TX(1,0,`LP_REQUEST_LPDT1)
             `LP_REQUEST_LPDT1:
               `LP_TX(0,0,`LP_REQUEST_LPDT2)
             `LP_REQUEST_LPDT2:
               `LP_TX(0,1,`LP_REQUEST_LPDT3)
             `LP_REQUEST_LPDT3:
               `LP_TX(0,0,`LP_WAIT_TX)
             `LP_WAIT_TX: 
               lp_state <= `LP_START_TX;
             `LP_START_TX: begin
                if(!lp_request_i) begin
                   lp_state <= `LP_EXIT0;
                   lp_ready_o <= 0;
                end else if (lp_valid_i) begin
                   lp_sreg <= lp_data_i;
                   lp_state <= `LP_NEXT_BIT;
                   tx_count <= 8;
                   lp_ready_o <= 0;
                end else
                  lp_ready_o <= 1;
             end
             `LP_NEXT_BIT: begin
                if(!tx_count)
                  lp_state <= `LP_WAIT_TX;
                else if(tick_i) begin
                   tx_count <= tx_count - 1;
                   lp_txp_int<=lp_sreg[7] ;
                   lp_txn_int<=~lp_sreg[7];
                   lp_sreg <= lp_sreg << 1;
                   lp_state <= `LP_MARK_BIT;
                end
             end 
             `LP_MARK_BIT:
               if(tick_i)begin
                  lp_txp_int <= 0;
                  lp_txn_int <= 0;
                  lp_state <= `LP_SPACE;
               end
             `LP_SPACE:
               if(tick_i)begin
                  lp_state <= `LP_NEXT_BIT;
               end
             `LP_EXIT0:
               `LP_TX(1, 0, `LP_EXIT1)
             `LP_EXIT1:
               `LP_TX(1, 1, `LP_ACTIVE)
	   endcase
	end
     end
   always@(posedge clk_i)
     if(lp_state == `LP_HS_ACTIVE && hs_request_muxed && hs_valid_muxed)
       serdes_data_lastbit <= (lane_invert_i ? ~hs_data_muxed[7] : hs_data_muxed[7]);
   always@(hs_data_muxed, hs_valid_muxed, lp_hs_entered, lp_state, serdes_data_lastbit)
     begin
        if(lp_state == `LP_HS_EXIT0 || lp_state == `LP_HS_EXIT1 || lp_state == `LP_HS_EXIT2)
          serdes_data_o <= {8{~serdes_data_lastbit}};
        else if(hs_valid_muxed)
          serdes_data_o <= (lane_invert_i ? ~hs_data_muxed : hs_data_muxed);
        else
          serdes_data_o <= (lane_invert_i ? 8'hff:8'h00);
        serdes_oe_o <= lp_hs_entered;
     end
   assign lp_txp_o = (lane_invert_i ? lp_txn_int : lp_txp_int);
   assign lp_txn_o = (lane_invert_i ? lp_txp_int : lp_txn_int);
   always@(posedge clk_i)
     if(!rst_n_i)
       hs_ready_o <= 0;
     else if(tick_i && lp_hs_entered) 
       hs_ready_o <= 1;
     else if(!hs_request_muxed) 
       hs_ready_o <= 0;
endmodule
