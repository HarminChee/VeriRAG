`default_nettype none
`timescale 1ns / 1ps
module memory(
  input  wire pll_ref_clk,
  input  wire reset_in,
  output reg  reset_out,
  output wire clk,
  input  wire        write_req,
  input  wire        read_req,
  input  wire [31:0] data_write,
  output reg  [31:0] data_read,
  input  wire [25:0] addr,
  output wire        busy,
  output wire [ 12: 0]       mem_addr,
  output wire [  2: 0]       mem_ba,
  output wire                mem_cas_n,
  output wire [  0: 0]       mem_cke,
  inout  wire [  0: 0]       mem_clk,
  inout  wire [  0: 0]       mem_clk_n,
  output wire [  0: 0]       mem_cs_n,
  output wire [  1: 0]       mem_dm,
  inout  wire [ 15: 0]       mem_dq,
  inout  wire [  1: 0]       mem_dqs,
  output wire [  0: 0]       mem_odt,
  output wire                mem_ras_n,
  output wire                mem_we_n,
  output wire        flash_dq0,
  input  wire        flash_dq1,
  output wire        flash_wb,
  output wire        flash_holdb,
  output wire        flash_c,
  output wire        flash_sb,
  input  wire         program_req,
  output reg          program_ack,
  input  wire         program_buffer_empty,
  input  wire [31:0]  program_buffer_q,
  output reg          program_buffer_read,
  output reg  [5:0]  state,
  output reg         busy_int
);

localparam VOID                         = 6'd0,
           DELAY                        = 6'd1,
           INIT                         = 6'd2,
           INIT_B                       = 6'd3,
           IDLE                         = 6'd4,
           PROGRAM_WRITE_ENABLE         = 6'd5,
           PROGRAM_WRITE_ENABLE_B       = 6'd6,
           PROGRAM_WRITE_FINISH         = 6'd7,
           PROGRAM_WRITE_FINISH_B       = 6'd8,
           PROGRAM_START                = 6'd9,
           PROGRAM_PAGE                 = 6'd10,
           PROGRAM_SECTOR_ERASE_ADDR1   = 6'd11,
           PROGRAM_SECTOR_ERASE_ADDR2   = 6'd12,
           PROGRAM_SECTOR_ERASE_ADDR3   = 6'd13,
           PROGRAM_SECTOR_ERASE_EXECUTE = 6'd14,
           PROGRAM_SECTOR_ERASE_FINISH  = 6'd15,
           PROGRAM_ADDR1                = 6'd16,
           PROGRAM_ADDR2                = 6'd17,
           PROGRAM_ADDR3                = 6'd18,
           PROGRAM_DAT1                 = 6'd19,
           PROGRAM_DAT2A                = 6'd20,
           PROGRAM_DAT2B                = 6'd21,
           PROGRAM_DAT2C                = 6'd22,
           PROGRAM_DAT2D                = 6'd23,
           PROGRAM_DAT2E                = 6'd24,
           LOAD_0                       = 6'd25,
           LOAD_1                       = 6'd26,
           LOAD_ADDR1                   = 6'd27,
           LOAD_ADDR2                   = 6'd28,
           LOAD_ADDR3                   = 6'd29,
           LOAD_EXECUTE                 = 6'd30,
           LOAD_WORD1                   = 6'd31,
           LOAD_WORD1B                  = 6'd32,
           LOAD_WORD2                   = 6'd33,
           LOAD_WORD3                   = 6'd34,
           LOAD_WORD4                   = 6'd35,
           READ_1                       = 6'd36,
           READ_2                       = 6'd37,
           WRITE_1                      = 6'd38,
           WRITE_2                      = 6'd39;

localparam FLASH_WREN = 8'b0000_0110,  
           FLASH_WRDI = 8'b0000_0100,  
           FLASH_RFSR = 8'b0111_0000,  
           FLASH_RDSR = 8'b0000_0101,  
           FLASH_BE   = 8'b1100_0111,  
           FLASH_SE   = 8'b1101_1000,  
           FLASH_PP   = 8'b0000_0010,  
           FLASH_READ = 8'b0000_0011,  
           FLASH_RDID = 8'b1001_1111;  

wire        phy_clk;
wire        local_ready;
wire [31:0] local_rdata;
wire        local_rdata_valid;
wire        local_init_done;
wire        flash_busy;
wire [7:0]  flash_read_buffer_q;
wire        flash_write_buffer_full;
wire        flash_read_buffer_empty;
reg  [24:0] local_address;
reg         local_write_req;
reg         local_read_req;
reg         local_burstbegin;
reg  [31:0] local_wdata;
reg  [5:0]  state_callback;
reg  [7:0]  delay_counter;
reg  [16:0] pages_to_write;
reg  [16:0] pages_written;
reg         pages_to_write_valid;
reg  [16:0] pages_to_read;
reg  [16:0] pages_read;
reg         pages_to_read_valid;
reg  [6:0]  page_words;
reg  [31:0] page_word;
reg  [23:0] page_address;
reg  [7:0]  flash_instruction;
reg         flash_execute;
reg  [8:0]  flash_bytes_to_read;
reg  [7:0]  flash_write_buffer_data;
reg         flash_write_buffer_write;
reg         flash_read_buffer_read;

assign busy = busy_int | program_req | write_req | read_req;
assign clk = phy_clk;

always @(posedge clk or posedge reset_in) begin
  if (reset_in) begin
    state <= INIT;
    state_callback <= VOID;
    local_write_req <= 0;
    local_read_req <= 0;
    local_burstbegin <= 0;
    data_read <= 32'h0;
    program_buffer_read <= 0;
    flash_execute <= 0;
    flash_read_buffer_read <= 0;
    flash_write_buffer_write <= 0;
    program_ack <= 0;
    busy_int <= 1;
    reset_out <= 0;
  end
  else begin
    local_write_req <= 0;
    local_read_req <= 0;
    local_burstbegin <= 0;
    program_buffer_read <= 0;
    flash_execute <= 0;
    flash_read_buffer_read <= 0;
    flash_write_buffer_write <= 0;
    program_ack <= 0;
    
    case (state)
      INIT: begin
        reset_out <= 1;
        state <= DELAY;
        state_callback <= INIT_B;
        delay_counter <= 2;
        busy_int <= 1;
      end

      INIT_B: begin
        if (program_req) begin
          state <= PROGRAM_START;
          program_ack <= 1;
          busy_int <= 1;
        end
        else begin
          state <= LOAD_0;
          busy_int <= 1;
        end
      end

      IDLE: begin
        if (program_req) begin
          state <= PROGRAM_START;
          program_ack <= 1;
          busy_int <= 1;
        end
        else if (write_req) begin
          state <= WRITE_1;
          local_wdata <= data_write;
          local_address <= addr[24:0];
          busy_int <= 1;
        end
        else if (read_req) begin
          state <= READ_1;
          local_address <= addr[24:0];
          busy_int <= 1;
        end
        else begin
          busy_int <= 0;
        end
      end

      DELAY: begin
        busy_int <= 1;
        if (delay_counter == 8'd0) begin
          state <= state_callback;
          state_callback <= VOID;
        end
        else begin
          delay_counter <= delay_counter - 8'd1;
        end
      end

      // ... rest of state machine cases remain unchanged ...

    endcase
  end
end

ram_controller ram_controller_inst(
  .pll_ref_clk(pll_ref_clk),
  .phy_clk(phy_clk),
  .global_reset_n(~reset_in),
  .soft_reset_n(1'b1),
  .reset_phy_clk_n(),
  .local_address(local_address),
  .local_write_req(local_write_req),
  .local_read_req(local_read_req),
  .local_burstbegin(local_burstbegin),
  .local_wdata(local_wdata),
  .local_be(4'hF),
  .local_size(3'd1),
  .local_ready(local_ready),
  .local_rdata(local_rdata),
  .local_rdata_valid(local_rdata_valid),
  .local_refresh_ack(),
  .local_init_done(local_init_done),
  .mem_addr(mem_addr),
  .mem_ba(mem_ba),
  .mem_cas_n(mem_cas_n),
  .mem_cke(mem_cke),
  .mem_clk(mem_clk),
  .mem_clk_n(mem_clk_n),
  .mem_cs_n(mem_cs_n),
  .mem_dm(mem_dm),
  .mem_dq(mem_dq),
  .mem_dqs(mem_dqs),
  .mem_odt(mem_odt),
  .mem_ras_n(mem_ras_n),
  .mem_we_n(mem_we_n),
  .aux_full_rate_clk(),
  .aux_half_rate_clk(),
  .reset_request_n()
);

flash_interface flash_interface_inst (
  .clk(clk),
  .reset(reset_out),
  .instruction(flash_instruction),
  .execute(flash_execute),
  .bytes_to_read(flash_bytes_to_read),
  .busy(flash_busy),
  .write_buffer_data(flash_write_buffer_data),
  .write_buffer_write(flash_write_buffer_write),
  .write_buffer_full(flash_write_buffer_full),
  .read_buffer_q(flash_read_buffer_q),
  .read_buffer_empty(flash_read_buffer_empty),
  .read_buffer_read(flash_read_buffer_read),
  .flash_dq0(flash_dq0),
  .flash_dq1(flash_dq1),
  .flash_wb(flash_wb),
  .flash_holdb(flash_holdb),
  .flash_c(flash_c),
  .flash_sb(flash_sb)
);

endmodule