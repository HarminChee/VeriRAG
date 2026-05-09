`default_nettype none
`default_nettype none
module sha512(
              input wire           clk,
              input wire           reset_n,
              input wire           cs,
              input wire           we,
              input wire  [7 : 0]  address,
              input wire  [31 : 0] write_data,
              output wire [31 : 0] read_data,
              output wire          error
             );
  parameter ADDR_NAME0           = 8'h00;
  parameter ADDR_NAME1           = 8'h01;
  parameter ADDR_VERSION         = 8'h02;
  parameter ADDR_CTRL            = 8'h08;
  parameter CTRL_INIT_BIT        = 0;
  parameter CTRL_NEXT_BIT        = 1;
  parameter CTRL_MODE_LOW_BIT    = 2;
  parameter CTRL_MODE_HIGH_BIT   = 3;
  parameter CTRL_WORK_FACTOR_BIT = 7;
  parameter ADDR_STATUS          = 8'h09;
  parameter STATUS_READY_BIT     = 0;
  parameter STATUS_VALID_BIT     = 1;
  parameter ADDR_WORK_FACTOR_NUM = 8'h0a;
  parameter ADDR_BLOCK0          = 8'h10;
  parameter ADDR_BLOCK31         = 8'h2f;
  parameter ADDR_DIGEST0         = 8'h40;
  parameter ADDR_DIGEST15        = 8'h4f;
  parameter CORE_NAME0           = 32'h73686132; 
  parameter CORE_NAME1           = 32'h2d353132; 
  parameter CORE_VERSION         = 32'h302e3830; 
  parameter MODE_SHA_512_224     = 2'h0;
  parameter MODE_SHA_512_256     = 2'h1;
  parameter MODE_SHA_384         = 2'h2;
  parameter MODE_SHA_512         = 2'h3;
  parameter DEFAULT_WORK_FACTOR_NUM = 32'h000f0000;
  reg init_reg;
  reg init_new;
  reg next_reg;
  reg next_new;
  reg ready_reg;
  reg work_factor_reg;
  reg work_factor_new;
  reg work_factor_we;
  reg [1 : 0] mode_reg;
  reg [1 : 0] mode_new;
  reg         mode_we;
  reg [31 : 0] work_factor_num_reg;
  reg          work_factor_num_we;
  reg [31 : 0] block_reg [0 : 31];
  reg          block_we;
  reg [511 : 0] digest_reg;
  reg           digest_valid_reg;
  wire            core_ready;
  wire [1023 : 0] core_block;
  wire [511 : 0]  core_digest;
  wire            core_digest_valid;
  reg [4 : 0]     block_addr;
  reg [31 : 0]    tmp_read_data;
  reg             tmp_error;
  assign core_block = {block_reg[00], block_reg[01], block_reg[02], block_reg[03],
                       block_reg[04], block_reg[05], block_reg[06], block_reg[07],
                       block_reg[08], block_reg[09], block_reg[10], block_reg[11],
                       block_reg[12], block_reg[13], block_reg[14], block_reg[15],
                       block_reg[16], block_reg[17], block_reg[18], block_reg[19],
                       block_reg[20], block_reg[21], block_reg[22], block_reg[23],
                       block_reg[24], block_reg[25], block_reg[26], block_reg[27],
                       block_reg[28], block_reg[29], block_reg[30], block_reg[31]};
  assign read_data = tmp_read_data;
  assign error     = tmp_error;
  sha512_core core(
                   .clk(clk),
                   .reset_n(reset_n),
                   .init(init_reg),
                   .next(next_reg),
                   .mode(mode_reg),
                   .work_factor(work_factor_reg),
                   .work_factor_num(work_factor_num_reg),
                   .block(core_block),
                   .ready(core_ready),
                   .digest(core_digest),
                   .digest_valid(core_digest_valid)
                  );
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      integer i;
      if (!reset_n)
        begin
          for (i = 0 ; i < 32 ; i = i + 1)
            block_reg[i] <= 32'h0;
          init_reg            <= 1'h0;
          next_reg            <= 1'h0;
          mode_reg            <= MODE_SHA_512;
          work_factor_reg     <= 1'h0;
          work_factor_num_reg <= DEFAULT_WORK_FACTOR_NUM;
          ready_reg           <= 1'h0;
          digest_reg          <= 512'h0;
          digest_valid_reg    <= 1'h0;
        end
      else
        begin
          ready_reg        <= core_ready;
          digest_valid_reg <= core_digest_valid;
          init_reg         <= init_new;
          next_reg         <= next_new;
          if (mode_we)
            mode_reg <= mode_new;
          if (work_factor_we)
            work_factor_reg <= work_factor_new;
          if (work_factor_num_we)
            work_factor_num_reg <= write_data;
          if (core_digest_valid)
            digest_reg <= core_digest;
          if (block_we)
            block_reg[block_addr] <= write_data;
        end
    end 
  always @*
    begin : api_logic
      init_new           = 1'h0;
      next_new           = 1'h0;
      mode_new           = MODE_SHA_512;
      mode_we            = 1'h0;
      work_factor_new    = 1'h0;
      work_factor_we     = 1'h0;
      work_factor_num_we = 1'h0;
      block_we           = 1'h0;
      tmp_read_data      = 32'h0;
      tmp_error          = 1'h0;
      block_addr = address[4 : 0] - ADDR_BLOCK0[4 : 0];
      if (cs)
        begin
          if (we)
            begin
              if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK31))
                block_we = 1'h1;
              case (address)
                ADDR_CTRL:
                  begin
                    init_new        = write_data[CTRL_INIT_BIT];
                    next_new        = write_data[CTRL_NEXT_BIT];
                    mode_new        = write_data[CTRL_MODE_HIGH_BIT : CTRL_MODE_LOW_BIT];
                    mode_we         = 1'h1;
                    work_factor_new = write_data[CTRL_WORK_FACTOR_BIT];
                    work_factor_we  = 1'h1;
                  end
                ADDR_WORK_FACTOR_NUM:
                  work_factor_num_we = 1'h1;
                default:
                    tmp_error = 1'h1;
              endcase 
            end 
          else
            begin
              if ((address >= ADDR_DIGEST0) && (address <= ADDR_DIGEST15))
                tmp_read_data = digest_reg[(15 - (address - ADDR_DIGEST0)) * 32 +: 32];
              if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK31))
                tmp_read_data = block_reg[address[4 : 0]];
              case (address)
                ADDR_NAME0:
                  tmp_read_data = CORE_NAME0;
                ADDR_NAME1:
                  tmp_read_data = CORE_NAME1;
                ADDR_VERSION:
                  tmp_read_data = CORE_VERSION;
                ADDR_CTRL:
                  tmp_read_data = {24'h0, work_factor_reg, 3'b0, mode_reg, next_reg, init_reg};
                ADDR_STATUS:
                  tmp_read_data = {30'h0, digest_valid_reg, ready_reg};
                ADDR_WORK_FACTOR_NUM:
                  tmp_read_data = work_factor_num_reg;
                default:
                  tmp_error = 1'h1;
              endcase 
            end
        end
    end 
endmodule 
