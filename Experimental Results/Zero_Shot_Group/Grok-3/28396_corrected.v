<xaiArtifact artifact_id="d9d6839b-dbd8-4c15-ba35-3d47572c6fe5" artifact_version_id="7129cbd6-46b6-4840-be2a-ab1bf6dfb22e" title="steering_driver.v" contentType="text/verilog">
module steering_driver(
    input               rsi_MRST_reset,
    input               csi_MCLK_clk,
    input      [31:0]   avs_ctrl_writedata,
    output reg [31:0]   avs_ctrl_readdata,
    input      [3:0]    avs_ctrl_byteenable,
    input      [2:0]    avs_ctrl_address,
    input               avs_ctrl_write,
    input               avs_ctrl_read,
    output             avs_ctrl_waitrequest,
    input              rsi_PWMRST_reset,
    input              csi_PWMCLK_clk,     
    output             streeing    
);
    reg forward_back;
    reg on_off;
    reg [9:0] angle;
    reg [31:0] read_data;
    assign avs_ctrl_readdata = read_data;
    assign avs_ctrl_waitrequest = 1'b0;

    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
    begin
        if (rsi_MRST_reset) begin
            angle <= 10'b0;
            read_data <= 32'b0;
            forward_back <= 1'b0;
            on_off <= 1'b0;
        end
        else if (avs_ctrl_write) 
        begin
            case (avs_ctrl_address)
                3'd0: begin
                    if (avs_ctrl_byteenable[0]) on_off <= avs_ctrl_writedata[0];
                    if (avs_ctrl_byteenable[1]) forward_back <= avs_ctrl_writedata[8];
                end
                3'd1: begin
                    if (avs_ctrl_byteenable[1]) angle[9:8] <= avs_ctrl_writedata[9:8];
                    if (avs_ctrl_byteenable[0]) angle[7:0] <= avs_ctrl_writedata[7:0];
                end
                default: ;
            endcase
        end
        else if (avs_ctrl_read)
        begin
            case (avs_ctrl_address)
                3'd0: read_data <= {24'b0, forward_back, 7'b0, on_off};
                3'd1: read_data <= {22'b0, angle};
                default: read_data <= 32'hEA680003;
            endcase
        end
    end

    reg PWM_out;
    reg [31:0] counter;
    always @(posedge csi_PWMCLK_clk or posedge rsi_PWMRST_reset)
    begin
        if (rsi_PWMRST_reset) 
            counter <= 32'b0;
        else    
            counter <= counter + 32'd2048 * 32'd1073; 
    end

    reg [10:0] PWM; 
    always @(posedge counter[31] or posedge rsi_PWMRST_reset)
    begin
        if (rsi_PWMRST_reset) 
            PWM <= 11'b0;
        else    
            PWM <= PWM + 1;
    end

    always @(*)
    begin
        if (PWM < {1'b0, angle})
            PWM_out = 1'b1;
        else
            PWM_out = 1'b0;
    end

    assign streeing = PWM_out & on_off;
endmodule
</xaiArtifact>