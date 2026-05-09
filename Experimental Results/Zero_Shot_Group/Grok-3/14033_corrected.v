`timescale 1ns/1ps
module I2C_wr_subad(
    sda, scl, ack, rst_n, clk, WR, RD, data
);
    input  rst_n, WR, RD, clk;
    output scl, ack;
    inout [7:0] data; 
    inout  sda;
    
    reg link_sda, link_data;
    reg [7:0] data_buf;
    reg scl, ack, WF, RF, FF;
    reg wr_state;
    reg head_state;
    reg [8:0] sh8out_state;
    reg [9:0] sh8in_state;
    reg stop_state;
    reg [6:0] main_state;
    reg [7:0] data_from_rm;
    reg [7:0] cnt_read;
    reg [7:0] cnt_write;
    
    assign sda  = (link_sda)   ? data_buf[7] : 1'bz;
    assign data = (link_data)  ? data_from_rm : 8'hzz;
    
    parameter page_write_num = 10'd34,
              page_read_num  = 10'd32;
              
    parameter
        idle         = 7'b000_0001,
        ready        = 7'b000_0010,
        write_start  = 7'b000_0100,
        addr_write   = 7'b000_1000,
        data_read    = 7'b001_0000,
        stop         = 7'b010_0000,
        ackn         = 7'b100_0000;
        
    parameter
        bit7     = 9'b0_0000_0001,
        bit6     = 9'b0_0000_0010,
        bit5     = 9'b0_0000_0100,
        bit4     = 9'b0_0000_1000,
        bit3     = 9'b0_0001_0000,
        bit2     = 9'b0_0010_0000,
        bit1     = 9'b0_0100_0000,
        bit0     = 9'b0_1000_0000,
        bitend   = 9'b1_0000_0000;
        
    parameter 
        read_begin  = 10'b00_0000_0001,
        read_bit7   = 10'b00_0000_0010,
        read_bit6   = 10'b00_0000_0100,
        read_bit5   = 10'b00_0000_1000,
        read_bit4   = 10'b00_0001_0000,
        read_bit3   = 10'b00_0010_0000,
        read_bit2   = 10'b00_0100_0000,
        read_bit1   = 10'b00_1000_0000,
        read_bit0   = 10'b01_0000_0000,
        read_end    = 10'b10_0000_0000;     
        
    always @(negedge clk or negedge rst_n) begin
        if(!rst_n)
            scl <= 1'b0;
        else
            scl <= ~scl;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            link_sda    <= 1'b0;
            ack         <= 1'b0;
            RF          <= 1'b0;
            WF          <= 1'b0;
            FF          <= 1'b0;
            main_state  <= idle;
            head_state  <= 1'b0;
            sh8out_state<= bit7;
            sh8in_state <= read_begin;
            stop_state  <= 1'b0;
            cnt_read    <= 8'h1;
            cnt_write   <= 8'h1;
            link_data   <= 1'b0;
            data_buf    <= 8'h00;
        end
        else begin
            case(main_state)
                idle: begin
                    link_data  <= 1'b0;
                    link_sda   <= 1'b0;
                    if(WR) begin
                        WF <= 1'b1;
                        main_state <= ready;
                    end
                    else if(RD) begin
                        RF <= 1'b1;
                        main_state <= ready;
                    end
                    else begin
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
                            data_buf <= {1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0};
                        else
                            data_buf <= {1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b1};
                        FF           <= 1'b0;
                        sh8out_state <= bit6;
                        main_state   <= addr_write;
                    end
                end
                addr_write: begin
                    if(FF == 1'b0)
                        shift8_out;
                    else begin
                        if(RF == 1'b1) begin
                            data_buf    <= 8'h00;
                            link_sda    <= 1'b0;
                            FF          <= 1'b0;
                            cnt_read    <= 8'h1;
                            main_state  <= data_read;
                        end
                        else if(WF == 1'b1) begin
                            FF          <= 1'b0;
                            main_state  <= data_read;
                            data_buf    <= data;
                            cnt_write   <= 8'h1;
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
                    end
                    else if(WF == 1'b1) begin
                        if(cnt_write <= page_write_num) begin
                            case(wr_state)
                                1'b0: begin
                                    if(!scl) begin
                                        data_buf     <= data;
                                        link_sda     <= 1'b1;
                                        sh8out_state <= bit6;
                                        wr_state     <= 1'b1;
                                        ack          <= 1'b0;
                                    end
                                    else
                                        wr_state <= 1'b0;
                                end
                                1'b1: shift8_out;
                            endcase
                        end
                        else begin
                            main_state <= stop;
                            wr_state   <= 1'b0;
                            FF         <= 1'b0;
                        end
                    end
                end
                stop: begin
                    if(FF == 1'b0)
                        task_stop;
                    else begin
                        ack        <= 1'b1;
                        FF         <= 1'b0;
                        main_state <= ackn;
                    end
                end
                ackn: begin
                    ack        <= 1'b0;
                    WF         <= 1'b0;
                    RF         <= 1'b0;
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
                    link_sda    <= 1'b1;
                    data_buf[7] <= 1'b1;
                    head_state  <= 1'b1;
                end
                else
                    head_state <= 1'b0;
            end
            1'b1: begin
                if(scl) begin
                    FF          <= 1'b1;
                    data_buf[7] <= 1'b0;
                    head_state  <= 1'b0;
                end
                else
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
                end
                else
                    sh8out_state <= bit7;
            end
            bit6: begin
                if(!scl) begin
                    sh8out_state <= bit5;
                    data_buf     <= {data_buf[6:0], 1'b0};
                end
                else
                    sh8out_state <= bit6;
            end
            bit5: begin
                if(!scl) begin
                    sh8out_state <= bit4;
                    data_buf     <= {data_buf[6:0], 1'b0};
                end
                else
                    sh8out_state <= bit5;
            end
            bit4: begin
                if(!scl) begin
                    sh8out_state <= bit3;
                    data_buf     <= {data_buf[6:0], 1'b0};
                end
                else
                    sh8out_state <= bit4;
            end
            bit3: begin
                if(!scl) begin
                    sh8out_state <= bit2;
                    data_buf     <= {data_buf[6:0], 1'b0};
                end
                else
                    sh8out_state <= bit3;
            end
            bit2: begin
                if(!scl) begin
                    sh8out_state <= bit1;
                    data_buf     <= {data_buf[6:0], 1'b0};
                end
                else
                    sh8out_state <= bit2;
            end
            bit1: begin
                if(!scl) begin
                    sh8out_state <= bit0;
                    data_buf     <= {data_buf[6:0], 1'b0};
                end
                else
                    sh8out_state <= bit1;
            end
            bit0: begin
                if(!scl) begin
                    sh8out_state <= bitend;
                    data_buf     <= {data_buf[6:0], 1'b0};
                end
                else
                    sh8out_state <= bit0;
            end
            bitend: begin
                if(scl == 1'b0) begin
                    link_sda     <= 1'b0;
                    sh8out_state <= bit7;
                    wr_state     <= 1'b0;
                    FF           <= 1'b1;
                    cnt_write    <= cnt_write + 1'b1;
                    ack          <= 1'b1;
                end
            end
        endcase
    end
    endtask
    
    task shift8_in;
    begin
        case(sh8in_state)
            read_begin: begin
                sh8in_state <= read_bit7;
                link_data   <= 1'b0;
                ack         <= 1'b0;
            end
            read_bit7: begin
                if(scl) begin
                    data_from_rm[7] <= sda;
                    sh8in_state     <= read_bit6;
                end
                else begin
                    link_sda    <= 1'b0;
                    sh8in_state <= read_bit7;
                end
            end
            read_bit6: begin
                if(scl) begin
                    data_from_rm[6] <= sda;
                    sh8in_state     <= read_bit5;
                end
                else
                    sh8in_state <= read_bit6;
            end
            read_bit5: begin
                if(scl) begin
                    data_from_rm[5] <= sda;
                    sh8in_state     <= read_bit4;
                end
                else
                    sh8in_state <= read_bit5;
            end
            read_bit4: begin
                if(scl) begin
                    data_from_rm[4] <= sda;
                    sh8in_state     <= read_bit3;
                end
                else
                    sh8in_state <= read_bit4;
            end
            read_bit3: begin
                if(scl) begin
                    data_from_rm[3] <= sda;
                    sh8in_state     <= read_bit2;
                end
                else
                    sh8in_state <= read_bit3;
            end
            read_bit2: begin
                if(scl) begin
                    data_from_rm[2] <= sda;
                    sh8in_state     <= read_bit1;
                end
                else
                    sh8in_state <= read_bit2;
            end
            read_bit1: begin
                if(scl) begin
                    data_from_rm[1] <= sda;
                    sh8in_state     <= read_bit0;
                end
                else
                    sh8in_state <= read_bit1;
            end
            read_bit0: begin
                if(scl) begin
                    data_from_rm[0] <= sda;
                    sh8in_state     <= read_end;
                end
                else
                    sh8in_state <= read_bit0;
            end
            read_end: begin
                if(!scl) begin
                    if(cnt_read == page_read_num) begin
                        link_data   <= 1'b1;
                        link_sda    <= 1'b1;
                        sh8in_state <= read_begin;
                        FF          <= 1'b1;
                        data_buf[7] <= 1'b1;
                        cnt_read    <= cnt_read + 1'b1;
                        ack         <= 1'b1;
                    end
                    else begin
                        link_data   <= 1'b1;
                        link_sda    <= 1'b1;
                        sh8in_state <= read_begin;
                        FF          <= 1'b1;
                        data_buf[7] <= 1'b0;
                        cnt_read    <= cnt_read + 1'b1;
                        ack         <= 1'b1;
                    end
                end
            end
        endcase
    end
    endtask
    
    task task_stop;
    begin
        case(stop_state)
            1'b0: begin
                if(!scl) begin
                    link_sda    <= 1'b1;
                    stop_state  <= 1'b1;
                    data_buf[7] <= 1'b0;
                end
                else
                    stop_state <= 1'b0;
            end
            1'b1: begin
                if(scl) begin
                    data_buf[7] <= 1'b1;
                    FF          <= 1'b1;
                    stop_state  <= 1'b0;
                end
                else
                    stop_state <= 1'b1;
            end
        endcase
    end 
    endtask
    
endmodule