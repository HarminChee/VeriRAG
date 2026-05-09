`ifndef Tcq
   `define Tcq 1
`endif
`ifndef Tcq
   `define Tcq 1
`endif
module extend_clk 
#(
   parameter CLKRATIO=1
)
(
   input            clk,
   input            rst_n,
   input   [6:0]    l0_dll_error_vector,   
   input   [1:0]    l0_rx_mac_link_error,  
   output  [6:0]    l0_dll_error_vector_retime,  
   output  [1:0]    l0_rx_mac_link_error_retime
);
   reg     [6:0]    l0_dll_error_vector_d;
   reg     [6:0]    l0_dll_error_vector_dd;
   reg     [6:0]    l0_dll_error_vector_ddd;
   reg     [1:0]    l0_rx_mac_link_error_d;
   reg     [1:0]    l0_rx_mac_link_error_dd;
   reg     [1:0]    l0_rx_mac_link_error_ddd;
always @(posedge clk) begin
   if (CLKRATIO == 2) begin          
      if (!rst_n) begin
         l0_dll_error_vector_d   <= #`Tcq 6'h00;
         l0_rx_mac_link_error_d  <= #`Tcq 2'h0;
      end else begin
         l0_dll_error_vector_d   <= #`Tcq l0_dll_error_vector;
         l0_rx_mac_link_error_d  <= #`Tcq l0_rx_mac_link_error;
      end
   end else if (CLKRATIO == 4) begin 
      if (!rst_n)
      begin
         l0_dll_error_vector_d     <= #`Tcq 6'h00;
         l0_dll_error_vector_dd    <= #`Tcq 6'h00;
         l0_dll_error_vector_ddd   <= #`Tcq 6'h00;
         l0_rx_mac_link_error_d    <= #`Tcq 2'h0;
         l0_rx_mac_link_error_dd   <= #`Tcq 2'h0;
         l0_rx_mac_link_error_ddd  <= #`Tcq 2'h0;
      end else begin
         l0_dll_error_vector_d     <= #`Tcq l0_dll_error_vector;
         l0_dll_error_vector_dd    <= #`Tcq l0_dll_error_vector_d;
         l0_dll_error_vector_ddd   <= #`Tcq l0_dll_error_vector_dd;
         l0_rx_mac_link_error_d    <= #`Tcq l0_rx_mac_link_error;
         l0_rx_mac_link_error_dd   <= #`Tcq l0_rx_mac_link_error_d;
         l0_rx_mac_link_error_ddd  <= #`Tcq l0_rx_mac_link_error_dd;
      end
   end
end
assign l0_dll_error_vector_retime[6] =
   (CLKRATIO==2) ? (l0_dll_error_vector[6]    | l0_dll_error_vector_d[6]) :
   (CLKRATIO==4) ? (l0_dll_error_vector[6]    | l0_dll_error_vector_d[6] |
                    l0_dll_error_vector_dd[6] | l0_dll_error_vector_ddd[6]) :
                    l0_dll_error_vector[6];
assign l0_dll_error_vector_retime[5] =
   (CLKRATIO==2) ? (l0_dll_error_vector[5]    | l0_dll_error_vector_d[5]) :
   (CLKRATIO==4) ? (l0_dll_error_vector[5]    | l0_dll_error_vector_d[5] |
                    l0_dll_error_vector_dd[5] | l0_dll_error_vector_ddd[5]) :
                    l0_dll_error_vector[5];
assign l0_dll_error_vector_retime[4] =
   (CLKRATIO==2) ? (l0_dll_error_vector[4]    | l0_dll_error_vector_d[4]) :
   (CLKRATIO==4) ? (l0_dll_error_vector[4]    | l0_dll_error_vector_d[4] |
                    l0_dll_error_vector_dd[4] | l0_dll_error_vector_ddd[4]) :
                    l0_dll_error_vector[4];
assign l0_dll_error_vector_retime[3] =
   (CLKRATIO==2) ? (l0_dll_error_vector[3]    | l0_dll_error_vector_d[3]) :
   (CLKRATIO==4) ? (l0_dll_error_vector[3]    | l0_dll_error_vector_d[3] |
                    l0_dll_error_vector_dd[3] | l0_dll_error_vector_ddd[3]) :
                    l0_dll_error_vector[3];
assign l0_dll_error_vector_retime[2] =
   (CLKRATIO==2) ? (l0_dll_error_vector[2]    | l0_dll_error_vector_d[2]) :
   (CLKRATIO==4) ? (l0_dll_error_vector[2]    | l0_dll_error_vector_d[2] |
                    l0_dll_error_vector_dd[2] | l0_dll_error_vector_ddd[2]) :
                    l0_dll_error_vector[2];
assign l0_dll_error_vector_retime[1] =
   (CLKRATIO==2) ? (l0_dll_error_vector[1]    | l0_dll_error_vector_d[1]) :
   (CLKRATIO==4) ? (l0_dll_error_vector[1]    | l0_dll_error_vector_d[1] |
                    l0_dll_error_vector_dd[1] | l0_dll_error_vector_ddd[1]) :
                    l0_dll_error_vector[1];
assign l0_dll_error_vector_retime[0] =
   (CLKRATIO==2) ? (l0_dll_error_vector[0]    | l0_dll_error_vector_d[0]) :
   (CLKRATIO==4) ? (l0_dll_error_vector[0]    | l0_dll_error_vector_d[0] |
                    l0_dll_error_vector_dd[0] | l0_dll_error_vector_ddd[0]) :
                    l0_dll_error_vector[0];
assign l0_rx_mac_link_error_retime[1] =
   (CLKRATIO==2) ? (l0_rx_mac_link_error[1]    | l0_rx_mac_link_error_d[1]) :
   (CLKRATIO==4) ? (l0_rx_mac_link_error_d[1]  | l0_rx_mac_link_error_dd[1] |
                    l0_rx_mac_link_error_dd[1] | l0_rx_mac_link_error_ddd[1]) :
                    l0_rx_mac_link_error;
assign l0_rx_mac_link_error_retime[0] =
   (CLKRATIO==2) ? (l0_rx_mac_link_error[0]    | l0_rx_mac_link_error_d[0]) :
   (CLKRATIO==4) ? (l0_rx_mac_link_error_d[0]  | l0_rx_mac_link_error_dd[0] |
                    l0_rx_mac_link_error_dd[0] | l0_rx_mac_link_error_ddd[0]) :
                    l0_rx_mac_link_error;
endmodule
