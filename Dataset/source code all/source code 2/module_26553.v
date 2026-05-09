module uart
(
    clk_i,
    rst_i,
    tx_busy_o,
    rx_ready_o,
    break_o,
    data_i,
    wr_i,
    data_o,
    rd_i,
    rxd_i,
    txd_o
);
parameter  [31:0]    UART_DIVISOR = 278;
input               clk_i ;
input               rst_i ;
input [7:0]         data_i ;
output [7:0]        data_o ;
input               wr_i ;
input               rd_i ;
output              tx_busy_o ;
output              rx_ready_o ;
output              break_o ;
input               rxd_i ;
output              txd_o ;
parameter           FULL_BIT = UART_DIVISOR;
parameter           HALF_BIT = (FULL_BIT / 2);
reg [7:0]           tx_buf;
reg                 tx_buf_full;
reg                 tx_busy;
reg [3:0]           tx_bits;
integer             tx_count;
reg [7:0]           tx_shift_reg;
reg                 txd_o;
reg                 i_rxd;
reg [7:0]           data_o;
reg [3:0]           rx_bits;
integer             rx_count;
reg [7:0]           rx_shift_reg;
reg                 rx_ready_o;
reg                 break_o;
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
       i_rxd <= 1'b1;
   else
       i_rxd <= rxd_i;
end
always @ (posedge clk_i or posedge rst_i )
begin
   if (rst_i == 1'b1)
   begin
       rx_bits      <= 0;
       rx_count     <= 0;
       rx_ready_o   <= 1'b0;
       rx_shift_reg <= 8'h00;
       data_o       <= 8'h00;
       break_o      <= 1'b0;
   end
   else
   begin
       if (rd_i == 1'b1)
           rx_ready_o <= 1'b0;
       if (rx_count != 0)
           rx_count    <= (rx_count - 1);
       else
       begin
           if (rx_bits == 0)
           begin
               break_o  <= 1'b0;
               if (i_rxd == 1'b0)
               begin
                   rx_count <= HALF_BIT;
                   rx_bits  <= 1;
               end
           end
           else if (rx_bits == 1)
           begin
               if (i_rxd == 1'b0)
               begin
                   rx_count     <= FULL_BIT;
                   rx_bits      <= rx_bits + 1'b1;
                   rx_shift_reg <= 8'h00;
               end
               else
               begin
                   rx_bits      <= 0;
               end
           end
           else if (rx_bits == 10)
           begin
               if (i_rxd == 1'b1)
               begin
                   rx_count     <= 0;
                   rx_bits      <= 0;
                   data_o       <= rx_shift_reg;
                   rx_ready_o   <= 1'b1;
               end
               else
               begin
                   rx_count     <= FULL_BIT;
                   rx_bits      <= 0;
                   break_o      <= 1'b1;
               end
           end
           else
           begin
               rx_shift_reg[7]  <= i_rxd;
               rx_shift_reg[6:0]<= rx_shift_reg[7:1];
               rx_count         <= FULL_BIT;
               rx_bits          <= rx_bits + 1'b1;
           end
       end
   end
end
always @ (posedge clk_i or posedge rst_i )
begin
   if (rst_i == 1'b1)
   begin
       tx_count     <= 0;
       tx_bits      <= 0;
       tx_busy      <= 1'b0;
       txd_o        <= 1'b1;
       tx_shift_reg <= 8'h00;
       tx_buf       <= 8'h00;
       tx_buf_full  <= 1'b0;
   end
   else
   begin
       if (wr_i == 1'b1)
       begin
           tx_buf       <= data_i;
           tx_buf_full  <= 1'b1;
       end
       if (tx_count != 0)
           tx_count     <= (tx_count - 1);
       else
       begin
           if (tx_bits == 0)
           begin
               tx_busy <= 1'b0;
               if (tx_buf_full == 1'b1)
               begin
                   tx_shift_reg <= tx_buf;
                   tx_busy      <= 1'b1;
                   txd_o        <= 1'b0;
                   tx_buf_full  <= 1'b0;
                   tx_bits      <= 1;
                   tx_count     <= FULL_BIT;
               end
           end
           else if (tx_bits == 9)
           begin
               txd_o    <= 1'b1;
               tx_bits  <= 0;
               tx_count <= FULL_BIT;
           end
           else
           begin
               txd_o            <= tx_shift_reg[0];
               tx_shift_reg[6:0]<= tx_shift_reg[7:1];
               tx_bits          <= tx_bits + 1'b1;
               tx_count         <= FULL_BIT;
           end
        end
    end
end
assign tx_busy_o = (tx_busy | tx_buf_full | wr_i);
endmodule
