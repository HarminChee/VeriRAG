module DATA_PHYSICAL(
    input wire SD_CLK,
    input wire RESET_L,
    input wire strobe_IN_DATA_Phy,
    input wire ack_IN_DATA_Phy,
    input wire [15:0] timeout_Reg_DATA_Phy,
    input wire [3:0] blocks_DATA_Phy,
    input wire writeRead_DATA_Phy,
    input wire multiple_DATA_Phy,
    input wire idle_in_DATA_Phy,
    input wire transmission_complete_PS_Phy,
    input wire reception_complete_SP_Phy,
    input wire [31:0] data_read_SP_Phy,
    input wire [31:0] dataFromFIFO_FIFO_Phy,
    output reg serial_Ready_Phy_DATA,
    output reg complete_Phy_DATA,
    output reg ack_OUT_Phy_DATA,
    output reg data_timeout_Phy_DATA,
    output reg reset_Wrapper_Phy_PS,
    output reg enable_pts_Wrapper_Phy_PS,
    output reg enable_stp_Wrapper_Phy_SP,
    output reg [31:0] dataParallel_Phy_PS,
    output reg pad_state_Phy_PAD,
    output reg pad_enable_Phy_PAD,
    output reg writeFIFO_enable_Phy_FIFO,
    output reg readFIFO_enable_Phy_FIFO,
    output reg [31:0] dataReadToFIFO_Phy_FIFO,
    output reg IO_enable_Phy_SD_CARD
);
parameter RESET                  = 11'b00000000001;
parameter IDLE                   = 11'b00000000010;
parameter FIFO_READ              = 11'b00000000100;
parameter LOAD_WRITE             = 11'b00000001000;
parameter SEND                   = 11'b00000010000;
parameter WAIT_RESPONSE          = 11'b00000100000;
parameter READ                   = 11'b00001000000;
parameter READ_FIFO_WRITE        = 11'b00010000000;
parameter READ_WRAPPER_RESET     = 11'b00100000000;
parameter WAIT_ACK               = 11'b01000000000;
parameter SEND_ACK               = 11'b10000000000;
reg [15:0] timeout_input;
reg [3:0] blocks;
reg STATE;
reg NEXT_STATE;
always @ (posedge SD_CLK)
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
            serial_Ready_Phy_DATA       = 0;
            complete_Phy_DATA           = 0;
            ack_OUT_Phy_DATA            = 0;
            data_timeout_Phy_DATA       = 0;
            reset_Wrapper_Phy_PS        = 1;                 
            enable_pts_Wrapper_Phy_PS   = 0;
            enable_stp_Wrapper_Phy_SP   = 0;
            dataParallel_Phy_PS         = 32'b0;
            pad_state_Phy_PAD           = 0;
            pad_enable_Phy_PAD          = 0;
            writeFIFO_enable_Phy_FIFO   = 0;
            readFIFO_enable_Phy_FIFO    = 0;
            dataReadToFIFO_Phy_FIFO     = 32'b0;
            IO_enable_Phy_SD_CARD        = 0;                
            NEXT_STATE = IDLE;
            end
        IDLE:
            begin
            serial_Ready_Phy_DATA = 1;
            blocks = 4'b0;
            timeout_input = 16'b0;
            if (strobe_IN_DATA_Phy && writeRead_DATA_Phy)
                begin
                    NEXT_STATE = FIFO_READ;
                end
            else
                begin
                    NEXT_STATE = READ;
                end
            end
        FIFO_READ:
            begin
            writeFIFO_enable_Phy_FIFO = 1;
            dataParallel_Phy_PS = dataFromFIFO_FIFO_Phy;
            NEXT_STATE = LOAD_WRITE;
            end
        LOAD_WRITE:
            begin
            enable_pts_Wrapper_Phy_PS = 1;
            IO_enable_Phy_SD_CARD = 0;
            pad_state_Phy_PAD = 1;
            pad_enable_Phy_PAD = 1;
            NEXT_STATE = SEND;
            end
        SEND:
            begin
            IO_enable_Phy_SD_CARD = 1;
            NEXT_STATE = WAIT_RESPONSE;
            end
        WAIT_RESPONSE:
            begin
            enable_pts_Wrapper_Phy_PS = 0;
            enable_stp_Wrapper_Phy_SP = 1;
            pad_state_Phy_PAD = 0;
            timeout_input = timeout_input + 1;
            if (timeout_input == timeout_Reg_DATA_Phy)
                begin
                    data_timeout_Phy_DATA = 1;
                end
            else
                begin
                    data_timeout_Phy_DATA = 0;
                end
            if (reception_complete_SP_Phy)
                begin
                    blocks = blocks + 1;
                    if (!multiple_DATA_Phy || (blocks==blocks_DATA_Phy))
                        begin
                            NEXT_STATE = WAIT_ACK;
                        end
                    else
                        begin
                            NEXT_STATE = FIFO_READ;
                        end
                end
            else
                begin
                    NEXT_STATE = WAIT_RESPONSE;
                end
            end
        READ:
            begin
            pad_enable_Phy_PAD = 1;
            pad_state_Phy_PAD = 0;
            enable_stp_Wrapper_Phy_SP = 1;
            timeout_input = timeout_input + 1;
            if (timeout_input == timeout_Reg_DATA_Phy)
                begin
                    data_timeout_Phy_DATA = 1;
                end
            else
                begin
                    data_timeout_Phy_DATA = 0;
                end
            if (reception_complete_SP_Phy)
                begin
                    blocks = blocks + 1;
                    NEXT_STATE = READ_FIFO_WRITE;
                end
            else
                begin
                    NEXT_STATE = READ;
                end
            end
        READ_FIFO_WRITE:
            begin
            readFIFO_enable_Phy_FIFO = 1;
            dataReadToFIFO_Phy_FIFO = data_read_SP_Phy;
            enable_stp_Wrapper_Phy_SP = 0;
            if ((blocks == blocks_DATA_Phy) || !multiple_DATA_Phy)
                begin
                    NEXT_STATE = WAIT_ACK;
                end
            else
                begin
                    NEXT_STATE = READ_WRAPPER_RESET;
                end
            end
        READ_WRAPPER_RESET:
            begin
            reset_Wrapper_Phy_PS = 1;
            NEXT_STATE = READ;
            end
        WAIT_ACK:
            begin
            complete_Phy_DATA = 1;
            if (ack_IN_DATA_Phy)
                begin
                    NEXT_STATE = SEND_ACK;
                end
            else
                begin
                    NEXT_STATE = WAIT_ACK;
                end
            end
        SEND_ACK:
            begin
                ack_OUT_Phy_DATA = 1;
                NEXT_STATE = IDLE;
            end
        default:
            begin
            NEXT_STATE = IDLE;  
            end
    endcase
end 
endmodule 
