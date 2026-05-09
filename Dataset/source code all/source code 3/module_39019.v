module qpi_flash(
    input wire clk,
    output reg ready = 0,
    input wire reset,
    input wire read,
    input wire [23:0] addr,
    output reg [7:0] data_out = 8'hFF,
    input wire passthrough,
    input wire passthrough_nCE,
    input wire passthrough_SCK,
    input wire passthrough_MOSI,
    output reg flash_nCE = 1,
    output reg flash_SCK = 0,
    inout wire flash_IO0,
    inout wire flash_IO1,
    inout wire flash_IO2,
    inout wire flash_IO3
);
reg [3:0] reset_state = 0;
`define RESET_START 0
`define RESET_DISABLE_CONT_READ 1
`define RESET_DISABLE_QPI 2
`define RESET_RESET_CHIP 3
`define RESET_WAIT_CHIP 4
`define RESET_ENTER_QPI 5
`define RESET_SET_DUMMY_CLOCKS 6
`define RESET_ENTER_CONT_READ 7
`define RESET_TEST_CONT_READ 8
`define RESET_SET_READY 9
`define RESET_DONE 10
reg [12:0] reset_delay_counter = 13'b0;
reg [39:0] shifter = 0;
reg [6:0] shift_count = 0;
reg last_passthrough = 0;
reg passthrough_active = 0;
reg spi_mode = 1'b0;    
reg qpi_mode = 1'b0;
reg qpi_output = 1'b0;  
reg [5:0] qpi_output_count = 0;  
`define TXN_IDLE 0
`define TXN_START 1
`define TXN_RUNNING 2
`define TXN_FINISH 3
`define TXN_DONE 4
reg [2:0] txn_state = `TXN_IDLE;
reg reading = 0;
reg [3:0] output_IO = 4'b0;
assign flash_IO0 = (spi_mode == 1'b1 || qpi_output == 1'b1) ? output_IO[0] : 1'bZ;
assign flash_IO1 = (qpi_output == 1'b1) ? output_IO[1] : 1'bZ;
assign flash_IO2 = (qpi_output == 1'b1) ? output_IO[2] : 1'bZ;
assign flash_IO3 = (qpi_output == 1'b1) ? output_IO[3] : 1'bZ;
always @(posedge clk) begin
    if (passthrough == 0 && read == 1) begin
        $display("Read triggered with addr %x", addr);
        qpi_output_count <= 6'd24 + 6'd8;  
        shifter <= {addr, 8'h20, 8'b0};
        shift_count <= 7'd24 + 7'd8 + 7'd8;  
        txn_state <= `TXN_START;
        reading <= 1;
        ready <= 0;
    end
    if (reading && txn_state == `TXN_DONE) begin
        reading <= 0;
        ready <= 1;
        data_out <= shifter[7:0];
    end
    if (passthrough == 1 && passthrough_active == 1) begin
        spi_mode <= 1'b1;
        qpi_mode <= 0;
        qpi_output <= 1'b0;
        flash_nCE <= passthrough_nCE;
        flash_SCK <= passthrough_SCK;
        output_IO[0] <= passthrough_MOSI;
    end
    last_passthrough <= passthrough;
    if (last_passthrough == 0 && passthrough == 1) begin
        reset_state <= `RESET_START;
    end
    if (last_passthrough == 1'b1 && passthrough == 1'b0) begin
        reset_state <= `RESET_START;
    end
    if (spi_mode == 1'b1) begin
        case (txn_state)
            `TXN_START : begin
                flash_nCE <= 1'b0;
                output_IO[0] = shifter[39];
                shifter <= {shifter[38:0], 1'b0};
                txn_state <= `TXN_RUNNING;
            end
            `TXN_RUNNING : begin
                if (shift_count == 0) begin
                    txn_state <= `TXN_FINISH;
                end else if (flash_SCK == 1'b0) begin
                    flash_SCK <= 1'b1;
                end else begin
                    flash_SCK <= 1'b0;
                    output_IO[0] = shifter[39];
                    shifter <= {shifter[38:0], flash_IO1};
                    shift_count <= shift_count - 7'd1;
                end
            end
            `TXN_FINISH : begin
                flash_nCE <= 1'b1;
                txn_state <= `TXN_DONE;
            end
        endcase
    end
    if (qpi_mode == 1'b1) begin
        case (txn_state)
            `TXN_START : begin
                flash_nCE <= 1'b0;
                output_IO <= shifter[39:36];
                shifter <= {shifter[35:0], 4'b0};
                qpi_output <= 1;
                txn_state <= `TXN_RUNNING;
            end
            `TXN_RUNNING : begin
                if (shift_count == 0) begin
                    txn_state <= `TXN_FINISH;
                end else if (flash_SCK == 1'b0) begin
                    flash_SCK <= 1'b1;
                end else begin
                    flash_SCK <= 1'b0;
                    output_IO <= shifter[39:36];
                    shifter <= {shifter[35:0], flash_IO3, flash_IO2, flash_IO1, flash_IO0};
                    shift_count <= shift_count - 7'd4;
                    if (qpi_output_count == 4) begin
                        qpi_output <= 0;
                    end else begin
                        qpi_output_count <= qpi_output_count - 6'd4;
                    end
                    if (qpi_output == 0 && shift_count == 7'd4) begin
                        data_out <= {shifter[3:0], flash_IO3, flash_IO2, flash_IO1, flash_IO0};
                    end
                end
            end
            `TXN_FINISH : begin
                flash_nCE <= 1'b1;
                qpi_output <= 1'b0;
                txn_state <= `TXN_DONE;
            end
        endcase
    end
    case (reset_state)
        `RESET_START : begin
            ready <= 1'b0;
            flash_nCE <= 1'b1;
            flash_SCK <= 1'b0;
            output_IO <= 4'b0;
            spi_mode <= 1'b1;
            qpi_mode <= 1'b0;
            qpi_output <= 1'b0;
            reading <= 0;
            passthrough_active <= 0;
            txn_state <= `TXN_IDLE;
            reset_state <= `RESET_DISABLE_CONT_READ;
        end
        `RESET_DISABLE_CONT_READ : begin
            case (txn_state)
                `TXN_IDLE : begin
                    $display("qpi_flash: Disabling continuous read");
                    shifter <= 40'hFF00000000;
                    shift_count <= 8;
                    txn_state <= `TXN_START;
                end
                `TXN_DONE : begin
                    txn_state <= `TXN_IDLE;
                    reset_state <= `RESET_DISABLE_QPI;
                end
            endcase
        end
        `RESET_DISABLE_QPI : begin
            case (txn_state)
                `TXN_IDLE : begin
                    $display("qpi_flash: Disabling QPI mode");
                    shifter <= 40'hFF00000000;
                    spi_mode <= 0;
                    qpi_mode <= 1;
                    qpi_output_count <= 8;
                    shift_count <= 8;
                    txn_state <= `TXN_START;
                end
                `TXN_DONE : begin
                    spi_mode <= 1;
                    qpi_mode <= 0;
                    txn_state <= `TXN_IDLE;
                    if (passthrough == 1) begin
                        passthrough_active <= 1;
                        reset_state <= `RESET_SET_READY;
                    end else begin
                        reset_state <= `RESET_ENTER_QPI;
                    end
                end
            endcase
        end
        `RESET_ENTER_QPI : begin
            case (txn_state)
                `TXN_IDLE : begin
                    $display("qpi_flash: Entering QPI mode");
                    shifter <= 40'h3800000000;
                    shift_count <= 8;
                    txn_state <= `TXN_START;
                end
                `TXN_DONE : begin
                    txn_state <= `TXN_IDLE;
                    reset_state <= `RESET_SET_DUMMY_CLOCKS;
                    spi_mode <= 0;
                    qpi_mode <= 1;
                end
            endcase
        end
        `RESET_SET_DUMMY_CLOCKS : begin
            case (txn_state)
                `TXN_IDLE : begin
                    $display("qpi_flash: Setting read params");
                    shifter <= 40'hC000000000;
                    shift_count <= 16;
                    qpi_output_count <= 20;  
                    txn_state <= `TXN_START;
                end
                `TXN_DONE : begin
                    txn_state <= `TXN_IDLE;
                    reset_state <= `RESET_ENTER_CONT_READ;
                end
            endcase
        end
        `RESET_ENTER_CONT_READ : begin
            case (txn_state)
                `TXN_IDLE : begin
                    $display("qpi_flash: Entering continuous read mode");
                    shifter <= 40'hEB00000320;  
                    shift_count <= 48;  
                    qpi_output_count <= 40;
                    txn_state <= `TXN_START;
                end
                `TXN_DONE : begin
                    txn_state <= `TXN_IDLE;
                    reset_state <= `RESET_TEST_CONT_READ;
                end
            endcase
        end
        `RESET_TEST_CONT_READ : begin
            case (txn_state)
                `TXN_IDLE : begin
                    $display("qpi_flash: Testing continuous read mode");
                    shifter <= 40'h0000072000;  
                    shift_count <= 40;  
                    qpi_output_count <= 32;
                    txn_state <= `TXN_START;
                end
                `TXN_DONE : begin
                    txn_state <= `TXN_IDLE;
                    reset_state <= `RESET_SET_READY;
                end
            endcase
        end
        `RESET_SET_READY : begin
            $display("qpi_flash: Reset done");
            ready <= 1;
            reset_state <= `RESET_DONE;
        end
        `RESET_DONE : begin
        end
        default : begin
        end
    endcase
    if (reset == 1'b1) begin
        reset_state <= `RESET_START;
    end
end
endmodule
