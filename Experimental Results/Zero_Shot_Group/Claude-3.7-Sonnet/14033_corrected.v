`timescale 1ns/1ps
module I2C_wr_subad(
    sda,scl,ack,rst_n,clk,WR,RD,data
    );
input  rst_n,WR,RD,clk;
output scl,ack;
inout [7:0] data;
inout  sda;

reg link_sda;
reg link_data;
reg[7:0] data_buf;
reg scl;
reg ack;
reg WF;
reg RF;
reg FF;
reg wr_state;
reg head_state;
reg[8:0] sh8out_state;
reg[9:0] sh8in_state;
reg stop_state;
reg[6:0] main_state;
reg[7:0] data_from_rm;
reg[7:0] cnt_read;
reg[7:0] cnt_write;

assign sda  = (link_sda)   ? data_buf[7] : 1'bz;
assign data = (link_data)  ? data_from_rm : 8'bz;

parameter page_write_num = 10'd34;
parameter page_read_num  = 10'd32;

parameter idle         = 7'b0000001;
parameter ready        = 7'b0000010;
parameter write_start  = 7'b0000100;
parameter addr_write   = 7'b0001000;
parameter data_read    = 7'b0010000;
parameter stop         = 7'b0100000;
parameter ackn         = 7'b1000000;

parameter bit7     = 9'b000000001;
parameter bit6     = 9'b000000010;
parameter bit5     = 9'b000000100;
parameter bit4     = 9'b000001000;
parameter bit3     = 9'b000010000;
parameter bit2     = 9'b000100000;
parameter bit1     = 9'b001000000;
parameter bit0     = 9'b010000000;
parameter bitend   = 9'b100000000;

parameter read_begin  = 10'b0000000001;
parameter read_bit7   = 10'b0000000010;
parameter read_bit6   = 10'b0000000100;
parameter read_bit5   = 10'b0000001000;
parameter read_bit4   = 10'b0000010000;
parameter read_bit3   = 10'b0000100000;
parameter read_bit2   = 10'b0001000000;
parameter read_bit1   = 10'b0010000000;
parameter read_bit0   = 10'b0100000000;
parameter read_end    = 10'b1000000000;

always @(negedge clk or negedge rst_n) begin
    if(!rst_n)
        scl <= 1'b0;
    else
        scl <= ~scl;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        link_sda    <= 1'b0;
        link_data   <= 1'b0;
        ack         <= 1'b0;
        RF          <= 1'b0;
        WF          <= 1'b0;
        FF          <= 1'b0;
        main_state  <= idle;
        head_state  <= 1'b0;
        sh8out_state<= bit7;
        sh8in_state <= read_begin;
        stop_state  <= 1'b0;
        cnt_read    <= 8'h01;
        cnt_write   <= 8'h01;
		wr_state    <= 1'b0;
    end else begin
        case(main_state)
            idle: begin
                link_data  <= 1'b0;
                link_sda   <= 1'b0;
                if(WR) begin
                    WF <= 1'b1;
                    main_state <= ready;
                end else if(RD) begin
                    RF <= 1'b1;
                    main_state <= ready;
                end else begin
                    WF <= 1'b0;
                    RF <= 1'b0;
                    main_state <= idle;
                end
            end
            ready: begin
                FF         <= 1'b0;
                main_state <= write_start;
            end
            write_start: begin
                if(FF == 1'b0)
                    shift_head;
                else begin
                    if(WF == 1'b1)
                        data_buf <= 8'b11111100;
                    else
                        data_buf <= 8'b11111101;
                    FF              <= 1'b0;
                    sh8out_state    <= bit7;
                    main_state      <= addr_write;
                end
            end
            addr_write: begin
                if(FF == 1'b0)
                    shift8_out;
                else begin
                    if(RF == 1'b1) begin
                        data_buf   <= 8'h00;
                        link_sda  <= 1'b0;
                        FF          <= 1'b0;
                        cnt_read <= 8'h01;
                        main_state  <= data_read;
                    end else if(WF == 1'b1) begin
                        FF             <= 1'b0;
                        main_state     <= data_read;
                        data_buf       <= data;
                        cnt_write      <= 8'h01;
                    end
                end
            end
            data_read: begin
                if(RF == 1'b1) begin
                    if(cnt_read <= page_read_num)
                        shift8_in;
                    else begin
                        main_state <= stop;
                        FF         <= 1'b0;
                    end
                end else if(WF == 1'b1) begin
                    if(cnt_write <= page_write_num) begin
                        case(wr_state)
                            1'b0: begin
                                if(!scl) begin
                                    data_buf  <= data;
                                    link_sda  <= 1'b1;
                                    sh8out_state<=bit7;
                                    wr_state    <= 1'b1;
                                    ack         <= 1'b0;
                                end else
                                    wr_state    <= 1'b0;
                            end
                            1'b1: shift8_out;
                            default: wr_state <= 1'b0;
                        endcase
                    end else begin
                        main_state  <= stop;
                        wr_state    <= 1'b0;
                        FF          <= 1'b0;
                    end
                end
            end
            stop: begin
                if(FF == 1'b0)
                    task_stop;
                else begin
                    ack <= 1'b1;
                    FF  <= 1'b0;
                    main_state <= ackn;
                end
            end
            ackn: begin
                ack <= 1'b0;
                WF  <= 1'b0;
                RF  <= 1'b0;
                main_state <= idle;
            end
            default: main_state <= idle;
        endcase
    end
end

task shift_head;
    begin
        case(head_state)
            1'b0: begin
                if(!scl) begin
                    link_sda      <= 1'b1;
                    data_buf[7]   <= 1'b1;
                    head_state    <= 1'b1;
                end else
                    head_state <= 1'b0;
            end
            1'b1: begin
                if(scl) begin
                    FF            <= 1'b1;
                    data_buf[7]   <= 1'b0;
                    head_state    <= 1'b0;
                end else
                    head_state <= 1'b1;
            end
        endcase
    end
endtask

task shift8_out;
    begin
        case(sh8out_state)
            bit7: begin
                if(!scl) begin
                    link_sda     <= 1'b1;
                    sh8out_state <= bit6;
                end else
                    sh8out_state <= bit7;
            end
            bit6: begin
                if(!scl) begin
                    sh8out_state <= bit5;
                    data_buf <= {data_buf[6:0], 1'b0};
                end else
                    sh8out_state <= bit6;
            end
            bit5: begin
                if(!scl) begin
                    sh8out_state <= bit4;
                    data_buf <= {data_buf[6:0], 1'b0};
                end else
                    sh8out_state <= bit5;
            end
            bit4: begin
                if(!scl) begin
                    sh8out_state <= bit3;
                    data_buf <= {data_buf[6:0], 1'b0};
                end else
                    sh8out_state <= bit4;
            end
            bit3: begin
                if(!scl) begin
                    sh8out_state <= bit2;
                    data_buf <= {data_buf[6:0], 1'b0};
                end else
                    sh8out_state <= bit3;
            end
            bit2: begin
                if(!scl) begin
                    sh8out_state <= bit1;
                    data_buf <= {data_buf[6:0], 1'b0};
                end else
                    sh8out_state <= bit2;
            end
            bit1: begin
                if(!scl) begin
                    sh8out_state <= bit0;
                    data_buf <= {data_buf[6:0], 1'b0};
                end else
                    sh8out_state <= bit1;
            end
            bit0: begin
                if(!scl) begin
                    sh8out_state <= bitend;
                    data_buf <= {data_buf[6:0], 1'b0};
                end else
                    sh8out_state <= bit0;
            end
            bitend: begin
                if(!scl && (wr_state == 1'b1)) begin
                    link_sda       <= 1'b0;
                    sh8out_state   <= bit7;
                    wr_state             <= 1'b0;
                    FF             <= 1'b1;
                    cnt_write      <= cnt_write + 1;
                    ack            <= 1'b1;
                end else if(!scl) begin
                    link_sda       <= 1'b0;
                    sh8out_state   <= bit7;
                    wr_state             <= 1'b0;
                    FF             <= 1'b1;
                    cnt_write      <= cnt_write + 1;
                end else;
            end
			default: sh8out_state <= bit7;
        endcase
    end
endtask

task shift8_in;
    begin
        case(sh8in_state)
            read_begin: begin
                sh8in_state <= read_bit7;
                link_data   <= 1'b1;
                ack         <= 1'b0;
            end
            read_bit7: begin
                if(scl) begin
                    data_from_rm[7] <= sda;
                    sh8in_state     <= read_bit6;
                end else begin
                    link_sda    <= 1'b0;
                    sh8in_state <= read_bit7;
                end
            end
            read_bit6: begin
                if(scl) begin
                    data_from_rm[6] <= sda;
                    sh8in_state     <= read_bit5;
                end else
                    sh8in_state <= read_bit6;
            end
            read_bit5: begin
                if(scl) begin
                    data_from_rm[5] <= sda;
                    sh8in_state     <= read_bit4;
                end else
                    sh8in_state <= read_bit5;
            end
            read_bit4: begin
                if(scl) begin
                    data_from_rm[4] <= sda;
                    sh8in_state     <= read_bit3;
                end else
                    sh8in_state <= read_bit4;
            end
            read_bit3: begin
                if(scl) begin
                    data_from_rm[3] <= sda;
                    sh8in_state     <= read_bit2;
                end else
                    sh8in_state <= read_bit3;
            end
            read_bit2: begin
                if(scl) begin
                    data_from_rm[2] <= sda;
                    sh8in_state     <= read_bit1;
                end else
                    sh8in_state <= read_bit2;
            end
            read_bit1: begin
                if(scl) begin
                    data_from_rm[1] <= sda;
                    sh8in_state     <= read_bit0;
                end else
                    sh8in_state <= read_bit1;
            end
            read_bit0: begin
                if(scl) begin
                    data_from_rm[0] <= sda;
                    sh8in_state     <= read_end;
                end else
                    sh8in_state <= read_bit0;
            end
            read_end: begin
                if(cnt_read == page_read_num) begin
                    link_data       <= 1'b0;
                    link_sda        <= 1'b1;
                    sh8in_state     <= read_begin;
                    FF              <= 1'b1;
                    data_buf[7]     <= 1'b1;
                    cnt_read        <= cnt_read + 1;
                    ack             <= 1'b1;
                end else begin
                    link_data       <= 1'b0;
                    link_sda        <= 1'b1;
                    sh8in_state     <= read_begin;
                    FF              <= 1'b1;
                    data_buf[7]     <= 1'b0;
                    cnt_read        <= cnt_read + 1;
                    ack             <= 1'b1;
                end
            end
            default: begin
                sh8in_state    <= read_begin;
            end
        endcase
    end
endtask

task task_stop;
    begin
        case(stop_state)
            1'b0: begin
                if(!scl) begin
                    link_sda <= 1'b1;
                    stop_state <= 1'b1;
                    data_buf[7] <= 1'b0;
                end else
                    stop_state  <= 1'b0;
            end
            1'b1: begin
                if(scl) begin
                    data_buf[7] <= 1'b1;
                    FF          <= 1'b1;
                    stop_state  <= 1'b0;
                end else
                    stop_state  <= 1'b1;
            end
        endcase
    end
endtask

endmodule