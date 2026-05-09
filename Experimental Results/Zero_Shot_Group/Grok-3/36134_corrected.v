module i2c_bus_controller(
    input           iCLK,
    input           iRST_n,
    input           iStart,
    input   [2:0]   iSlave_addr,
    input   [7:0]   iWord_addr,
    input   [7:0]   iRead_length,
    input   [7:0]   wr_data,
    input           wr_cmd,
    input           iSequential_read,
    inout           i2c_data,
    output          oSYSTEM_STATE,
    output          oCONFIG_DONE,
    output  reg [1:0]   i2c_clk_cnt,
    output  reg [5:0]   i2c_state,
    output  reg [2:0]   i2c_bit_cnt,
    output  reg         system_clk,
    output  reg         i2c_clk_src,
    output  wire        process_en,
    output  wire        falling_edge,
    output  wire        rising_edge,
    output  wire        start_data_control,
    output  wire        stop_data_control,
    output  wire        i2c_clk,
    output  wire        start_clk_control,
    output  wire        stop_clk_control,
    output  reg         i2c_master_out,
    output  reg         shift_out,
    output  reg [7:0]   read_data_tmp,
    output  wire        i2c_slave_out,
    output  wire        i2c_read_done,
    output  reg [7:0]   i2c_read_data,
    output  reg [7:0]   read_length,
    output  wire        i2c_read_data_rdy,
    output  reg [1:0]   test_cnt,
    output  wire        test_start,
    output  wire        slave_addr1_shift_en,
    output  wire        slave_addr2_shift_en,
    output  wire        word_addr1_shift_en,
    output  wire        data_shift_en,
    output  wire        wr_data_en,
    output  reg [2:0]   i2c_stop_ctrl_cnt
);

parameter   state_idle          = 6'd0,
            state_start1        = 6'd1,
            state_slave_addr1   = 6'd2,
            state_slave_addr_ack1 = 6'd3,
            state_word_addr1    = 6'd4,
            state_word_addr_ack = 6'd5,
            state_start2        = 6'd6,
            state_slave_addr2   = 6'd7,
            state_slave_addr_ack2 = 6'd8,
            state_data1         = 6'd9,
            state_non_ack       = 6'd10,
            state_master_ack    = 6'd11,
            state_stop          = 6'd12,
            state_ack_error     = 6'd13,
            state_wr_data       = 6'd14,
            state_wr_ack        = 6'd15;

wire    [7:0]   slave_addr_1, slave_addr_2;
wire            shift_enable;
reg     [1:0]   test_start_d;

assign process_en = (i2c_state > 0) ? 1'b1 : 1'b0;
assign falling_edge = (i2c_clk_cnt == 2'd0 && process_en) ? 1'b1 : 1'b0;
assign rising_edge = (i2c_clk_cnt == 2'd3 && process_en) ? 1'b1 : 1'b0;
assign start_data_control = (((i2c_state == state_start1) || (i2c_state == state_start2)) && (i2c_clk_cnt > 1)) ? 1'b1 : 1'b0;
assign stop_data_control = (i2c_state == state_stop && i2c_stop_ctrl_cnt > 3'd1) ? 1'b1 : 1'b0;
assign start_clk_control = (i2c_state == state_start1 && i2c_clk_cnt == 2'd1) ? 1'b0 : 1'b1;
assign stop_clk_control = (i2c_state == state_stop && i2c_clk_cnt == 2'd2) ? 1'b0 : 1'b1;
assign i2c_clk = (i2c_state == state_start1) ? start_clk_control :
                (i2c_state == state_stop) ? stop_clk_control :
                process_en ? i2c_clk_src : 1'b1;
assign slave_addr_1 = {iSlave_addr, 1'b0};
assign slave_addr_2 = {iSlave_addr, 1'b1};

always @(posedge iCLK or negedge iRST_n) begin
    if (!iRST_n)
        test_cnt <= 2'b0;
    else
        test_cnt <= test_cnt + 1'b1;
end

always @(posedge iCLK or negedge iRST_n) begin
    if (!iRST_n)
        i2c_clk_cnt <= 2'b0;
    else
        i2c_clk_cnt <= i2c_clk_cnt + 1'b1;
end

always @(posedge iCLK or negedge iRST_n) begin
    if (!iRST_n)
        i2c_clk_src <= 1'b0;
    else if (i2c_clk_cnt > 1)
        i2c_clk_src <= 1'b1;
    else
        i2c_clk_src <= 1'b0;
end

always @(posedge iCLK or negedge iRST_n) begin
    if (!iRST_n)
        system_clk <= 1'b0;
    else if (i2c_clk_cnt > 0 && i2c_clk_cnt < 3)
        system_clk <= 1'b1;
    else
        system_clk <= 1'b0;
end

always @(posedge system_clk or negedge iRST_n) begin
    if (!iRST_n) begin
        i2c_state <= state_idle;
    end
    else begin
        case(i2c_state)
            state_idle:
                if (iStart)
                    i2c_state <= state_start1;
                else
                    i2c_state <= state_idle;
            state_start1:
                i2c_state <= state_slave_addr1;
            state_slave_addr1:
                if (i2c_bit_cnt == 3'd7)
                    i2c_state <= state_slave_addr_ack1;
                else
                    i2c_state <= state_slave_addr1;
            state_slave_addr_ack1:
                i2c_state <= state_word_addr1;
            state_word_addr1:
                if (i2c_bit_cnt == 3'd7)
                    i2c_state <= state_word_addr_ack;
                else
                    i2c_state <= state_word_addr1;
            state_word_addr_ack:
                if (wr_cmd)
                    i2c_state <= state_wr_data;
                else
                    i2c_state <= state_start2;
            state_start2:
                i2c_state <= state_slave_addr2;
            state_slave_addr2:
                if (i2c_bit_cnt == 3'd7)
                    i2c_state <= state_slave_addr_ack2;
                else
                    i2c_state <= state_slave_addr2;
            state_slave_addr_ack2:
                i2c_state <= state_data1;
            state_data1:
                if (i2c_bit_cnt == 3'd7)
                    if (iSequential_read) begin
                        if (read_length == 8'd0)
                            i2c_state <= state_non_ack;
                        else
                            i2c_state <= state_master_ack;
                    end
                    else
                        i2c_state <= state_non_ack;
                else
                    i2c_state <= state_data1;
            state_master_ack:
                i2c_state <= state_data1;
            state_non_ack:
                i2c_state <= state_stop;
            state_wr_data:
                if (i2c_bit_cnt == 3'd7)
                    i2c_state <= state_wr_ack;
                else
                    i2c_state <= state_wr_data;
            state_wr_ack:
                i2c_state <= state_stop;
            state_stop:
                i2c_state <= state_idle;
            default:
                i2c_state <= state_idle;
        endcase
    end
end

assign shift_enable = (i2c_state == state_slave_addr1) ||
                    (i2c_state == state_word_addr1) ||
                    (i2c_state == state_slave_addr2) ||
                    (i2c_state == state_wr_data) ||
                    (i2c_state == state_data1);

assign slave_addr1_shift_en = (i2c_state == state_slave_addr1) ? 1'b1 : 1'b0;
assign word_addr1_shift_en = (i2c_state == state_word_addr1) ? 1'b1 : 1'b0;
assign slave_addr2_shift_en = (i2c_state == state_slave_addr2) ? 1'b1 : 1'b0;
assign data_shift_en = (i2c_state == state_data1) ? 1'b1 : 1'b0;
assign wr_data_en = (i2c_state == state_wr_data) ? 1'b1 : 1'b0;

always @(posedge system_clk or negedge iRST_n) begin
    if (!iRST_n)
        i2c_bit_cnt <= 3'b0;
    else if (i2c_bit_cnt == 3'd7)
        i2c_bit_cnt <= 3'b0;
    else if (shift_enable)
        i2c_bit_cnt <= i2c_bit_cnt + 1'b1;
    else
        i2c_bit_cnt <= i2c_bit_cnt;
end

always @(*) begin
    if (slave_addr1_shift_en)
        shift_out = slave_addr_1[7-i2c_bit_cnt];
    else if (word_addr1_shift_en)
        shift_out = iWord_addr[7-i2c_bit_cnt];
    else if (slave_addr2_shift_en)
        shift_out = slave_addr_2[7-i2c_bit_cnt];
    else if (wr_data_en)
        shift_out = wr_data[7-i2c_bit_cnt];
    else
        shift_out = 1'b0;
end

always @(*) begin
    case(i2c_state)
        state_start1, state_start2:
            i2c_master_out = start_data_control;
        state_slave_addr1, state_word_addr1, state_slave_addr2, state_wr_data:
            i2c_master_out = shift_out;
        state_stop:
            i2c_master_out = stop_data_control;
        state_slave_addr_ack1, state_word_addr_ack, state_slave_addr_ack2, state_wr_ack, state_data1:
            i2c_master_out = 1'b1;
        state_master_ack:
            i2c_master_out = 1'b0;
        state_non_ack:
            i2c_master_out = 1'b1;
        default:
            i2c_master_out = 1'b1;
    endcase
end

assign i2c_slave_out = (data_shift_en ||
                       i2c_state == state_slave_addr_ack1 ||
                       i2c_state == state_word_addr_ack ||
                       i2c_state == state_wr_ack ||
                       i2c_state == state_slave_addr_ack2) ? 1'b1 : 1'b0;

assign i2c_data = i2c_slave_out ? 1'bz : i2c_master_out;

always @(posedge iCLK or negedge iRST_n) begin
    if (!iRST_n)
        read_data_tmp <= 8'b0;
    else if (i2c_state == state_data1 && falling_edge)
        read_data_tmp <= {read_data_tmp[6:0], i2c_data};
end

always @(posedge iCLK or negedge iRST_n) begin
    if (!iRST_n)
        i2c_read_data <= 8'b0;
    else if (i2c_state == state_non_ack || i2c_state == state_master_ack)
        i2c_read_data <= read_data_tmp;
end

assign i2c_read_done = (i2c_state == state_stop) ? 1'b1 : 1'b0;
assign i2c_read_data_rdy = (i2c_state == state_non_ack || i2c_state == state_master_ack) ? 1'b1 : 1'b0;

always @(posedge i2c_clk_src or negedge iRST_n) begin
    if (!iRST_n)
        read_length <= 8'b0;
    else if (i2c_state == state_start1)
        read_length <= iRead_length;
    else if (i2c_state == state_data1 && i2c_bit_cnt == 3'd1)
        read_length <= (read_length == 8'd0) ? 8'd0 : read_length - 1'b1;
end

always @(posedge iCLK or negedge iRST_n) begin
    if (!iRST_n)
        i2c_stop_ctrl_cnt <= 3'b0;
    else if (i2c_state == state_stop)
        i2c_stop_ctrl_cnt <= i2c_stop_ctrl_cnt + 1'b1;
    else
        i2c_stop_ctrl_cnt <= 3'b0;
end

assign oSYSTEM_STATE = (i2c_state == state_idle) ? 1'b0 : 1'b1;
assign oCONFIG_DONE = (i2c_state == state_stop) ? 1'b1 : 1'b0;
assign test_start = (test_cnt == 2'b11);

endmodule