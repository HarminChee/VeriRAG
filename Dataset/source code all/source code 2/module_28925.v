`define STATE_IDLE              2'b00
`define STATE_LEADVERIFY        2'b01
`define STATE_DATARCV           2'b10
`define STATE_IDLE              2'b00
`define STATE_LEADVERIFY        2'b01
`define STATE_DATARCV           2'b10
module ir_rcv (
    input clk27,
    input reset_n,
    input ir_rx,
    output reg [15:0] ir_code,
    output reg ir_code_ack,
    output reg [7:0] ir_code_cnt
);
parameter LEADCODE_LO_THOLD     = 200000;  
parameter LEADCODE_HI_THOLD     = 100000;  
parameter LEADCODE_HI_TIMEOUT   = 160000;  
parameter LEADCODE_HI_RPT_THOLD = 54000;   
parameter RPT_RELEASE_THOLD     = 3240000; 
parameter BIT_ONE_THOLD         = 27000;   
parameter BIT_DETECT_THOLD      = 7628;    
parameter IDLE_THOLD            = 141480;  
reg [1:0] state;            
reg [31:0] databuf;         
reg [5:0] bits_detected;    
reg [17:0] act_cnt;         
reg [17:0] leadvrf_cnt;     
reg [17:0] datarcv_cnt;     
reg [21:0] rpt_cnt;         
always @(posedge clk27 or negedge reset_n)
begin
    if (!reset_n)
        act_cnt <= 0;
    else
        begin
            if ((state == `STATE_IDLE) & (~ir_rx))
                act_cnt <= act_cnt + 1'b1;
            else
                act_cnt <= 0;
        end
end
always @(posedge clk27 or negedge reset_n)
begin
    if (!reset_n)
        leadvrf_cnt <= 0;
    else
        begin
            if ((state == `STATE_LEADVERIFY) & ir_rx)
                leadvrf_cnt <= leadvrf_cnt + 1'b1;
            else
                leadvrf_cnt <= 0;
        end
end
always @(posedge clk27 or negedge reset_n)
begin
    if (!reset_n)
        begin
            datarcv_cnt <= 0;
            bits_detected <= 0;
            databuf <= 0;
        end
    else
        begin
            if (state == `STATE_DATARCV)
                begin
                    if (ir_rx)
                        datarcv_cnt <= datarcv_cnt + 1'b1;
                    else
                        datarcv_cnt <= 0;
                    if (datarcv_cnt == BIT_DETECT_THOLD)
                        bits_detected <= bits_detected + 1'b1;
                    if (datarcv_cnt == BIT_ONE_THOLD)
                        databuf[32-bits_detected] <= 1'b1;
                end
            else
                begin
                    datarcv_cnt <= 0;
                    bits_detected <= 0;
                    databuf <= 0;
                end
        end
end
always @(posedge clk27 or negedge reset_n)
begin
    if (!reset_n)
        begin
            ir_code_ack <= 1'b0;
            ir_code <= 16'h00000000;
        end
    else
        begin
            if ((bits_detected == 32) & (databuf[31:24] == ~databuf[23:16]) & (databuf[15:8] == ~databuf[7:0]))
                begin
                    ir_code <= {databuf[31:24], databuf[15:8]};
                    ir_code_ack <= 1'b1;
                end
            else if (rpt_cnt >= RPT_RELEASE_THOLD)
                begin
                    ir_code <= 16'h00000000;
                    ir_code_ack <= 1'b0;
                end
            else
                ir_code_ack <= 1'b0;
        end
end
always @(posedge clk27 or negedge reset_n)
begin
    if (!reset_n)
        begin
            state <= `STATE_IDLE;
            rpt_cnt <= 0;
            ir_code_cnt <= 0;
        end
    else
        begin
            rpt_cnt <= rpt_cnt + 1'b1;
            case (state)
                `STATE_IDLE:
                    begin
                        if ((act_cnt >= LEADCODE_LO_THOLD) & ir_rx)
                            state <= `STATE_LEADVERIFY;
                        if (rpt_cnt >= RPT_RELEASE_THOLD)
                            ir_code_cnt <= 0;
                    end
                `STATE_LEADVERIFY:
                    begin
                        if (leadvrf_cnt == LEADCODE_HI_RPT_THOLD)
                            begin
                                if (ir_code != 0)
                                    ir_code_cnt <= ir_code_cnt + 1'b1;
                                rpt_cnt <= 0;
                            end
                        if (!ir_rx)
                            state <= (leadvrf_cnt >= LEADCODE_HI_THOLD) ? `STATE_DATARCV : `STATE_IDLE;
                        else if (leadvrf_cnt >= LEADCODE_HI_TIMEOUT)
                            state <= `STATE_IDLE;
                    end    
                `STATE_DATARCV:
                    begin
                        if (ir_code_ack == 1'b1)
                            ir_code_cnt <= 1;
                        if ((datarcv_cnt >= IDLE_THOLD)|bits_detected >= 33)
                            state <= `STATE_IDLE;
                    end
                default:
                    state <= `STATE_IDLE;
            endcase
        end
end
endmodule
