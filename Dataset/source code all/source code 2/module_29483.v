`timescale 1ns / 1ns
module async_fifo #
  (
   parameter D_WIDTH = 0,    
   parameter A_WIDTH = 0,    
   parameter INIT_WADDR = 0, 
   parameter INIT_RADDR = 0  
   )
   (
    input        rst,      
    input        wr_clk,   
    input        wr_en,    
    input [7:0]  wr_data,  
    input        rd_clk,   
    input        rd_en,    
    output [7:0] rd_data,  
    output       rd_empty, 
    output       rd_full,  
    output       wr_empty, 
    output       wr_full   
    );
   wire [A_WIDTH:0] waddr;     
   wire [A_WIDTH:0] waddr_g;   
   reg [A_WIDTH:0]  waddr_g1;  
   reg [A_WIDTH:0]  waddr_g2;  
   wire [A_WIDTH:0] raddr;     
   wire [A_WIDTH:0] raddr_g;   
   reg [A_WIDTH:0]  raddr_g1;  
   reg [A_WIDTH:0]  raddr_g2;  
   reg [D_WIDTH-1:0] data[0:2^A_WIDTH-1];
   bin_gray_counter #
     (
      .N(A_WIDTH+1),
      .INIT(INIT_WADDR)
      )
   waddr_counter
     (
      .clk(wr_clk),
      .rst(rst),
      .inc(wr_en && !wr_full),
      .binary(waddr),
      .gray(waddr_g)
      );
   bin_gray_counter #
     (
      .N(A_WIDTH+1),
      .INIT(INIT_RADDR)
      )
   addr_counter
     (
      .clk(rd_clk),
      .rst(rst),
      .inc(rd_en && !rd_empty),
      .binary(raddr),
      .gray(raddr_g)
      );
   always @(posedge wr_clk) begin
      raddr_g1 <= raddr_g;
      raddr_g2 <= raddr_g1;
   end
   always @(posedge rd_clk) begin
      waddr_g1 <= waddr_g;
      waddr_g2 <= waddr_g1;
   end
   always @(posedge wr_clk) begin
      if (wr_en && !wr_full) begin
         data[waddr[A_WIDTH-1:0]] <= wr_data;
      end
   end
   assign rd_data = data[raddr[A_WIDTH-1:0]];
   assign wr_empty = (waddr_g ^ raddr_g2) == 0;
   assign rd_empty = (raddr_g ^ waddr_g2) == 0;
   assign wr_full  = (waddr_g ^ raddr_g2) == 3 << (A_WIDTH-1);
   assign rd_full  = (raddr_g ^ waddr_g2) == 3 << (A_WIDTH-1);
endmodule
module ph_reg3
  (
   input        h_rst_b,
   input        h_rd,
   input        h_selectData,
   input        h_phi2,
   input [7:0]  p_data,
   input        p_selectData,
   input        p_phi2,
   input        p_rdnw,
   input        one_byte_mode,
   output [7:0] h_data,
   output       h_data_available,
   output       p_empty,
   output       p_full
   );
   wire         rd_empty;    
   wire         rd_full;     
   wire         wr_empty;    
   wire         wr_full;     
   async_fifo #
     (
      .D_WIDTH(8),
      .A_WIDTH(1),
      .INIT_WADDR(1),
      .INIT_RADDR(0)
      )
   ph_reg3_fifo
     (
      .rst(!h_rst_b),
      .wr_clk(p_phi2),
      .wr_en(p_selectData && !p_rdnw),
      .wr_data(p_data),
      .rd_clk(!h_phi2),
      .rd_en(h_selectData && h_rd),
      .rd_data(h_data),
      .rd_empty(rd_empty),
      .rd_full(rd_full),
      .wr_empty(wr_empty),
      .wr_full(wr_full)
      );
   assign p_empty          = wr_empty;
   assign p_full           = one_byte_mode ? wr_full   : !wr_empty;
   assign h_data_available = one_byte_mode ? !rd_empty : rd_full;
endmodule
`timescale 1ns / 1ns
module bin_gray_counter #
  (
   parameter N = 0,     
   parameter INIT = 0   
   )
   (
    input              clk,
    input              rst,
    input              inc,
    output reg [N-1:0] binary,
    output reg [N-1:0] gray
    );
   wire [N-1:0]        next_binary = binary + 1'b1;
   wire [N-1:0]        next_gray = next_binary ^ (next_binary >> 1);
   always @(posedge clk or posedge rst) begin
      if (rst) begin
         binary <= INIT;
         gray <= INIT ^ (INIT >> 1);
      end else if (inc) begin
         binary <= next_binary;
         gray <= next_gray;
      end
   end
endmodule
module async_fifo #
  (
   parameter D_WIDTH = 0,    
   parameter A_WIDTH = 0,    
   parameter INIT_WADDR = 0, 
   parameter INIT_RADDR = 0  
   )
   (
    input        rst,      
    input        wr_clk,   
    input        wr_en,    
    input [7:0]  wr_data,  
    input        rd_clk,   
    input        rd_en,    
    output [7:0] rd_data,  
    output       rd_empty, 
    output       rd_full,  
    output       wr_empty, 
    output       wr_full   
    );
   wire [A_WIDTH:0] waddr;     
   wire [A_WIDTH:0] waddr_g;   
   reg [A_WIDTH:0]  waddr_g1;  
   reg [A_WIDTH:0]  waddr_g2;  
   wire [A_WIDTH:0] raddr;     
   wire [A_WIDTH:0] raddr_g;   
   reg [A_WIDTH:0]  raddr_g1;  
   reg [A_WIDTH:0]  raddr_g2;  
   reg [D_WIDTH-1:0] data[0:2^A_WIDTH-1];
   bin_gray_counter #
     (
      .N(A_WIDTH+1),
      .INIT(INIT_WADDR)
      )
   waddr_counter
     (
      .clk(wr_clk),
      .rst(rst),
      .inc(wr_en && !wr_full),
      .binary(waddr),
      .gray(waddr_g)
      );
   bin_gray_counter #
     (
      .N(A_WIDTH+1),
      .INIT(INIT_RADDR)
      )
   addr_counter
     (
      .clk(rd_clk),
      .rst(rst),
      .inc(rd_en && !rd_empty),
      .binary(raddr),
      .gray(raddr_g)
      );
   always @(posedge wr_clk) begin
      raddr_g1 <= raddr_g;
      raddr_g2 <= raddr_g1;
   end
   always @(posedge rd_clk) begin
      waddr_g1 <= waddr_g;
      waddr_g2 <= waddr_g1;
   end
   always @(posedge wr_clk) begin
      if (wr_en && !wr_full) begin
         data[waddr[A_WIDTH-1:0]] <= wr_data;
      end
   end
   assign rd_data = data[raddr[A_WIDTH-1:0]];
   assign wr_empty = (waddr_g ^ raddr_g2) == 0;
   assign rd_empty = (raddr_g ^ waddr_g2) == 0;
   assign wr_full  = (waddr_g ^ raddr_g2) == 3 << (A_WIDTH-1);
   assign rd_full  = (raddr_g ^ waddr_g2) == 3 << (A_WIDTH-1);
endmodule
module ph_reg3
  (
   input        h_rst_b,
   input        h_rd,
   input        h_selectData,
   input        h_phi2,
   input [7:0]  p_data,
   input        p_selectData,
   input        p_phi2,
   input        p_rdnw,
   input        one_byte_mode,
   output [7:0] h_data,
   output       h_data_available,
   output       p_empty,
   output       p_full
   );
   wire         rd_empty;    
   wire         rd_full;     
   wire         wr_empty;    
   wire         wr_full;     
   async_fifo #
     (
      .D_WIDTH(8),
      .A_WIDTH(1),
      .INIT_WADDR(1),
      .INIT_RADDR(0)
      )
   ph_reg3_fifo
     (
      .rst(!h_rst_b),
      .wr_clk(p_phi2),
      .wr_en(p_selectData && !p_rdnw),
      .wr_data(p_data),
      .rd_clk(!h_phi2),
      .rd_en(h_selectData && h_rd),
      .rd_data(h_data),
      .rd_empty(rd_empty),
      .rd_full(rd_full),
      .wr_empty(wr_empty),
      .wr_full(wr_full)
      );
   assign p_empty          = wr_empty;
   assign p_full           = one_byte_mode ? wr_full   : !wr_empty;
   assign h_data_available = one_byte_mode ? !rd_empty : rd_full;
endmodule
