`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module FirstStage
(
    input wire [7:0] plane_xpos,
    input wire [3:0] plane_ypos,
    input wire [5:0] ram_read_data,
    input wire [5:0] copy_read_data,
    input wire [5:0] write_block,
    input wire save_block,
    input wire copy_backup,
    input wire clk,
    input wire rst,
    output reg [11:0] ram_addr,
    output reg [11:0] copy_addr,
    output reg [5:0] block,
    output reg blocking,
    output reg ram_we,
    output reg [5:0] ram_write_data,
    output reg backuped
 );
    localparam  A   =   1 ;
    localparam  B   =   0 ;
    localparam  C   =   2 ;
    localparam  D   =   3 ;
    localparam  E   =   4 ;
    localparam  F   =   5 ;
    localparam  G   =   6 ;
    localparam  H   =   7 ;
    localparam  I   =   8 ;
    localparam  J   =   9 ;
    localparam  K   =   10;
    localparam  L   =   11;
    localparam  M   =   12;
    localparam  N   =   13;
    localparam  O   =   14;
    localparam  P   =   15;
    localparam  Q   =   16;
    localparam  R   =   17;
    localparam  S   =   18;
    localparam  T   =   19;
    localparam  U   =   20;
    localparam  V   =   21;
    localparam  W   =   22;
    localparam  X   =   23;
    localparam  Y   =   24;
    localparam  Z   =   25;
    localparam  AY  =   26;
    localparam  IY  =   27;
    localparam  GY  =   28;
    localparam  KY  =   29;
    localparam  PY  =   30;
    localparam  TY  =   31;
    localparam  UY  =   32;
    localparam  WY  =   33;
    localparam  DY  =   34;
    reg [1:0] state, state_nxt;
    localparam NORMAL_MODE  = 2'b00;
    localparam START_BACKUP = 2'b01;
    localparam BACKUP       = 2'b10;
    reg backuped_nxt;
    reg [11:0] saving_addr, saving_addr_nxt;
    localparam ROM_STAGE_SIZE   = 2160;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            backuped    <= #1 0;
            state       <= #1 START_BACKUP;
            saving_addr <= #1 0;
        end
        else begin
            backuped    <= #1 backuped_nxt;
            state       <= #1 state_nxt;
            saving_addr <= #1 saving_addr_nxt;
        end
    end
    always @* begin
        case(state)
            NORMAL_MODE: begin
                backuped_nxt    = 0;
                copy_addr       = 0;
                saving_addr_nxt = 0;
                ram_addr = (11-plane_ypos)*180 + plane_xpos;
                if(save_block) begin
                    ram_write_data = write_block;
                    ram_we  = 1;
                    block   = ram_read_data;
                    blocking= 0;
                end
                else begin
                    ram_write_data = write_block;
                    ram_we  = 0;
                    block   = ram_read_data;
                    if((block == A) || (block == D)|| (block == C)|| (block == S)|| (block == L)|| (block == N)|| (block == J)|| (block == M)|| (block == P)|| (block == WY) || (block == DY)) begin
                       blocking = 1;
                    end
                    else begin
                       blocking = 0;
                    end
                end
                if(copy_backup)
                    state_nxt = START_BACKUP;
                else
                    state_nxt = NORMAL_MODE;
            end
            START_BACKUP: begin
                backuped_nxt    = 0;
                copy_addr       = 0;
                saving_addr_nxt = 0;
                ram_addr        = 0;
                ram_write_data  = 0;
                ram_we          = 0;
                block           = 0;
                blocking        = 0;
                state_nxt       = BACKUP;
            end
            BACKUP: begin
                copy_addr       = saving_addr;
                saving_addr_nxt = saving_addr + 1;
                ram_addr        = saving_addr; 
                ram_write_data  = copy_read_data;
                if(saving_addr == ROM_STAGE_SIZE) begin
                    backuped_nxt= 1;
                    ram_we      = 0;
                    state_nxt   = NORMAL_MODE;  
                end
                else begin
                    backuped_nxt= 0;
                    ram_we      = 1;
                    state_nxt   = BACKUP;
                end        
                block   = 0;
                blocking= 0;
            end
            default: begin
                backuped_nxt    = 0;
                copy_addr       = 0;
                saving_addr_nxt = 0;
                ram_addr        = 0;
                ram_write_data  = 0;
                ram_we          = 0;
                block           = 0;
                blocking        = 0;
                state_nxt       = NORMAL_MODE;        
            end
        endcase 
    end
endmodule
