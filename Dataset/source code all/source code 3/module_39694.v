`timescale 1 ns / 10 ps
  module vga_hint
    (
     input		hclk,		
     input		resetn,		
     input		vga_req_0,	
     input		vga_rdwr,	
     input		vga_mem,	
     input	[3:0]	hst_byte,	
     input	[31:0]	hst_din,	
     input	[22:0]	hst_addr,	
     input		mclock,		
     input	[31:0]	vga_hst_dout,	
     input		vga_ready_n,	
     output reg	[31:0]	hst_dout,	
     output reg	[31:0]	vga_hst_din,	
     output reg	[22:0]	haddr,		
     output		vga_sel,	
     output reg		hst_rd_wr,	
     output reg	[3:0]	byte_en,	
     output reg		hst_mem_io,	
     output reg		vga_ready_2,
     output reg		vga_push_1
     );
  reg [2:0] 		cstate, nstate;
  reg 			done_0, done_1;
  reg 			toggle_req, toggle_done;
  reg 			req0, req1;
  reg 			vga_push_0;
  wire 			svga_req;	
  wire 			vga_clear;
  parameter 		
			vga_0 = 3'b010,
			vga_1 = 3'b110,
			vga_2 = 3'b011,
			vga_3 = 3'b001;
  always @(posedge hclk)
    if (vga_req_0) begin
      vga_hst_din  <= hst_din;
      haddr        <= hst_addr;
      hst_rd_wr    <= vga_rdwr;
      hst_mem_io   <= vga_mem;
      byte_en      <= hst_byte;
    end
  always @(posedge hclk or negedge resetn)
    if (!resetn) begin
      toggle_req  <= 1'b0;
      vga_ready_2 <= 1'b1;
      done_0      <= 1'b0;
      done_1      <= 1'b0;
    end else begin
      done_0 <= toggle_done;
      done_1 <= done_0;
      if (vga_req_0) begin
	toggle_req  <= ~toggle_req;
	vga_ready_2 <= 1'b0;
      end else if (done_0 ^ done_1) vga_ready_2 <= 1'b1;
    end
  always @(posedge mclock or negedge resetn)
    if (!resetn) begin
      toggle_done <= 1'b0;
      req0 <= 1'b0;
      req1 <= 1'b0;
    end else begin
      req0 <= toggle_req;
      req1 <= req0;
      if (~vga_clear) toggle_done <= ~toggle_done;
    end
  always @(posedge mclock or negedge resetn)
    if (!resetn) cstate <= vga_0;
    else	 cstate <= nstate;
  assign svga_req = req0 ^ req1;
  always @* begin
    nstate = vga_0;
    case(cstate)
      vga_0: begin
	if (svga_req)     nstate = vga_1;
	else              nstate = vga_0;
      end 
      vga_1:              nstate = vga_2;
      vga_2: begin
	if (!vga_ready_n) nstate = vga_3;
	else              nstate = vga_2;
      end 
      vga_3:              nstate = vga_0;
      default:            nstate = vga_0; 
    endcase
  end
  assign vga_sel   = cstate[2];
  assign vga_clear = cstate[1];
  always @(posedge mclock) begin
    if (!vga_ready_n) hst_dout <= vga_hst_dout;
    vga_push_1 <= vga_push_0 ;
    vga_push_0 <= ~vga_ready_n & hst_rd_wr;
  end
endmodule
`timescale 1 ns / 10 ps
  module vga_hint
    (
     input		hclk,		
     input		resetn,		
     input		vga_req_0,	
     input		vga_rdwr,	
     input		vga_mem,	
     input	[3:0]	hst_byte,	
     input	[31:0]	hst_din,	
     input	[22:0]	hst_addr,	
     input		mclock,		
     input	[31:0]	vga_hst_dout,	
     input		vga_ready_n,	
     output reg	[31:0]	hst_dout,	
     output reg	[31:0]	vga_hst_din,	
     output reg	[22:0]	haddr,		
     output		vga_sel,	
     output reg		hst_rd_wr,	
     output reg	[3:0]	byte_en,	
     output reg		hst_mem_io,	
     output reg		vga_ready_2,
     output reg		vga_push_1
     );
  reg [2:0] 		cstate, nstate;
  reg 			done_0, done_1;
  reg 			toggle_req, toggle_done;
  reg 			req0, req1;
  reg 			vga_push_0;
  wire 			svga_req;	
  wire 			vga_clear;
  parameter 		
			vga_0 = 3'b010,
			vga_1 = 3'b110,
			vga_2 = 3'b011,
			vga_3 = 3'b001;
  always @(posedge hclk)
    if (vga_req_0) begin
      vga_hst_din  <= hst_din;
      haddr        <= hst_addr;
      hst_rd_wr    <= vga_rdwr;
      hst_mem_io   <= vga_mem;
      byte_en      <= hst_byte;
    end
  always @(posedge hclk or negedge resetn)
    if (!resetn) begin
      toggle_req  <= 1'b0;
      vga_ready_2 <= 1'b1;
      done_0      <= 1'b0;
      done_1      <= 1'b0;
    end else begin
      done_0 <= toggle_done;
      done_1 <= done_0;
      if (vga_req_0) begin
	toggle_req  <= ~toggle_req;
	vga_ready_2 <= 1'b0;
      end else if (done_0 ^ done_1) vga_ready_2 <= 1'b1;
    end
  always @(posedge mclock or negedge resetn)
    if (!resetn) begin
      toggle_done <= 1'b0;
      req0 <= 1'b0;
      req1 <= 1'b0;
    end else begin
      req0 <= toggle_req;
      req1 <= req0;
      if (~vga_clear) toggle_done <= ~toggle_done;
    end
  always @(posedge mclock or negedge resetn)
    if (!resetn) cstate <= vga_0;
    else	 cstate <= nstate;
  assign svga_req = req0 ^ req1;
  always @* begin
    nstate = vga_0;
    case(cstate)
      vga_0: begin
	if (svga_req)     nstate = vga_1;
	else              nstate = vga_0;
      end 
      vga_1:              nstate = vga_2;
      vga_2: begin
	if (!vga_ready_n) nstate = vga_3;
	else              nstate = vga_2;
      end 
      vga_3:              nstate = vga_0;
      default:            nstate = vga_0; 
    endcase
  end
  assign vga_sel   = cstate[2];
  assign vga_clear = cstate[1];
  always @(posedge mclock) begin
    if (!vga_ready_n) hst_dout <= vga_hst_dout;
    vga_push_1 <= vga_push_0 ;
    vga_push_0 <= ~vga_ready_n & hst_rd_wr;
  end
endmodule
