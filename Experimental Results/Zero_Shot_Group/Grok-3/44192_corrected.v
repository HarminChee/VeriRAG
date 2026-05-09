`timescale 1ns / 1ps
module can_controller
    (
    input wire GCLK,
    input wire RES,
    inout wire CAN,
    input wire [107:0] DIN,
    output reg [107:0] DOUT,
    input wire tx_start,
    output reg tx_ready = 1'b0,
    output reg rx_ready = 1'b0
    );
    wire tx;
    wire rx;
    wire cntmn;
    wire cntmn_ready;
    wire tsync;
    reg [107:0] DIN_BUF = 108'd0;
    reg timeslot_start  = 1'b0;         
    reg timeslot_finish = 1'b0;         
    reg have_arb = 1'b1;                
    reg tx_requested = 1'b0;            
    reg [127:0] can_state = "RECEIVING";  
    always @(posedge GCLK or posedge RES) begin
        if (RES) begin
            DIN_BUF <= 108'd0;
            tx_ready <= 1'b0;
            rx_ready <= 1'b0;
            tx_requested <= 1'b0;
            have_arb <= 1'b0;
            can_state <= "RECEIVING";
        end 
    end
    always @(posedge timeslot_start or posedge RES) begin
        if (RES) begin
            DIN_BUF <= 108'd0;
            tx_requested <= 1'b0;
            have_arb <= 1'b0;
            can_state <= "RECEIVING";
        end
        else if (tx_start) begin
            DIN_BUF <= DIN;
            tx_ready <= 1'b0;
            tx_requested <= 1'b1;
        end
        else if (!cntmn_ready) begin
            have_arb <= 1'b1; 
            can_state <= "TRANSMITTING";
        end
    end
    always @(posedge GCLK or posedge RES) begin
        if (RES) begin
            have_arb <= 1'b0; 
            can_state <= "RECEIVING"; 
        end
        else if (cntmn_ready & cntmn) begin
            have_arb <= 1'b0;
            can_state <= "RECEIVING";
        end
    end
    reg [63:0] bit_cnt = 64'd0;
    reg [107:0] rx_buf = 108'd0;
    always @(posedge tsync or posedge RES) begin
        if (RES) begin
            bit_cnt <= 64'd0;
            timeslot_start <= 1'b0;
            timeslot_finish <= 1'b0;
        end
        else begin
            if (bit_cnt == 64'd106) begin
                timeslot_finish <= 1'b1;
                timeslot_start <= 1'b0;
            end 
            else if (bit_cnt == 64'd107) begin
                timeslot_finish <= 1'b0;
                timeslot_start <= 1'b1;
            end
            else begin
                timeslot_start <= 1'b0;
                timeslot_finish <= 1'b0;
            end
            if (timeslot_finish) begin
                bit_cnt <= 64'd0;
            end 
            else begin
                bit_cnt <= bit_cnt + 64'd1;
            end
        end
    end
    assign tx = (have_arb & tx_requested) ? DIN_BUF[bit_cnt] : 1'b1;
    always @(posedge GCLK or posedge RES) begin
        if (RES) begin
            rx_buf <= 108'd0;
            DOUT <= 108'd0;
            rx_ready <= 1'b0;
            tx_ready <= 1'b0;
            tx_requested <= 1'b0;
        end
        else begin
            rx_buf[bit_cnt] <= rx;
            if (timeslot_finish & cntmn_ready & cntmn) begin
                rx_ready <= 1'b1;
                DOUT <= rx_buf;
            end
            else if (timeslot_finish & cntmn_ready & !cntmn) begin
                tx_ready <= 1'b1;
                tx_requested <= 1'b0;
            end
            else begin
                rx_ready <= 1'b0;
                tx_ready <= 1'b0;
            end
        end
    end
    can_qsampler CQS
    (
        .GCLK(GCLK),
        .RES(RES),  
        .CAN(CAN),  
        .din(tx),  
        .dout(rx),   
        .cntmn(cntmn),
        .cntmn_ready(cntmn_ready),
        .sync(tsync) 
    );
endmodule