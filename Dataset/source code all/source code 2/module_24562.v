`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module mc_vga
  (
   input	 mclock,        
   input	 v_mclock,      
   input	 reset_n,         
   input         vga_req,       
   input 	 vga_rd_wrn,    
   input [17:0]	 vga_addr,      
   input 	 vga_abort,     
   input [3:0]	 vga_we,        
   input [31:0]  vga_data_in,   
   input 	 vga_gnt,       
   input         vga_pop,       
   input         vga_push,      
   input [31:0]  read_data,     
   input         init_done,     
   output reg	 vga_arb_req,   
   output reg [17:0] vga_arb_addr,  
   output reg 	 vga_arb_read,  
   output reg	 vga_ack,       
   output reg	 vga_ready_n,   
   output [31:0] vga_data_out,  
   output [3:0]  vga_wen,       
   output [31:0] vga_data       
   );
  reg 		 capt_rw;       
  reg 		 out_push;      
  reg 		 out_pop;       
  reg 		 make_req;      
  reg [1:0] 	 out_cs, out_ns; 
  reg [1:0] 	 in_cs;         
  reg 		 rc_pop;         
  reg 		 in_pop;
  reg [1:0] 	 init_sync;     
  wire 		 in_empty;      
  wire 		 out_empty_m;   
  wire 		 out_empty_v;   
  wire 		 out_full_v;    
  wire [56:0] 	 out_vgareq;    
  wire [56:0] 	 ram_data_in;
  wire [3:0] 	 vga_wen_comb;
  wire 		 vga_rd;
  wire [5:0] 	 wrusedw;
  parameter 	VGA      = 3'h6,
		IDLE     = 2'b00,
		REQ      = 2'b01,
		WAIT4GNT = 2'b10,
		WAIT4POP = 2'b11,
		IN_IDLE  = 2'b00,
		IN_POP   = 2'b01,
		IN_RDY   = 2'b10;
  always @(posedge v_mclock or negedge reset_n) begin
    if (!reset_n) begin
      vga_ack         <= 1'b0;
      out_push        <= 1'b0;
      capt_rw         <= 1'b0;
      init_sync       <= 2'b0;
    end else begin
      out_push  <= 1'b0;
      init_sync <= {init_sync[0], init_done};
      if (vga_req && ~vga_ack && ~wrusedw[5]) begin
	capt_rw   <= vga_rd_wrn;
	vga_ack   <= 1'b1;
      end else if (vga_ack) begin
	out_push  <= 1'b1;
	vga_ack   <= 1'b0;
      end
    end
  end
  always @(posedge mclock or negedge reset_n) begin
    if (!reset_n) begin
      vga_arb_req   <= 1'b0;
      out_cs        <= IDLE;
      rc_pop        <= 1'b0;
    end else begin
      rc_pop <= vga_pop;
      out_cs <= out_ns;
      if (make_req && ~vga_gnt) begin
	vga_arb_req  <= 1'b1;
	vga_arb_read <= out_vgareq[54];
	vga_arb_addr <= out_vgareq[53:36];
      end else if (vga_gnt) begin
	vga_arb_req <= 1'b0;
      end
    end
  end
  always @* begin
    out_pop = 1'b0;
    make_req = 1'b0;
    case (out_cs)
      IDLE: begin
	if (~out_empty_m) begin
	  out_pop = 1'b1;
	  out_ns = REQ;
	end else out_ns = IDLE;
      end
      REQ: begin
        make_req = 1'b1;
	if (vga_arb_req) out_ns = WAIT4GNT;
	else out_ns = REQ;
      end
      WAIT4GNT: begin
	if (vga_gnt) begin
	  if (vga_arb_read && ~out_empty_m) begin
	    out_pop = 1'b1;
	    out_ns = REQ;
	  end else if (~vga_arb_read) out_ns = WAIT4POP;
	  else out_ns = IDLE;
	end else out_ns = WAIT4GNT;
      end
      WAIT4POP: begin
	if (rc_pop) begin
	  if (~out_empty_m) begin
	    out_pop = 1'b1;
	    out_ns = REQ;
	  end else out_ns = IDLE;
	end else out_ns = WAIT4POP;
      end
    endcase 
  end
  always @(posedge v_mclock or negedge reset_n)
    if (~reset_n) begin
      vga_ready_n <= 1'b1;
      in_pop      <= 1'b0;
      in_cs       <= IN_IDLE;
    end else begin
      vga_ready_n <= 1'b1;
      case (in_cs)
	IN_IDLE: begin
 	  if (~in_empty & ~in_pop) begin
	    in_pop <= 1'b1;
	    in_cs  <= IN_POP;
	  end
	end
	IN_POP: begin
	  in_pop <= 1'b0;
	  in_cs  <= IN_RDY;
	end
	IN_RDY: begin
	  vga_ready_n <= 1'b0;
	  in_cs  <= IN_IDLE;
	end
	default: in_cs <= IN_IDLE;
      endcase
    end
  assign ram_data_in = {2'b0, capt_rw, vga_addr, vga_we, 
			vga_data_in};
  fifo_57x64 U_outfifo
    (
     .data            (ram_data_in),
     .wrreq           (out_push),
     .rdreq           (out_pop),
     .rdclk           (mclock),
     .wrclk           (v_mclock),
     .aclr            (~reset_n),
     .q               (out_vgareq),
     .rdempty         (out_empty_m),
     .wrfull          (out_full_v),
     .wrempty         (out_empty_v),
     .wrusedw         (wrusedw)
     );
  fifo_32x64a U_infifo
    (
     .data            (read_data),
     .wrreq           (vga_push),
     .rdreq           (in_pop),
     .rdclk           (v_mclock),
     .wrclk           (mclock),
     .aclr            (~reset_n),
     .q               (vga_data),
     .rdempty         (in_empty),
     .wrfull          ()
     );
  assign {vga_wen_comb, vga_data_out} = out_vgareq[35:0];
  assign vga_wen = vga_wen_comb;
endmodule
