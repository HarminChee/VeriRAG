module wb_bram #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 12,
  parameter MEM_FILE  = "NOTHING",
  parameter MEM_FILE_LENGTH = 0
)(
  input               clk,
  input               rst,
  input               i_wbs_we,
  input               i_wbs_stb,
  input               i_wbs_cyc,
  input       [3:0]   i_wbs_sel,
  input       [31:0]  i_wbs_adr,
  input       [31:0]  i_wbs_dat,
  output reg  [31:0]  o_wbs_dat,
  output reg          o_wbs_ack,
  output reg          o_wbs_int
);
localparam            RAM_SIZE = ADDR_WIDTH - 1;
localparam            SLEEP_COUNT = 4;
wire  [31:0]        read_data;
reg   [31:0]        write_data;
reg   [RAM_SIZE:0]  ram_adr;
reg                 en_ram;
reg   [3:0]         ram_sleep;
bram#(
  .DATA_WIDTH      (DATA_WIDTH      ),
  .ADDR_WIDTH      (ADDR_WIDTH      ),
  .MEM_FILE        (MEM_FILE        ),
  .MEM_FILE_LENGTH (MEM_FILE_LENGTH )
)br(
  .clk             (clk             ),
  .rst             (rst             ),
  .en              (en_ram          ),
  .we              (i_wbs_we        ),
  .write_address   (ram_adr         ),
  .read_address    (ram_adr         ),
  .data_in         (write_data      ),
  .data_out        (read_data       )
);
always @ (posedge clk) begin
  if (rst) begin
    o_wbs_dat       <= 32'h0;
    o_wbs_ack       <= 0;
    o_wbs_int       <= 0;
    ram_sleep       <= SLEEP_COUNT;
    ram_adr         <= 0;
    en_ram          <= 0;
  end
  else begin
    if (o_wbs_ack & !i_wbs_stb)begin
      o_wbs_ack     <= 0;
      en_ram        <= 0;
    end
    if (i_wbs_stb & i_wbs_cyc) begin
      en_ram <= 1;
      ram_adr <= i_wbs_adr[RAM_SIZE:0];
      if (i_wbs_we) begin
        write_data <= i_wbs_dat;
      end
      else begin
        o_wbs_dat <= read_data;
      end
      if (ram_sleep > 0) begin
        ram_sleep <= ram_sleep - 1;
      end
      else begin
        o_wbs_ack <= 1;
        ram_sleep <= SLEEP_COUNT;
      end
    end
  end
end
endmodule
