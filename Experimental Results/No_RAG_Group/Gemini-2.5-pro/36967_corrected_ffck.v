module sht1x_sensor_corrected_ffc (
    input               rsi_MRST_reset,
    input               csi_MCLK_clk,
    input   [31:0]      avs_ctrl_writedata,
    output  [31:0]      avs_ctrl_readdata,
    input   [3:0]       avs_ctrl_byteenable,
    input   [2:0]       avs_ctrl_address,
    input               avs_ctrl_write,
    input               avs_ctrl_read,
    output              avs_ctrl_waitrequest, // Note: This output is not assigned in the original or corrected code.
    output              sck,
    output              dir,
    inout               sda
);

    reg      [31:0] read_data;
    reg      [31:0] write_data;
    reg      [15:0] temperature;
    reg      [15:0] moisture;
    wire              data_ready; // Note: This wire is declared but not driven.

    // AVS Read/Write Logic (Clocked by primary clock)
    assign avs_ctrl_readdata = read_data;
    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset) begin
        if (rsi_MRST_reset) begin
            read_data <= 32'd0;
            write_data <= 32'd0; // Added reset for write_data
        end else begin
            if (avs_ctrl_write) begin
                // Assuming byte enables are handled elsewhere or full write intended
                case (avs_ctrl_address)
                    3'd0: write_data <= avs_ctrl_writedata;
                    default: ; // write_data holds its value
                endcase
                read_data <= read_data; // Hold read data during write
            end else if (avs_ctrl_read) begin // Changed else if condition for clarity
                case (avs_ctrl_address)
                    3'd0: read_data <= 32'd0; // Example read value
                    3'd1: read_data <= 32'hEA680003; // Example read value
                    3'd2: read_data <= {16'd0, temperature};
                    3'd3: read_data <= {16'd0, moisture};
                    3'd4: read_data <= {31'd0, data_ready}; // data_ready is undriven
                    default: read_data <= 32'd0;
                endcase
                write_data <= write_data; // Hold write data during read
            end
            // else: If neither read nor write, registers hold values.
        end
    end

    // Internal clock generation logic (kept for enable signal generation)
    wire sck_t;
    reg [31:0] temp;
    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset) begin // Added reset
        if (rsi_MRST_reset) begin
            temp <= 32'd0;
        end else begin
            temp <= temp + 32'd64585974 / 4 / 4 / 2;
        end
    end
    assign sck_t = temp[31];

    // Generate clock enable signal based on sck_t rising edge
    reg sck_t_prev;
    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset) begin
        if (rsi_MRST_reset) begin
            sck_t_prev <= 1'b0; // Initialize to known state
        end else begin
            sck_t_prev <= sck_t;
        end
    end
    wire sck_t_rise_enable = sck_t & ~sck_t_prev;

    // Measurement Data, CRC, and Control Registers (Clocked by primary clock, enabled)
    reg [15:0] measure_date;
    reg [7:0]  crc;
    reg [7:0]  command_reg;
    reg        temp_moist; // 0 for temperature, 1 for moisture

    // State Machine Parameters
    parameter Address = 3'b000;
    parameter Measure_Temperature = 5'b00011;
    parameter Measure_Relative_Humidity = 5'b00101;
    parameter Read_Status_Register = 5'b00111;
    parameter Write_Status_Register = 5'b00110;

    parameter dir_out = 1'b1;
    parameter dir_in = 1'b0;

    // State Definitions
    parameter Reset_0 = 15'd0;
    parameter Reset_1 = Reset_0 + 1;
    parameter Reset_2 = Reset_1 + 1;
    parameter Reset_3 = Reset_2 + 1;
    parameter Reset_4 = Reset_3 + 1;
    parameter Reset_5 = Reset_4 + 1;
    parameter Reset_6 = Reset_5 + 1;
    parameter Reset_7 = Reset_6 + 1;
    parameter Reset_8 = Reset_7 + 1;
    parameter Reset_9 = Reset_8 + 1;
    parameter Transmision_Start_0 = Reset_9 + 1;
    parameter Transmision_Start_1 = Transmision_Start_0 + 1;
    parameter Transmision_Start_2 = Transmision_Start_1 + 1;
    parameter Transmision_Start_3 = Transmision_Start_2 + 1;
    parameter Transmision_Start_4 = Transmision_Start_3 + 1;
    parameter Transmision_Start_5 = Transmision_Start_4 + 1;
    parameter Transmision_Start_6 = Transmision_Start_5 + 1;
    parameter Transmision_Start_7 = Transmision_Start_6 + 1;
    parameter Command_0 = Transmision_Start_7 + 1;
    parameter Command_1 = Command_0 + 1;
    parameter Command_2 = Command_1 + 1;
    parameter Command_3 = Command_2 + 1;
    parameter Command_4 = Command_3 + 1;
    parameter Command_5 = Command_4 + 1;
    parameter Command_6 = Command_5 + 1;
    parameter Command_7 = Command_6 + 1;
    parameter Command_ack = Command_7 + 1;
    parameter Measure_wait = Command_ack + 1;
    parameter Date_0 = Measure_wait + 1;
    parameter Date_1 = Date_0 + 1;
    parameter Date_2 = Date_1 + 1;
    parameter Date_3 = Date_2 + 1;
    parameter Date_4 = Date_3 + 1;
    parameter Date_5 = Date_4 + 1;
    parameter Date_6 = Date_5 + 1;
    parameter Date_7 = Date_6 + 1;
    parameter Date_ack_0 = Date_7 + 1;
    parameter Date_8 = Date_ack_0 + 1;
    parameter Date_9 = Date_8 + 1;
    parameter Date_10 = Date_9 + 1;
    parameter Date_11 = Date_10 + 1;
    parameter Date_12 = Date_11 + 1;
    parameter Date_13 = Date_12 + 1;
    parameter Date_14 = Date_13 + 1;
    parameter Date_15 = Date_14 + 1;
    parameter Date_ack_1 = Date_15 + 1;
    parameter Crc_0 = Date_ack_1 + 1;
    parameter Crc_1 = Crc_0 + 1;
    parameter Crc_2 = Crc_1 + 1;
    parameter Crc_3 = Crc_2 + 1;
    parameter Crc_4 = Crc_3 + 1;
    parameter Crc_5 = Crc_4 + 1;
    parameter Crc_6 = Crc_5 + 1;
    parameter Crc_7 = Crc_6 + 1;
    parameter Crc_ack = Crc_7 + 1;
    parameter check_sum = Crc_ack + 1;
    parameter measure_update = check_sum + 1;
    parameter measure_end = measure_update + 1;

    // State Machine Registers (Clocked by primary clock, enabled)
    reg [14:0] state;
    reg [14:0] next_state;
    reg [15:0] time_out;

    // State Register Logic
    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset) begin
        if (rsi_MRST_reset) begin
            state <= Reset_0;
        end else if (sck_t_rise_enable) begin // Use clock enable
            state <= next_state;
        end
    end

    // Timeout Counter Logic
    always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset) begin
        if (rsi_MRST_reset) begin
            time_out <= 16'd0;
        end else if (sck_t_rise_enable) begin // Use clock enable
            // Use registered state value for comparison
            case (state)
                Command_ack:  time_out <= time_out + 1;
                Measure_wait: time_out <= time_out + 1; // Changed from Date_ack_0 based on FSM flow
                default:      time_out <= 16'd0;
            endcase
        end
    end

    // Data Capture and Update Logic
    always @(posedge c