`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module alt_ddrx_bank_tracking #
    ( parameter
        MEM_IF_CHIP_BITS = 2,
        MEM_IF_CS_WIDTH  = 2,
        MEM_IF_ROW_WIDTH = 16, 
        MEM_IF_BA_WIDTH  = 3,  
        CTL_LOOK_AHEAD_DEPTH = 6, 
        CTL_CMD_QUEUE_DEPTH  = 8
    )
    (
        ctl_clk,
        ctl_reset_n,
        all_banks_closed, 
        cmd0_is_valid,
        cmd0_chip_addr,
        cmd0_row_addr,
        cmd0_bank_addr,
        cmd0_is_a_write,
        cmd0_is_a_read,
        cmd0_multicast_req,
        cmd1_is_valid,
        cmd1_chip_addr,
        cmd1_row_addr,
        cmd1_bank_addr,
        cmd1_is_a_write,
        cmd1_is_a_read,
        cmd1_multicast_req,
        cmd2_is_valid,
        cmd2_chip_addr,
        cmd2_row_addr,
        cmd2_bank_addr,
        cmd2_is_a_write,
        cmd2_is_a_read,
        cmd2_multicast_req,
        cmd3_is_valid,
        cmd3_chip_addr,
        cmd3_row_addr,
        cmd3_bank_addr,
        cmd3_is_a_write,
        cmd3_is_a_read,
        cmd3_multicast_req,
        cmd4_is_valid,
        cmd4_chip_addr,
        cmd4_row_addr,
        cmd4_bank_addr,
        cmd4_is_a_write,
        cmd4_is_a_read,
        cmd4_multicast_req,
        cmd5_is_valid,
        cmd5_chip_addr,
        cmd5_row_addr,
        cmd5_bank_addr,
        cmd5_is_a_write,
        cmd5_is_a_read,
        cmd5_multicast_req,
        cmd6_is_valid,
        cmd6_chip_addr,
        cmd6_row_addr,
        cmd6_bank_addr,
        cmd6_is_a_write,
        cmd6_is_a_read,
        cmd6_multicast_req,
        cmd7_is_valid,
        cmd7_chip_addr,
        cmd7_row_addr,
        cmd7_bank_addr,
        cmd7_is_a_write,
        cmd7_is_a_read,
        cmd7_multicast_req,
        row_is_open,
        bank_is_open,
        bank_info_valid,
        current_chip_addr,
        current_row_addr,
        current_bank_addr,
        current_is_a_write,
        current_is_a_read,
        current_multicast_req,
        current_row_is_open,
        current_bank_is_open,
        current_bank_info_valid,
        ecc_fetch_error_addr,
        fetch,
        flush1,
        flush2,
        flush3,
        do_activate,
        do_precharge,
        do_precharge_all,
        do_auto_precharge,
        to_chip,
        to_row_addr,
        to_bank_addr,
        bank_information,
        bank_open
    );
input ctl_clk;
input ctl_reset_n;
output [MEM_IF_CS_WIDTH - 1 : 0] all_banks_closed;
input  cmd0_is_valid;
input  cmd0_is_a_write;
input  cmd0_is_a_read;
input  cmd0_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd0_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd0_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd0_bank_addr;
input  cmd1_is_valid;
input  cmd1_is_a_write;
input  cmd1_is_a_read;
input  cmd1_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd1_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd1_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd1_bank_addr;
input  cmd2_is_valid;
input  cmd2_is_a_write;
input  cmd2_is_a_read;
input  cmd2_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd2_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd2_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd2_bank_addr;
input  cmd3_is_valid;
input  cmd3_is_a_write;
input  cmd3_is_a_read;
input  cmd3_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd3_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd3_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd3_bank_addr;
input  cmd4_is_valid;
input  cmd4_is_a_write;
input  cmd4_is_a_read;
input  cmd4_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd4_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd4_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd4_bank_addr;
input  cmd5_is_valid;
input  cmd5_is_a_write;
input  cmd5_is_a_read;
input  cmd5_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd5_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd5_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd5_bank_addr;
input  cmd6_is_valid;
input  cmd6_is_a_write;
input  cmd6_is_a_read;
input  cmd6_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd6_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd6_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd6_bank_addr;
input  cmd7_is_valid;
input  cmd7_is_a_write;
input  cmd7_is_a_read;
input  cmd7_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] cmd7_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] cmd7_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  cmd7_bank_addr;
output [CTL_LOOK_AHEAD_DEPTH - 1 : 0] row_is_open;
output [CTL_LOOK_AHEAD_DEPTH - 1 : 0] bank_is_open;
output [CTL_LOOK_AHEAD_DEPTH - 1 : 0] bank_info_valid;
input  current_is_a_write;
input  current_is_a_read;
input  current_multicast_req;
input  [MEM_IF_CHIP_BITS - 1 : 0] current_chip_addr;
input  [MEM_IF_ROW_WIDTH - 1 : 0] current_row_addr;
input  [MEM_IF_BA_WIDTH - 1 : 0]  current_bank_addr;
output current_row_is_open;
output current_bank_is_open;
output current_bank_info_valid;
input ecc_fetch_error_addr;
input fetch;
input flush1;
input flush2;
input flush3;
input do_activate;
input do_precharge;
input do_precharge_all;
input do_auto_precharge;
input [MEM_IF_CS_WIDTH - 1 : 0]  to_chip;
input [MEM_IF_ROW_WIDTH - 1 : 0] to_row_addr;
input [MEM_IF_BA_WIDTH - 1 : 0]  to_bank_addr;
output [MEM_IF_CS_WIDTH * (2**MEM_IF_BA_WIDTH) * MEM_IF_ROW_WIDTH - 1 : 0]  bank_information ; 
output [MEM_IF_CS_WIDTH * (2**MEM_IF_BA_WIDTH) - 1 : 0]                     bank_open ; 
reg [MEM_IF_CS_WIDTH - 1 : 0] all_banks_closed;
integer ba_count;
integer cs_count1;
integer cs_count2;
reg [(2 ** MEM_IF_BA_WIDTH) - 1 : 0] bank_status [MEM_IF_CS_WIDTH - 1 : 0]; 
reg ecc_fetch_error_addr_r1;
reg ecc_fetch_error_addr_r2;
reg fetch_r1;
reg fetch_r2;
reg flush1_r1;
reg flush2_r1;
reg flush3_r1;
reg [1 : 0] flush;
reg int_current_info_valid;
reg int_current_info_valid_r;
reg cmd_cache;
reg do_activate_r1;
reg [MEM_IF_CHIP_BITS - 1 : 0] to_chip_r1;
reg [MEM_IF_BA_WIDTH  - 1 : 0] to_bank_addr_r1;
reg [MEM_IF_ROW_WIDTH - 1 : 0] to_row_addr_r1;
reg [MEM_IF_BA_WIDTH - 1 : 0]  current_bank_addr_r1;
reg [MEM_IF_ROW_WIDTH - 1 : 0] current_row_addr_r1;
reg current_bank_change;
reg current_row_change;
reg [CTL_CMD_QUEUE_DEPTH : 0] cmd_bank_is_open;
reg [CTL_CMD_QUEUE_DEPTH : 0] cmd_row_is_open;
reg [CTL_LOOK_AHEAD_DEPTH : 0] cmd_do_activate;
reg [CTL_LOOK_AHEAD_DEPTH : 0] cmd_do_precharge;
reg [CTL_LOOK_AHEAD_DEPTH : 0] cmd_do_activate_r1;
reg [CTL_LOOK_AHEAD_DEPTH : 0] cmd_do_precharge_r1;
reg [CTL_LOOK_AHEAD_DEPTH : 0] int_cmd_do_activate_cached;
reg [CTL_LOOK_AHEAD_DEPTH : 0] int_cmd_do_precharge_cached;
reg [CTL_CMD_QUEUE_DEPTH  : 0] cmd_do_activate_cached;
reg [CTL_CMD_QUEUE_DEPTH  : 0] cmd_do_precharge_cached;
wire [(CTL_CMD_QUEUE_DEPTH + 1) * (MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd_addr;
wire [(CTL_CMD_QUEUE_DEPTH + 1) * MEM_IF_CHIP_BITS - 1 : 0] cmd_chip_addr;
wire [(CTL_CMD_QUEUE_DEPTH + 1) * MEM_IF_BA_WIDTH  - 1 : 0] cmd_bank_addr;
wire [(CTL_CMD_QUEUE_DEPTH + 1) * MEM_IF_ROW_WIDTH - 1 : 0] cmd_row_addr;
wire [CTL_CMD_QUEUE_DEPTH : 0] cmd_is_valid;
wire [CTL_CMD_QUEUE_DEPTH : 0] cmd_info_valid;
wire [CTL_CMD_QUEUE_DEPTH : 0] is_a_write;
wire [CTL_CMD_QUEUE_DEPTH : 0] is_a_read;
wire [CTL_CMD_QUEUE_DEPTH : 0] multicast_req;
wire [CTL_CMD_QUEUE_DEPTH : 0] cmd_multicast_req;
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] current_addr = {current_chip_addr, current_bank_addr, current_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd0_addr = {cmd0_chip_addr, cmd0_bank_addr, cmd0_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd1_addr = {cmd1_chip_addr, cmd1_bank_addr, cmd1_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd2_addr = {cmd2_chip_addr, cmd2_bank_addr, cmd2_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd3_addr = {cmd3_chip_addr, cmd3_bank_addr, cmd3_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd4_addr = {cmd4_chip_addr, cmd4_bank_addr, cmd4_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd5_addr = {cmd5_chip_addr, cmd5_bank_addr, cmd5_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd6_addr = {cmd6_chip_addr, cmd6_bank_addr, cmd6_row_addr};
wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] cmd7_addr = {cmd7_chip_addr, cmd7_bank_addr, cmd7_row_addr};
wire [CTL_LOOK_AHEAD_DEPTH - 1 : 0] row_is_open;
wire [CTL_LOOK_AHEAD_DEPTH - 1 : 0] bank_is_open;
wire [CTL_LOOK_AHEAD_DEPTH - 1 : 0] bank_info_valid;
reg [CTL_CMD_QUEUE_DEPTH - 1 : 0]  int_row_is_open;
reg [CTL_CMD_QUEUE_DEPTH - 1 : 0]  int_bank_is_open;
reg [CTL_CMD_QUEUE_DEPTH - 1 : 0]  int_bank_info_valid;
reg current_bank_is_open;
reg current_row_is_open;
reg current_bank_info_valid;
assign cmd_addr           = {cmd7_addr, cmd6_addr, cmd5_addr, cmd4_addr, cmd3_addr, cmd2_addr, cmd1_addr, cmd0_addr, current_addr};
assign cmd_chip_addr      = {cmd7_chip_addr, cmd6_chip_addr, cmd5_chip_addr, cmd4_chip_addr, cmd3_chip_addr, cmd2_chip_addr, cmd1_chip_addr, cmd0_chip_addr, current_chip_addr};
assign cmd_bank_addr      = {cmd7_bank_addr, cmd6_bank_addr, cmd5_bank_addr, cmd4_bank_addr, cmd3_bank_addr, cmd2_bank_addr, cmd1_bank_addr, cmd0_bank_addr, current_bank_addr};
assign cmd_row_addr       = {cmd7_row_addr, cmd6_row_addr, cmd5_row_addr, cmd4_row_addr, cmd3_row_addr, cmd2_row_addr, cmd1_row_addr, cmd0_row_addr, current_row_addr};
assign cmd_is_valid       = {cmd7_is_valid, cmd6_is_valid, cmd5_is_valid, cmd4_is_valid, cmd3_is_valid, cmd2_is_valid, cmd1_is_valid, cmd0_is_valid, 1'b0}; 
assign cmd_info_valid [0] = int_current_info_valid;
assign multicast_req = {cmd7_multicast_req, cmd6_multicast_req, cmd5_multicast_req, cmd4_multicast_req, cmd3_multicast_req, cmd2_multicast_req, cmd1_multicast_req, cmd0_multicast_req, current_multicast_req};
assign is_a_write    = {cmd7_is_a_write, cmd6_is_a_write, cmd5_is_a_write, cmd4_is_a_write, cmd3_is_a_write, cmd2_is_a_write, cmd1_is_a_write, cmd0_is_a_write, current_is_a_write};
assign is_a_read     = {cmd7_is_a_read, cmd6_is_a_read, cmd5_is_a_read, cmd4_is_a_read, cmd3_is_a_read, cmd2_is_a_read, cmd1_is_a_read, cmd0_is_a_read, current_is_a_read};
assign cmd_multicast_req = multicast_req & is_a_write;
assign row_is_open     = int_row_is_open     [CTL_LOOK_AHEAD_DEPTH - 1 : 0];
assign bank_is_open    = int_bank_is_open    [CTL_LOOK_AHEAD_DEPTH - 1 : 0];
assign bank_info_valid = int_bank_info_valid [CTL_LOOK_AHEAD_DEPTH - 1 : 0];
always @ (*)
begin
    if (fetch)
    begin
        if (flush1)
            flush = 2'b01;
        else if (flush2)
            flush = 2'b10;
        else if (flush3)
            flush = 2'b11;
        else
            flush = 2'b00;
    end
    else if (fetch_r1)
    begin
        if (flush1_r1)
            flush = 2'b01;
        else if (flush2_r1)
            flush = 2'b10;
        else if (flush3_r1)
            flush = 2'b11;
        else
            flush = 2'b00;
    end
    else
    begin
        if (flush1 || flush1_r1)
            flush = 2'b00;
        else if (flush2 || flush2_r1)
            flush = 2'b01;
        else if (flush3 || flush3_r1)
            flush = 2'b10;
        else
            flush = 2'b00;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        ecc_fetch_error_addr_r1 <= 1'b0;
        ecc_fetch_error_addr_r2 <= 1'b0;
        fetch_r1                <= 1'b0;
        fetch_r2                <= 1'b0;
    end
    else
    begin
        ecc_fetch_error_addr_r1 <= ecc_fetch_error_addr;
        ecc_fetch_error_addr_r2 <= ecc_fetch_error_addr_r1;
        fetch_r1                <= fetch;
        fetch_r2                <= fetch_r1;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        flush1_r1 <= 1'b0;
        flush2_r1 <= 1'b0;
        flush3_r1 <= 1'b0;
    end
    else
    begin
        flush1_r1 <= flush1;
        flush2_r1 <= flush2;
        flush3_r1 <= flush3;
    end
end
always @ (*)
begin
    begin
        if (fetch || fetch_r1 || flush1 || flush2 || flush3 || flush1_r1 || flush2_r1 || flush3_r1)
            cmd_cache = 1'b1;
        else
            cmd_cache = 1'b0;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        current_bank_is_open    <=  0;
        int_bank_is_open        <=  0;
        current_row_is_open     <=  0;
        int_row_is_open         <=  0;
        current_bank_info_valid <=  0;
        int_bank_info_valid     <=  0;
    end
    else if (cmd_cache)
    begin
        if (flush == 2'b01)
        begin
            current_bank_is_open    <= cmd_bank_is_open [2];
            int_bank_is_open [0]    <= cmd_bank_is_open [3];
            int_bank_is_open [1]    <= cmd_bank_is_open [4];
            int_bank_is_open [2]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [5];
            int_bank_is_open [3]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [6];
            int_bank_is_open [4]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [7];
            int_bank_is_open [5]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [8];
            int_bank_is_open [6]    <= 1'b0;
            int_bank_is_open [7]    <= 1'b0;
            current_row_is_open     <= cmd_row_is_open [2];
            int_row_is_open [0]     <= cmd_row_is_open [3];
            int_row_is_open [1]     <= cmd_row_is_open [4];
            int_row_is_open [2]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [5];
            int_row_is_open [3]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [6];
            int_row_is_open [4]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [7];
            int_row_is_open [5]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [8];
            int_row_is_open [6]     <= 1'b0;
            int_row_is_open [7]     <= 1'b0;
            current_bank_info_valid <= cmd_info_valid[2];
            int_bank_info_valid [0] <= cmd_info_valid[3];
            int_bank_info_valid [1] <= cmd_info_valid[4];
            int_bank_info_valid [2] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [5];
            int_bank_info_valid [3] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [6];
            int_bank_info_valid [4] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [7];
            int_bank_info_valid [5] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [8];
            int_bank_info_valid [6] <= 1'b0;
            int_bank_info_valid [7] <= 1'b0;
        end
        else if (flush == 2'b10)
        begin
            current_bank_is_open    <= cmd_bank_is_open [3];
            int_bank_is_open [0]    <= cmd_bank_is_open [4];
            int_bank_is_open [1]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [5];
            int_bank_is_open [2]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [6];
            int_bank_is_open [3]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [7];
            int_bank_is_open [4]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [8];
            int_bank_is_open [5]    <= 1'b0;
            int_bank_is_open [6]    <= 1'b0;
            int_bank_is_open [7]    <= 1'b0;
            current_row_is_open     <= cmd_row_is_open [3];
            int_row_is_open [0]     <= cmd_row_is_open [4];
            int_row_is_open [1]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [5];
            int_row_is_open [2]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [6];
            int_row_is_open [3]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [7];
            int_row_is_open [4]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [8];
            int_row_is_open [5]     <= 1'b0;
            int_row_is_open [6]     <= 1'b0;
            int_row_is_open [7]     <= 1'b0;
            current_bank_info_valid <= cmd_info_valid[3];
            int_bank_info_valid [0] <= cmd_info_valid[4];
            int_bank_info_valid [1] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [5];
            int_bank_info_valid [2] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [6];
            int_bank_info_valid [3] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [7];
            int_bank_info_valid [4] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [8];
            int_bank_info_valid [5] <= 1'b0;
            int_bank_info_valid [6] <= 1'b0;
            int_bank_info_valid [7] <= 1'b0;
        end
        else if (flush == 2'b11)
        begin
            current_bank_is_open    <= cmd_bank_is_open [4];
            int_bank_is_open [0]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [5];
            int_bank_is_open [1]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [6];
            int_bank_is_open [2]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [7];
            int_bank_is_open [3]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [8];
            int_bank_is_open [4]    <= 1'b0;
            int_bank_is_open [5]    <= 1'b0;
            int_bank_is_open [6]    <= 1'b0;
            int_bank_is_open [7]    <= 1'b0;
            current_row_is_open     <= cmd_row_is_open [4];
            int_row_is_open [0]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [5];
            int_row_is_open [1]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [6];
            int_row_is_open [2]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [7];
            int_row_is_open [3]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [8];
            int_row_is_open [4]     <= 1'b0;
            int_row_is_open [5]     <= 1'b0;
            int_row_is_open [6]     <= 1'b0;
            int_row_is_open [7]     <= 1'b0;
            current_bank_info_valid <= cmd_info_valid[4];
            int_bank_info_valid [0] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [5];
            int_bank_info_valid [1] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [6];
            int_bank_info_valid [2] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [7];
            int_bank_info_valid [3] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [8];
            int_bank_info_valid [4] <= 1'b0;
            int_bank_info_valid [5] <= 1'b0;
            int_bank_info_valid [6] <= 1'b0;
            int_bank_info_valid [7] <= 1'b0;
        end
        else
        begin
            current_bank_is_open    <= cmd_bank_is_open [1];
            int_bank_is_open [0]    <= cmd_bank_is_open [2];
            int_bank_is_open [1]    <= cmd_bank_is_open [3];
            int_bank_is_open [2]    <= cmd_bank_is_open [4];
            int_bank_is_open [3]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [5];
            int_bank_is_open [4]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [6];
            int_bank_is_open [5]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [7];
            int_bank_is_open [6]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [8];
            int_bank_is_open [7]    <= 1'b0;
            current_row_is_open     <= cmd_row_is_open [1];
            int_row_is_open [0]     <= cmd_row_is_open [2];
            int_row_is_open [1]     <= cmd_row_is_open [3];
            int_row_is_open [2]     <= cmd_row_is_open [4];
            int_row_is_open [3]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [5];
            int_row_is_open [4]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [6];
            int_row_is_open [5]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [7];
            int_row_is_open [6]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [8];
            int_row_is_open [7]     <= 1'b0;
            current_bank_info_valid <= cmd_info_valid [1];
            int_bank_info_valid [0] <= cmd_info_valid [2];
            int_bank_info_valid [1] <= cmd_info_valid [3];
            int_bank_info_valid [2] <= cmd_info_valid [4];
            int_bank_info_valid [3] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [5];
            int_bank_info_valid [4] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [6];
            int_bank_info_valid [5] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [7];
            int_bank_info_valid [6] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [8];
            int_bank_info_valid [7] <= 1'b0;
        end
    end
    else
    begin
        if (current_bank_change)
            current_bank_info_valid <= 1'b0;
        else
            current_bank_info_valid <= cmd_info_valid [0];
        if (current_row_change)
            current_row_is_open <= 1'b0;
        else
            current_row_is_open <= cmd_row_is_open [0];
        current_bank_is_open    <= cmd_bank_is_open [0];
        int_bank_is_open [0]    <= cmd_bank_is_open [1];
        int_bank_is_open [1]    <= cmd_bank_is_open [2];
        int_bank_is_open [2]    <= cmd_bank_is_open [3];
        int_bank_is_open [3]    <= cmd_bank_is_open [4];
        int_bank_is_open [4]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [5];
        int_bank_is_open [5]    <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_bank_is_open [6];
        int_bank_is_open [6]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [7];
        int_bank_is_open [7]    <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_bank_is_open [8];
        int_row_is_open [0]     <= cmd_row_is_open [1];
        int_row_is_open [1]     <= cmd_row_is_open [2];
        int_row_is_open [2]     <= cmd_row_is_open [3];
        int_row_is_open [3]     <= cmd_row_is_open [4];
        int_row_is_open [4]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [5];
        int_row_is_open [5]     <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_row_is_open [6];
        int_row_is_open [6]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [7];
        int_row_is_open [7]     <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_row_is_open [8];
        int_bank_info_valid [0] <= cmd_info_valid [1];
        int_bank_info_valid [1] <= cmd_info_valid [2];
        int_bank_info_valid [2] <= cmd_info_valid [3];
        int_bank_info_valid [3] <= cmd_info_valid [4];
        int_bank_info_valid [4] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [5];
        int_bank_info_valid [5] <= (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : cmd_info_valid [6];
        int_bank_info_valid [6] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [7];
        int_bank_info_valid [7] <= (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : cmd_info_valid [8];
    end
end
always @ (*)
begin
    if (cmd_cache)
    begin
        if (flush == 2'b01)
        begin
            cmd_do_activate_cached [0] = 1'b0;
            cmd_do_activate_cached [1] = 1'b0;
            cmd_do_activate_cached [2] = int_cmd_do_activate_cached [0];
            cmd_do_activate_cached [3] = int_cmd_do_activate_cached [1];
            cmd_do_activate_cached [4] = int_cmd_do_activate_cached [2];
            cmd_do_activate_cached [5] = int_cmd_do_activate_cached [3];
            cmd_do_activate_cached [6] = int_cmd_do_activate_cached [4];
            cmd_do_activate_cached [7] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_activate_cached [5];
            cmd_do_activate_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_activate_cached [6];
            cmd_do_precharge_cached [0] = 1'b0;
            cmd_do_precharge_cached [1] = 1'b0;
            cmd_do_precharge_cached [2] = int_cmd_do_precharge_cached [0];
            cmd_do_precharge_cached [3] = int_cmd_do_precharge_cached [1];
            cmd_do_precharge_cached [4] = int_cmd_do_precharge_cached [2];
            cmd_do_precharge_cached [5] = int_cmd_do_precharge_cached [3];
            cmd_do_precharge_cached [6] = int_cmd_do_precharge_cached [4];
            cmd_do_precharge_cached [7] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_precharge_cached [5];
            cmd_do_precharge_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_precharge_cached [6];
        end
        else if (flush == 2'b10)
        begin
            cmd_do_activate_cached [0] = 1'b0;
            cmd_do_activate_cached [1] = 1'b0;
            cmd_do_activate_cached [2] = 1'b0;
            cmd_do_activate_cached [3] = int_cmd_do_activate_cached [0];
            cmd_do_activate_cached [4] = int_cmd_do_activate_cached [1];
            cmd_do_activate_cached [5] = int_cmd_do_activate_cached [2];
            cmd_do_activate_cached [6] = int_cmd_do_activate_cached [3];
            cmd_do_activate_cached [7] = int_cmd_do_activate_cached [4];
            cmd_do_activate_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_activate_cached [5];
            cmd_do_precharge_cached [0] = 1'b0;
            cmd_do_precharge_cached [1] = 1'b0;
            cmd_do_precharge_cached [2] = 1'b0;
            cmd_do_precharge_cached [3] = int_cmd_do_precharge_cached [0];
            cmd_do_precharge_cached [4] = int_cmd_do_precharge_cached [1];
            cmd_do_precharge_cached [5] = int_cmd_do_precharge_cached [2];
            cmd_do_precharge_cached [6] = int_cmd_do_precharge_cached [3];
            cmd_do_precharge_cached [7] = int_cmd_do_precharge_cached [4];
            cmd_do_precharge_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_precharge_cached [5];
        end
        else if (flush == 2'b11)
        begin
            cmd_do_activate_cached [0] = 1'b0;
            cmd_do_activate_cached [1] = 1'b0;
            cmd_do_activate_cached [2] = 1'b0;
            cmd_do_activate_cached [3] = 1'b0;
            cmd_do_activate_cached [4] = int_cmd_do_activate_cached [0];
            cmd_do_activate_cached [5] = int_cmd_do_activate_cached [1];
            cmd_do_activate_cached [6] = int_cmd_do_activate_cached [2];
            cmd_do_activate_cached [7] = int_cmd_do_activate_cached [3];
            cmd_do_activate_cached [8] = int_cmd_do_activate_cached [4];
            cmd_do_precharge_cached [0] = 1'b0;
            cmd_do_precharge_cached [1] = 1'b0;
            cmd_do_precharge_cached [2] = 1'b0;
            cmd_do_precharge_cached [3] = 1'b0;
            cmd_do_precharge_cached [4] = int_cmd_do_precharge_cached [0];
            cmd_do_precharge_cached [5] = int_cmd_do_precharge_cached [1];
            cmd_do_precharge_cached [6] = int_cmd_do_precharge_cached [2];
            cmd_do_precharge_cached [7] = int_cmd_do_precharge_cached [3];
            cmd_do_precharge_cached [8] = int_cmd_do_precharge_cached [4];
        end
        else
        begin
            cmd_do_activate_cached [0] = 1'b0;
            cmd_do_activate_cached [1] = int_cmd_do_activate_cached [0];
            cmd_do_activate_cached [2] = int_cmd_do_activate_cached [1];
            cmd_do_activate_cached [3] = int_cmd_do_activate_cached [2];
            cmd_do_activate_cached [4] = int_cmd_do_activate_cached [3];
            cmd_do_activate_cached [5] = int_cmd_do_activate_cached [4];
            cmd_do_activate_cached [6] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_activate_cached [5];
            cmd_do_activate_cached [7] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_activate_cached [6];
            cmd_do_activate_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : int_cmd_do_activate_cached [7];
            cmd_do_precharge_cached [0] = 1'b0;
            cmd_do_precharge_cached [1] = int_cmd_do_precharge_cached [0];
            cmd_do_precharge_cached [2] = int_cmd_do_precharge_cached [1];
            cmd_do_precharge_cached [3] = int_cmd_do_precharge_cached [2];
            cmd_do_precharge_cached [4] = int_cmd_do_precharge_cached [3];
            cmd_do_precharge_cached [5] = int_cmd_do_precharge_cached [4];
            cmd_do_precharge_cached [6] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_precharge_cached [5];
            cmd_do_precharge_cached [7] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_precharge_cached [6];
            cmd_do_precharge_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : int_cmd_do_precharge_cached [7];
        end
    end
    else
    begin
        cmd_do_activate_cached [0] = int_cmd_do_activate_cached [0];
        cmd_do_activate_cached [1] = int_cmd_do_activate_cached [1];
        cmd_do_activate_cached [2] = int_cmd_do_activate_cached [2];
        cmd_do_activate_cached [3] = int_cmd_do_activate_cached [3];
        cmd_do_activate_cached [4] = int_cmd_do_activate_cached [4];
        cmd_do_activate_cached [5] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_activate_cached [5];
        cmd_do_activate_cached [6] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_activate_cached [6];
        cmd_do_activate_cached [7] = (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : int_cmd_do_activate_cached [7];
        cmd_do_activate_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : int_cmd_do_activate_cached [8];
        cmd_do_precharge_cached [0] = int_cmd_do_precharge_cached [0];
        cmd_do_precharge_cached [1] = int_cmd_do_precharge_cached [1];
        cmd_do_precharge_cached [2] = int_cmd_do_precharge_cached [2];
        cmd_do_precharge_cached [3] = int_cmd_do_precharge_cached [3];
        cmd_do_precharge_cached [4] = int_cmd_do_precharge_cached [4];
        cmd_do_precharge_cached [5] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_precharge_cached [5];
        cmd_do_precharge_cached [6] = (CTL_LOOK_AHEAD_DEPTH <= 4) ? 1'b0 : int_cmd_do_precharge_cached [6];
        cmd_do_precharge_cached [7] = (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : int_cmd_do_precharge_cached [7];
        cmd_do_precharge_cached [8] = (CTL_LOOK_AHEAD_DEPTH <= 6) ? 1'b0 : int_cmd_do_precharge_cached [8];
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        current_bank_addr_r1 <= 0;
        current_row_addr_r1  <= 0;
    end
    else
    begin
        current_bank_addr_r1 <= current_bank_addr;
        current_row_addr_r1  <= current_row_addr;
    end
end
always @ (*)
begin
    begin
        if (current_bank_addr != current_bank_addr_r1)
            current_bank_change <= 1'b1;
        else
            current_bank_change <= 1'b0;
        if (current_row_addr != current_row_addr_r1)
            current_row_change <= 1'b1;
        else
            current_row_change <= 1'b0;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        do_activate_r1 <= 1'b0;
    end
    else
    begin
        do_activate_r1 <= do_activate;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        to_chip_r1      <= 0;
        to_bank_addr_r1 <= 0;
        to_row_addr_r1  <= 0;
    end
    else
    begin
        to_chip_r1      <= to_chip;
        to_bank_addr_r1 <= to_bank_addr;
        to_row_addr_r1  <= to_row_addr;
    end
end
generate
begin
    genvar w;
    for (w = 0;w < CTL_LOOK_AHEAD_DEPTH + 1;w = w + 1)
    begin : input_do_signal_fanout_per_cmd
        wire [MEM_IF_CHIP_BITS - 1 : 0] chip_addr = cmd_chip_addr [(w + 1) * MEM_IF_CHIP_BITS - 1 : w * MEM_IF_CHIP_BITS];
        wire [MEM_IF_BA_WIDTH  - 1 : 0] bank_addr = cmd_bank_addr [(w + 1) * MEM_IF_BA_WIDTH  - 1 : w * MEM_IF_BA_WIDTH];
        wire [MEM_IF_ROW_WIDTH - 1 : 0] row_addr  = cmd_row_addr  [(w + 1) * MEM_IF_ROW_WIDTH - 1 : w * MEM_IF_ROW_WIDTH];
        always @ (*)
        begin
            if (cmd_multicast_req [w]) 
            begin
                if (do_activate && &to_chip && to_bank_addr == bank_addr && to_row_addr == row_addr)
                    cmd_do_activate [w] = 1'b1;
                else
                    cmd_do_activate [w] = 1'b0;
            end
            else
            begin
                if (do_activate && to_chip [chip_addr] && to_bank_addr == bank_addr && to_row_addr == row_addr)
                    cmd_do_activate [w] = 1'b1;
                else
                    cmd_do_activate [w] = 1'b0;
            end
            if (cmd_multicast_req [w]) 
            begin
                if ((((do_auto_precharge || do_precharge) && to_bank_addr == bank_addr) || do_precharge_all) && &to_chip)
                    cmd_do_precharge [w] = 1'b1;
                else
                    cmd_do_precharge [w] = 1'b0;
            end
            else
            begin
                if ((((do_auto_precharge || do_precharge) && to_bank_addr == bank_addr) || do_precharge_all) && to_chip [chip_addr])
                    cmd_do_precharge [w] = 1'b1;
                else
                    cmd_do_precharge [w] = 1'b0;
            end
        end
        always @ (posedge ctl_clk or negedge ctl_reset_n)
        begin
            if (!ctl_reset_n)
            begin
                cmd_do_activate_r1  [w] <= 1'b0;
                cmd_do_precharge_r1 [w] <= 1'b0;
            end
            else
            begin
                cmd_do_activate_r1  [w] <= cmd_do_activate  [w];
                cmd_do_precharge_r1 [w] <= cmd_do_precharge [w];
            end
        end
        always @ (*)
        begin
            int_cmd_do_activate_cached [w] <= cmd_do_activate [w];
        end
        always @ (*)
        begin
            int_cmd_do_precharge_cached [w] <= cmd_do_precharge [w];
        end
    end
end
endgenerate
reg [MEM_IF_ROW_WIDTH - 1 : 0] row_information [MEM_IF_CS_WIDTH - 1 : 0] [(2 ** MEM_IF_BA_WIDTH) - 1 : 0];
generate
    genvar x_outer;
    genvar x_inner;
    for (x_outer = 0;x_outer < MEM_IF_CS_WIDTH;x_outer = x_outer + 1)
    begin : row_information_per_chip
        for (x_inner = 0;x_inner < (2 ** MEM_IF_BA_WIDTH);x_inner = x_inner + 1)
        begin : row_information_per_bank
            always @ (posedge ctl_clk or negedge ctl_reset_n)
            begin
                if (!ctl_reset_n)
                begin
                    row_information [x_outer][x_inner] <= 0;
                end
                else
                begin
                    if (do_activate && to_chip [x_outer] && x_inner == to_bank_addr)
                        row_information [x_outer][x_inner] <= to_row_addr;
                end
            end
        end
    end
endgenerate
generate
    genvar m_cs;
    genvar m_bank;
    genvar m_rowbit;
    for (m_cs = 0;m_cs < MEM_IF_CS_WIDTH;m_cs = m_cs + 1)
    begin : bank_information_cs
        for (m_bank = 0;m_bank < (2 ** MEM_IF_BA_WIDTH);m_bank = m_bank + 1)
        begin : bank_information_bank
            wire [MEM_IF_ROW_WIDTH - 1 : 0] bankaware_row   = row_information[m_cs] [m_bank];
            wire                            bankaware_open  = bank_status    [m_cs] [m_bank];
            assign bank_open[m_cs * (2 ** MEM_IF_BA_WIDTH) + m_bank] = bankaware_open;
            for (m_rowbit = 0; m_rowbit < MEM_IF_ROW_WIDTH; m_rowbit = m_rowbit + 1)
            begin : bank_information_row
                assign bank_information[ ( (m_cs * (2 ** MEM_IF_BA_WIDTH) * MEM_IF_ROW_WIDTH) + (m_bank * MEM_IF_ROW_WIDTH) + m_rowbit) ] = bankaware_row[m_rowbit];
            end
        end
    end
endgenerate
generate
    genvar z;
    genvar z_inner;
    for (z = 0; z < CTL_LOOK_AHEAD_DEPTH + 1;z = z + 1)
    begin : CMD
        reg [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] int_cmd_addr_r1;
        reg [MEM_IF_CS_WIDTH - 1 : 0]  int_cmd_row_is_open;
        reg [MEM_IF_CS_WIDTH - 1 : 0]  int_cmd_to_chip;
        reg [MEM_IF_CS_WIDTH - 1 : 0]  int_cmd_to_chip_r1;
        reg [MEM_IF_CS_WIDTH - 1 : 0]  int_cmd_bank_is_open;
        reg int_cmd_multicast_req_r1;
        wire [(MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH) - 1 : 0] int_cmd_addr;
        wire [MEM_IF_CHIP_BITS - 1 : 0] int_cmd_chip_addr;
        wire [MEM_IF_ROW_WIDTH - 1 : 0] int_cmd_row_addr;
        wire [MEM_IF_BA_WIDTH - 1 : 0]  int_cmd_bank_addr;
        wire [MEM_IF_CHIP_BITS - 1 : 0] int_cmd_chip_addr_r1;
        wire [MEM_IF_ROW_WIDTH - 1 : 0] int_cmd_row_addr_r1;
        wire [MEM_IF_BA_WIDTH - 1 : 0]  int_cmd_bank_addr_r1;
        wire [MEM_IF_CS_WIDTH * MEM_IF_ROW_WIDTH - 1 : 0] int_cmd_ram_rd_data;
        wire int_cmd_multicast_req;
        assign int_cmd_addr          = cmd_addr[((z + 1) * (MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH)) - 1 : (z * (MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH))];
        assign int_cmd_chip_addr     = int_cmd_addr [MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH - 1 : MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH];
        assign int_cmd_bank_addr     = int_cmd_addr [MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH - 1 : MEM_IF_ROW_WIDTH];
        assign int_cmd_row_addr      = int_cmd_addr [MEM_IF_ROW_WIDTH - 1 : 0];
        assign int_cmd_chip_addr_r1  = int_cmd_addr_r1 [MEM_IF_CHIP_BITS + MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH - 1 : MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH];
        assign int_cmd_bank_addr_r1  = int_cmd_addr_r1 [MEM_IF_BA_WIDTH + MEM_IF_ROW_WIDTH - 1 : MEM_IF_ROW_WIDTH];
        assign int_cmd_row_addr_r1   = int_cmd_addr_r1 [MEM_IF_ROW_WIDTH - 1 : 0];
        assign int_cmd_multicast_req = cmd_multicast_req [z];
        always @ (*)
        begin
            int_cmd_to_chip = 0;
            int_cmd_to_chip [int_cmd_chip_addr] = 1'b1;
        end
        always @ (posedge ctl_clk or negedge ctl_reset_n)
        begin
            if (!ctl_reset_n)
            begin
                int_cmd_addr_r1 <= 0;
            end
            else
            begin
                int_cmd_addr_r1 <= int_cmd_addr;
            end
        end
        always @ (posedge ctl_clk or negedge ctl_reset_n)
        begin
            if (!ctl_reset_n)
            begin
                int_cmd_to_chip_r1 <= 0;
            end
            else
            begin
                int_cmd_to_chip_r1 <= int_cmd_to_chip;
            end
        end
        always @ (posedge ctl_clk or negedge ctl_reset_n)
        begin
            if (!ctl_reset_n)
            begin
                int_cmd_multicast_req_r1 <= 1'b0;
            end
            else
            begin
                int_cmd_multicast_req_r1 <= int_cmd_multicast_req;
            end
        end
        always @ (*)
        begin
            if (cmd_do_precharge_cached [z])
                cmd_bank_is_open [z] = 1'b0;
            else if (cmd_do_precharge_r1 [z])
                cmd_bank_is_open [z] = 1'b0;
            else if (cmd_do_activate_cached [z])
                cmd_bank_is_open [z] = 1'b1;
            else if (cmd_do_activate_r1 [z])
                cmd_bank_is_open [z] = 1'b1;
            else
            begin
                if (int_cmd_multicast_req_r1)
                    cmd_bank_is_open [z] = |int_cmd_bank_is_open;
                else
                    cmd_bank_is_open [z] = int_cmd_bank_is_open [int_cmd_chip_addr_r1];
            end
        end
        always @ (*)
        begin
            if (cmd_do_activate_cached [z])
                cmd_row_is_open [z] = 1'b1;
            else if (cmd_do_activate_r1 [z])
                cmd_row_is_open [z] = 1'b1;
            else
            begin
                if (int_cmd_multicast_req_r1)
                    cmd_row_is_open [z] = &int_cmd_row_is_open;
                else
                    cmd_row_is_open [z] = int_cmd_row_is_open [int_cmd_chip_addr_r1];
            end
        end
        for (z_inner = 0;z_inner < MEM_IF_CS_WIDTH;z_inner = z_inner + 1)
        begin : row_is_open_loop
            wire [MEM_IF_ROW_WIDTH - 1 : 0] int_read_data = row_information [z_inner][int_cmd_bank_addr];
            wire                            int_bank_data = bank_status     [z_inner][int_cmd_bank_addr];
            always @ (posedge ctl_clk or negedge ctl_reset_n)
            begin
                if (!ctl_reset_n)
                    int_cmd_bank_is_open [z_inner] <= 1'b0;
                else
                    int_cmd_bank_is_open [z_inner] <= int_bank_data;
            end
            always @ (posedge ctl_clk or negedge ctl_reset_n)
            begin
                if (!ctl_reset_n)
                    int_cmd_row_is_open [z_inner] <= 1'b0;
                else
                begin
                    if (int_read_data == int_cmd_row_addr)
                        int_cmd_row_is_open [z_inner] <= 1'b1 & int_bank_data;
                    else
                        int_cmd_row_is_open [z_inner] <= 1'b0;
                end
            end
        end
    end
endgenerate
generate
    genvar Y;
    for (Y = 1; Y < CTL_LOOK_AHEAD_DEPTH + 1;Y = Y + 1)
    begin : VALID
        reg int_cmd_info_valid;
        wire int_cmd_info_valid_r1;
        reg int_cmd_is_valid_r1;
        reg int_cmd_is_valid_r2;
        wire int_cmd_is_valid;
        assign int_cmd_is_valid = cmd_is_valid [Y];
        assign int_cmd_info_valid_r1 = int_cmd_info_valid;
        assign cmd_info_valid [Y] = int_cmd_info_valid_r1;
        always @ (posedge ctl_clk or negedge ctl_reset_n)
        begin
            if (!ctl_reset_n)
            begin
                int_cmd_info_valid    <= 1'b0;
            end
            else
            begin
                int_cmd_info_valid    <= int_cmd_is_valid;
            end
        end
    end
endgenerate
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    int_current_info_valid_r <= 1'b0;
    else
    int_current_info_valid_r <= int_current_info_valid;
end
always @ (*)
begin
    begin
        if (fetch)
            int_current_info_valid <= 1'b0;
        else if (fetch_r2)
            int_current_info_valid <= 1'b1;
        else if (ecc_fetch_error_addr)
            int_current_info_valid <= 1'b0;
        else if (ecc_fetch_error_addr_r2)
            int_current_info_valid <= 1'b1;
        else
            int_current_info_valid <= int_current_info_valid_r;
    end
end
integer i;
integer j;
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        for (i = 0;i < MEM_IF_CS_WIDTH;i = i + 1'b1)
        begin : bank_status_init_outer_loop
            bank_status [i] <= 0;
        end
    end
    else
    begin
        i <= 0;
        for (cs_count2 = 0;cs_count2 < MEM_IF_CS_WIDTH;cs_count2 = cs_count2 + 1'b1)
        begin : bank_status_per_chip
            if (to_chip [cs_count2])
            begin
                if (do_precharge_all)
                    bank_status [cs_count2][(2 ** MEM_IF_BA_WIDTH) - 1 : 0] <= 0;
                else if (do_precharge || do_auto_precharge)
                    bank_status [cs_count2][to_bank_addr] <= 1'b0;
                else if (do_activate)
                    bank_status [cs_count2][to_bank_addr] <= 1'b1;
            end
        end
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        all_banks_closed <= 0;
    end
    else
    begin
        for (cs_count1 = 0;cs_count1 < MEM_IF_CS_WIDTH;cs_count1 = cs_count1 + 1'b1)
        begin : all_banks_closed_per_chip
            if (do_activate && to_chip[cs_count1]) 
                all_banks_closed [cs_count1] <= 1'b0;
            else if (!(|bank_status [cs_count1][(2 ** MEM_IF_BA_WIDTH) - 1 : 0]))
                all_banks_closed [cs_count1] <= 1'b1;
            else
                all_banks_closed [cs_count1] <= 1'b0;
        end
    end
end
endmodule
