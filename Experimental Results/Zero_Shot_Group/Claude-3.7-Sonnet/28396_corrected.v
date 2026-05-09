module steering_driver(
    input                   rsi_MRST_reset,
    input                   csi_MCLK_clk,
    input   [31:0]  avs_ctrl_writedata,
    output  [31:0]  avs_ctrl_readdata,
    input   [3:0]       avs_ctrl_byteenable,
    input   [2:0]       avs_ctrl_address,
    input                   avs_ctrl_write,
    input                   avs_ctrl_read,
    output                  avs_ctrl_waitrequest,
    input                   rsi_PWMRST_reset,
    input                   csi_PWMCLK_clk,
    output                  streeing
    );

    reg forward_back;
    reg on_off;
    reg [9:0] angle;
    reg [31:0] read_data;
    reg PWM_out;
    reg[31:0] counter;
    reg [10:0] PWM;

    assign  avs_ctrl_readdata = read_data;
    assign  avs_ctrl_waitrequest = 0; // Assuming no waitrequest

    always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
    begin
        if(rsi_MRST_reset) begin
            read_data <= 0;
        end
        else if(avs_ctrl_write) 
        begin
            case(avs_ctrl_address)
                2'b01: begin // Corrected address
                    if(avs_ctrl_byteenable[1]) angle[9:8] <= avs_ctrl_writedata[9:8];
                    if(avs_ctrl_byteenable[0]) angle[7:0] <= avs_ctrl_writedata[7:0];
                end
                default:;
            endcase
       end
        else if (avs_ctrl_read) begin
            case(avs_ctrl_address)
                2'b00: read_data <= 32'hEA680003;
                2'b01: read_data <= angle;
                default: read_data <= 32'b0;
            endcase
        end
    end


    always @(posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
    begin
        if (rsi_PWMRST_reset) 
            counter <= 32'b0;
        else    
            counter <= counter + 32'd2048; // Corrected counter increment
    end


    always @(posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset) //Using clock edge instead of MSB toggle
    begin
        if (rsi_PWMRST_reset) 
            PWM <= 11'b0;
        else if (counter[31])
            PWM <= PWM + 1;
    end

    always @(posedge csi_PWMCLK_clk) //Using clock edge
    begin
        if(PWM < angle)
            PWM_out<= 1;
        else
            PWM_out<= 0;
    end
   assign streeing = PWM_out;
endmodule