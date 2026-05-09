`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module rx_gear #(
                parameter GWIDTH = 14 
                )
   (
   input wire                 clk_250 ,    
   input wire                 clk_125 ,    
   input wire                 rst_n ,      
   input wire                 drate_enable, 
   input wire [GWIDTH-1:0]    data_in ,    
   output wire [GWIDTH*2-1:0] data_out     
   );
reg [1:0]         wr_pntr  ;    
reg [1:0]         rd_pntr  ;    
reg               wr_en    ;    
reg [GWIDTH-1:0]  rd_data0  ;   
reg [GWIDTH-1:0]  rd_data1  ;   
integer           i ;
integer           j ;
reg [GWIDTH-1:0]  rf_0[0:3] ;
reg [GWIDTH-1:0]  rf_1[0:3] ;
reg               drate_f0 ;
reg               drate_f1 ;
reg               drate_s0;
reg               rd_enable;
reg[1:0]          rd_cnt;
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n) begin
      drate_f0 <= 1'b0;
      drate_f1 <= 1'b0;
   end
   else begin
      drate_f0 <= drate_enable;
      drate_f1 <= drate_f0;
   end
end
always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n)
      drate_s0 <= 1'b0;
   else 
      drate_s0 <= drate_enable;
end
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n)
      wr_pntr <= 2'b00;
   else if (wr_en & drate_f1)
      wr_pntr <= wr_pntr + 2'b01;
   else
      wr_pntr <= wr_pntr;
end
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n)
      wr_en <= 1'b0;
   else if(~drate_f1)
      wr_en <= 1'b0;
   else
      wr_en <= ~wr_en;
end
always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n)
      rd_pntr <= 2'b10;
   else if(drate_s0)
      rd_pntr <= rd_pntr + 2'b01;
   else
      rd_pntr <= rd_pntr;
end
assign data_out = {rd_data0,rd_data1};
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n) 
      for (i=0;i<=3;i=i+1) begin 
         rf_0[i] <= 0;
      end
   else if (!wr_en)
      rf_0[wr_pntr] <= data_in ;
end
always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n) 
      rd_data0 <= 14'b00000000000010;
   else begin
      if(rd_enable) 
         rd_data0 <= rf_0[rd_pntr] ;
      else 
         rd_data0 <= 14'b00000000000010;
   end
end
always @(posedge clk_250, negedge rst_n) begin 
   if (!rst_n) 
      for (j=0;j<=3;j=j+1) begin 
         rf_1[j] <= 0;
      end
   else if (wr_en)
      rf_1[wr_pntr] <= data_in ;
end
always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n) 
      rd_data1 <= 14'b00000000000010;
   else begin
      if(rd_enable) 
         rd_data1 <= rf_1[rd_pntr] ;
      else 
         rd_data1 <= 14'b00000000000010;
   end
end
always @(posedge clk_125, negedge rst_n) begin 
   if (!rst_n) begin
      rd_cnt    <= 2'b00;
      rd_enable <= 1'b0;
   end
   else begin
      if(drate_s0)
         rd_cnt <= rd_cnt + 2'b01;
      else
         rd_cnt <= 2'b00;
      if(~drate_s0)
         rd_enable <= 1'b0;
      else if(rd_cnt == 2'b11) 
         rd_enable <= 1'b1;
   end
end
endmodule
