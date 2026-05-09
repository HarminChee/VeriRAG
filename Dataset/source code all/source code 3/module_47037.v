`timescale 1ns / 1ps
`timescale 1ns / 1ps
module efifo_module
   #(
      parameter                           DATA_WIDTH = 16,
      parameter                           DEPTH = 2
   )(
                                                                   clk,
                                                                   rd,
                                                                   rst_n,
                                                                   wr,
                                                                   wr_data,
                                                                   almost_empty,
                                                                   almost_full,
                                                                   empty,
                                                                   full,
                                                                   rd_data
                                                                )
;
  output                         almost_empty;
  output                         almost_full;
  output                         empty;
  output                         full;
  output  [ DATA_WIDTH - 1 : 0 ] rd_data;
  input                          clk;
  input                          rd;
  input                          rst_n;
  input                          wr;
  input   [ DATA_WIDTH - 1 : 0 ] wr_data;
  wire             almost_empty;
  wire             almost_full;
  wire             empty;
  reg     [      DEPTH - 1 : 0 ] entries;
  reg     [ DATA_WIDTH - 1 : 0 ] entry_0;
  reg     [ DATA_WIDTH - 1 : 0 ] entry_1;
  wire             full;
  reg              rd_address;
  reg     [ DATA_WIDTH - 1 : 0 ] rd_data;
  wire    [  1: 0] rdwr;
  reg              wr_address;
  assign rdwr = {rd, wr};
  assign full = entries == DEPTH;
  assign almost_full = entries >= DEPTH - 1;
  assign empty = entries == 0;
  assign almost_empty = entries <= DEPTH - 1;
  always @(entry_0 or entry_1 or rd_address)
    begin
      case (rd_address) 
          1'd0: begin
              rd_data = entry_0;
          end 
          1'd1: begin
              rd_data = entry_1;
          end 
          default: begin
          end 
      endcase 
    end
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          wr_address <= 0;
          rd_address <= 0;
          entries <= 0;
        end
      else 
        case (rdwr) 
            2'd1: begin
                if (!full)
                  begin
                    entries <= entries + 1;
                    wr_address <= (wr_address == 1) ? 0 : (wr_address + 1);
                  end
            end 
            2'd2: begin
                if (!empty)
                  begin
                    entries <= entries - 1;
                    rd_address <= (rd_address == 1) ? 0 : (rd_address + 1);
                  end
            end 
            2'd3: begin
                wr_address <= (wr_address == 1) ? 0 : (wr_address + 1);
                rd_address <= (rd_address == 1) ? 0 : (rd_address + 1);
            end 
            default: begin
            end 
        endcase 
    end
  always @(posedge clk)
    begin
      if (wr & !full)
          case (wr_address) 
              1'd0: begin
                  entry_0 <= wr_data;
              end 
              1'd1: begin
                  entry_1 <= wr_data;
              end 
              default: begin
              end 
          endcase 
    end
endmodule
