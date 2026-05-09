`timescale 1ns / 1ps
`timescale 1ns / 1ps
module DATA(
    input wire CLK,
    input wire RESET_L,
    input wire writeRead_Regs_DATA,
    input wire [3:0] blockCount_Regs_DATA,
    input wire multipleData_Regs_DATA,
    input wire timeout_Enable_Regs_DATA, 
    input wire [15:0] timeout_Reg_Regs_DATA, 
    input wire new_DAT_DMA_DATA,
    input wire serial_Ready_Phy_DATA, 
    input wire timeout_Phy_DATA, 
    input wire complete_Phy_DATA, 
    input wire ack_IN_Phy_DATA, 
    input wire fifo_OK_FIFO_DATA,
    output reg transfer_complete_DATA_DMA,
    output reg strobe_OUT_DATA_Phy,
    output reg ack_OUT_DATA_Phy,
    output reg [3:0] blocks_DATA_Phy,
    output reg [15:0] timeout_value_DATA_Phy,
    output reg writeReadPhysical_DATA_Phy,
    output reg multiple_DATA_Phy,
    output reg idle_out_DATA_Phy
);
parameter RESET                  = 6'b000001;
parameter IDLE                   = 6'b000010; 
parameter SETTING_OUTPUTS        = 6'b000100;
parameter CHECK_FIFO             = 6'b001000;
parameter TRANSMIT               = 6'b010000;
parameter ACK                    = 6'b100000;
reg STATE;
reg NEXT_STATE;
always @ (posedge CLK)
begin
    if (!RESET_L) 
        begin
        STATE <= RESET;
        end
    else
        begin
            STATE <= NEXT_STATE;
        end
end
always @ (*)
begin
    case (STATE)
        RESET:
            begin
            transfer_complete_DATA_DMA = 0;
            strobe_OUT_DATA_Phy        = 0;
            ack_OUT_DATA_Phy           = 0;
            blocks_DATA_Phy            = 4'b0000;
            timeout_value_DATA_Phy     = 0;
            writeReadPhysical_DATA_Phy = 0;
            multiple_DATA_Phy          = 0;
            idle_out_DATA_Phy          = 0;
            NEXT_STATE = IDLE;
            end
        IDLE:
            begin
            idle_out_DATA_Phy = 1;
            if (new_DAT_DMA_DATA)
                begin
                    NEXT_STATE = SETTING_OUTPUTS;
                end
            else
                begin
                    NEXT_STATE = IDLE;
                end 
            end
        SETTING_OUTPUTS:
            begin
            blocks_DATA_Phy = blockCount_Regs_DATA;
            timeout_value_DATA_Phy = timeout_Reg_Regs_DATA;
            writeReadPhysical_DATA_Phy = writeRead_Regs_DATA;
            multiple_DATA_Phy = multipleData_Regs_DATA;
            if (serial_Ready_Phy_DATA)
                begin
                    NEXT_STATE = CHECK_FIFO;
                end
            else
                begin
                    NEXT_STATE = SETTING_OUTPUTS;
                end
            end
        CHECK_FIFO:
            begin
            blocks_DATA_Phy = blockCount_Regs_DATA;
            timeout_value_DATA_Phy = timeout_Reg_Regs_DATA;
            writeReadPhysical_DATA_Phy = writeRead_Regs_DATA;
            multiple_DATA_Phy = multipleData_Regs_DATA;
            if (fifo_OK_FIFO_DATA)
                begin
                    NEXT_STATE = TRANSMIT;
                end
            else
                begin
                    NEXT_STATE = CHECK_FIFO;
                end
            end
        TRANSMIT:
            begin
            strobe_OUT_DATA_Phy = 1;
            if (complete_Phy_DATA)
                begin
                    NEXT_STATE = ACK;
                end
            else
                begin
                    NEXT_STATE = TRANSMIT;
                end
            end
        ACK:
            begin
            ack_OUT_DATA_Phy = 1;
            if (ack_IN_Phy_DATA)
                begin
                    NEXT_STATE = IDLE;
                end
            else
                begin
                    NEXT_STATE = ACK;
                end
            end 
        default:
            begin
            NEXT_STATE = RESET;
            end 
    endcase
end 
endmodule 
