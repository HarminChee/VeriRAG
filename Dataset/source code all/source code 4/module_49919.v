module red_pitaya_daisy_tx
(
   input                 ser_clk_i       ,  
   output                ser_clk_o       ,  
   output                ser_dat_o       ,  
   input                 par_clk_i       ,  
   input                 par_rstn_i      ,  
   output                par_rdy_o       ,  
   input                 par_dv_i        ,  
   input      [ 16-1: 0] par_dat_i          
);
ODDR #(
  .DDR_CLK_EDGE    ( "SAME_EDGE" ), 
  .INIT            (  1'b1       ), 
  .SRTYPE          ( "ASYNC"     )  
) ODDR_clk (
  .Q    (  ser_clk_o    ), 
  .C    (  ser_clk_i    ), 
  .CE   (  1'b1         ), 
  .D1   (  1'b1         ), 
  .D2   (  1'b0         ), 
  .R    ( !par_rstn_i   ), 
  .S    (  1'b0         )  
);
reg  [ 4-1: 0] par_dat ;
OSERDESE2
#(
  .DATA_RATE_OQ   ( "DDR"    ),
  .DATA_RATE_TQ   ( "SDR"    ),
  .DATA_WIDTH     (  4       ),
  .TRISTATE_WIDTH (  1       ),
  .SERDES_MODE    ( "MASTER" )
)
i_oserdese
(
  .D1             (  par_dat[0]     ),
  .D2             (  par_dat[1]     ),
  .D3             (  par_dat[2]     ),
  .D4             (  par_dat[3]     ),
  .D5             (  1'b0           ),
  .D6             (  1'b0           ),
  .D7             (  1'b0           ),
  .D8             (  1'b0           ),
  .T1             (  1'b0           ),
  .T2             (  1'b0           ),
  .T3             (  1'b0           ),
  .T4             (  1'b0           ),
  .SHIFTIN1       (),
  .SHIFTIN2       (),
  .SHIFTOUT1      (),
  .SHIFTOUT2      (),
  .OCE            (  1'b1           ),
  .CLK            (  ser_clk_i      ),
  .CLKDIV         (  par_clk_i      ),
  .OQ             (  ser_dat_o      ),
  .TQ             (),
  .OFB            (),
  .TFB            (),
  .TBYTEIN        (  1'b0           ),
  .TBYTEOUT       (),
  .TCE            (  1'b0           ),
  .RST            ( !par_rstn_i     )
);
reg  [ 2-1: 0] par_sel       ;
reg  [ 3-1: 0] par_dv        ;
reg  [12-1: 0] par_dat_r     ;
assign par_rdy_o = (par_sel==2'h0) ;
always @(posedge par_clk_i) begin
   case(par_sel)
    2'b00 : begin
               if (par_dv_i)
                  par_dat <= par_dat_i[3:0] ;
               else
                  par_dat <= 8'h0 ;
            end
    2'b01 : begin
               if (par_dv[0])
                  par_dat <= par_dat_r[3:0] ;
               else
                  par_dat <= 8'h0 ;
            end
    2'b10 : begin
               if (par_dv[1])
                  par_dat <= par_dat_r[7:4] ;
               else
                  par_dat <= 8'h0 ;
            end
    2'b11 : begin
               if (par_dv[2])
                  par_dat <= par_dat_r[11:8] ;
               else
                  par_dat <= 8'h0 ;
            end
   endcase
end
always @(posedge par_clk_i) begin
   if (par_rstn_i == 1'b0) begin
      par_sel   <=  2'h0 ;
      par_dv    <=  3'b0 ;
      par_dat_r <= 12'h0 ;
   end
   else begin
      par_sel <= par_sel + 2'h1 ;
      par_dv  <= {par_dv[1:0], par_dv_i && par_rdy_o} ;
      if (par_dv_i && par_rdy_o)
         par_dat_r <= par_dat_i[15:4] ;
   end
end
endmodule
