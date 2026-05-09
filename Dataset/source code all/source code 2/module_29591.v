`define MAX_SECTOR_COUNT 24'h10000
`define MAX_SECTOR_COUNT 24'h10000
module sata_dma_interface (
  input               clk,
  input               rst,
  input               enable,
  output  reg [7:0]   sata_command,
  output  reg         sata_execute_command_stb, 
  output  reg [47:0]  sata_lba,                 
  output  reg [15:0]  sata_sector_count,        
  input               sata_busy,
  input               write_enable,
  input       [63:0]  write_addr,
  output              write_finished,
  input       [23:0]  write_count,
  input               write_flush,
  input       [1:0]   write_activate,
  input               write_strobe,
  input               write_empty,
  output              enable_write_ready,
  input               read_enable,
  input       [63:0]  read_addr,
  output              read_busy,
  output              read_error,
  input       [23:0]  read_count,
  input               read_flush,
  input               read_activate,
  input               read_strobe
);
localparam              IDLE            =   4'h0;
localparam              WRITE_SETUP     =   4'h1;
localparam              WRITE_COMMAND   =   4'h2;
localparam              WRITE           =   4'h3;
localparam              WRITE_FINISHED  =   4'h4;
localparam              READ_SETUP      =   4'h5;
localparam              READ_COMMAND    =   4'h6;
localparam              READ            =   4'h7;
localparam              READ_FINISHED   =   4'h8;
reg         [23:0]      sata_write_count;
reg         [23:0]      sata_read_count;
reg         [3:0]       state;
reg         [23:0]      total_sector_count;
reg         [23:0]      dword_count;
wire        [23:0]      total_dword_size;
reg                     write_finished;
reg                     read_finished;
reg                     enable_write_fifo;
assign  read_busy                   = read_enable && !read_finished;
assign  read_error                  = 0;
assign  total_dword_size            = (sata_sector_count == 16'h0000)   ?
                                        `MAX_SECTOR_COUNT   << 7 :
                                        sata_sector_count   << 7;
assign  enable_write_ready          = enable && enable_write_fifo;
always @ (posedge clk) begin
  if (rst || !enable) begin
    sata_lba                    <=  0;
    sata_sector_count           <=  0;
    sata_command                <=  0;
    sata_execute_command_stb    <=  0;
    state                       <=  IDLE;
    total_sector_count          <=  0;
    dword_count                 <=  0;
    write_finished              <=  0;
    read_finished               <=  0;
    enable_write_fifo           <=  0;
  end
  else begin
    sata_execute_command_stb          <=  0;
    write_finished                    <=  0;
    read_finished                     <=  0;
    case (state)
        IDLE: begin
            if (write_enable) begin
                total_sector_count    <=  write_count[23:7] + (write_count[6:0] > 0); 
                sata_lba              <=  write_addr[55:6];
                sata_command          <=  8'h35;
                state                 <=  WRITE_SETUP;
            end
            else if (read_enable) begin
                total_sector_count    <=  read_count[23:7] + (read_count[6:0] > 0); 
                sata_lba              <=  read_addr[55:6];
                sata_command          <=  8'h25;
                state                 <=  READ_SETUP;
            end
        end
        WRITE_SETUP: begin
            if (!sata_busy) begin
              if (total_sector_count  >= `MAX_SECTOR_COUNT) begin
                  sata_sector_count   <=  `MAX_SECTOR_COUNT;
                  total_sector_count  <=  total_sector_count - `MAX_SECTOR_COUNT;
              end
              else begin
                  sata_sector_count   <=  total_sector_count;
                  total_sector_count  <=  0;
              end
              dword_count             <=  0;
              state                   <=  WRITE_COMMAND;
              enable_write_fifo       <=  1;
            end
        end
        WRITE_COMMAND: begin
            sata_execute_command_stb  <=  1;
            state                     <=  WRITE;
        end
        WRITE: begin
            if ((write_activate > 0) && write_strobe) begin
                dword_count           <=  dword_count + 1;
            end
            if (dword_count >= total_dword_size) begin
                enable_write_fifo     <=  0;
                if (!sata_busy) begin
                    if (total_sector_count > 0) begin
                        state         <=  WRITE_SETUP;
                        sata_lba      <=  sata_lba + `MAX_SECTOR_COUNT;
                    end
                    else begin
                        state         <=  WRITE_FINISHED;
                    end
                end
            end
        end
        WRITE_FINISHED: begin
            write_finished          <=  1;
            if (!write_enable) begin
                state               <=  IDLE;
            end
        end
        READ_SETUP: begin
            if (!sata_busy) begin
              if (total_sector_count  >= `MAX_SECTOR_COUNT) begin
                  sata_sector_count   <=  16'h0000;
                  total_sector_count  <=  total_sector_count - `MAX_SECTOR_COUNT;
              end
              else begin
                  sata_sector_count   <=  total_sector_count;
                  total_sector_count  <=  0;
              end
              dword_count             <=  0;
              state                   <=  READ_COMMAND;
            end
        end
        READ_COMMAND: begin
            sata_execute_command_stb<=  1;
            state                   <=  READ;
        end
        READ: begin
            if (read_activate && read_strobe) begin
                dword_count         <=  dword_count + 1;
            end
            if ((dword_count >= total_dword_size) && !sata_busy) begin
                if (total_sector_count > 0) begin
                    state           <=  READ_SETUP;
                end
                else begin
                    state           <=  READ_FINISHED;
                end
            end
        end
        READ_FINISHED: begin
            read_finished           <=  1;
            if (!read_enable) begin
                state               <= IDLE;
            end
        end
        default: begin
            state   <=  IDLE;
        end
    endcase
  end
end
endmodule
