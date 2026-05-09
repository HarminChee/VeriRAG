module econet(
    input wire clock_24m,  
    output reg serial_cpld_to_mcu = 1'b1,  
    input wire serial_mcu_to_cpld,  
    input wire mcu_is_transmitting,  
    output reg outputting_frame = 1'b0,  
    output wire serial_buffer_empty,  
    input wire drive_econet_clock,  
    input wire econet_clock_from_mcu,  
    input wire econet_data_R,  
    output wire econet_data_D,  
    output wire econet_data_DE,  
    input wire econet_clock_R,  
    output wire econet_clock_D,  
    output wire econet_clock_DE,  
    input wire collision_detect,
    input wire nNETINT,
    input wire RnW,
    input wire nADLC,
    input wire PHI2,
    input wire A0,
    input wire A1,
    output wire [7:0] D,  
    output wire nRESET,
    input wire PA18,
    input wire PA19,
    input wire PA22,
    input wire PA23
);
reg [2:0] econet_clock_sync = 3'b0;
reg [2:0] econet_data_sync = 3'b0;
reg [2:0] mcu_is_transmitting_sync = 3'b0;
reg [9:0] serial_shifter = 10'b1111111111;  
reg [3:0] serial_bit_count = 4'b0;  
reg serial_input_buffer_full = 1'b0;
assign serial_buffer_empty = !serial_input_buffer_full && (serial_bit_count == 0);
reg [2:0] econet_bit_count = 0;  
reg [2:0] econet_ones_count = 0;  
reg [7:0] econet_shifter = 0;  
reg econet_output_raw = 1'b0;  
reg econet_transmitting = 1'b0;  
reg econet_initiate_abort = 1'b0;  
wire econet_clock_out;
reg econet_data_out = 1'b1;  
reg buggy_rev1_pcb = 1'b1;
assign econet_data_DE = outputting_frame;
assign econet_data_D = econet_data_out;
assign econet_clock_DE = drive_econet_clock;
assign econet_clock_out = econet_clock_from_mcu;
assign econet_clock_D = econet_clock_out ^ buggy_rev1_pcb;
wire econet_clock;
assign econet_clock = drive_econet_clock ? econet_clock_from_mcu : (econet_clock_R ^ buggy_rev1_pcb);
assign nRESET = mcu_is_transmitting_sync[2]; 
assign D[7] = serial_mcu_to_cpld; 
assign D[6] = serial_cpld_to_mcu; 
assign D[5] = serial_input_buffer_full; 
assign D[4] = econet_initiate_abort; 
assign D[3] = econet_transmitting; 
assign D[2] = outputting_frame; 
always @(negedge clock_24m) begin
    serial_cpld_to_mcu <= mcu_is_transmitting_sync[2] ? 1'b1 : serial_shifter[0];
end
always @(posedge clock_24m) begin
    econet_clock_sync <= {econet_clock_sync[1:0], econet_clock};
    econet_data_sync <= {econet_data_sync[1:0], (econet_data_R ^ buggy_rev1_pcb)};
    mcu_is_transmitting_sync <= {mcu_is_transmitting_sync[1:0], mcu_is_transmitting};
    if (mcu_is_transmitting_sync[2] != mcu_is_transmitting_sync[1]) begin  
        serial_bit_count <= 0;
        serial_input_buffer_full <= 1'b0;
        serial_shifter[0] <= 1'b1;
        econet_initiate_abort <= 1'b0;
        econet_transmitting <= 1'b0;
        econet_bit_count <= 0;
        econet_ones_count <= 7;
    end else if (mcu_is_transmitting_sync[2] == 1'b1) begin  
        if (serial_bit_count == 0) begin
            if (serial_mcu_to_cpld == 1'b0) begin
                serial_bit_count <= 10;
            end
        end else if (serial_bit_count == 1) begin
            if (serial_mcu_to_cpld == 1'b1) begin
                if (serial_input_buffer_full == 1'b1) begin
                    econet_initiate_abort <= 1'b1;
                end else begin
                    serial_input_buffer_full <= 1'b1;
                end
            end else begin
            end
            serial_bit_count <= 0;
        end else begin
            serial_shifter <= {serial_mcu_to_cpld, serial_shifter[8:1]};
            serial_bit_count <= serial_bit_count - 1;
        end
        if (econet_transmitting == 1'b0) begin
            if (econet_initiate_abort == 1'b1) begin
                serial_input_buffer_full <= 1'b0;
                outputting_frame <= 1'b1;
                econet_transmitting <= 1'b1;
                econet_output_raw <= 1'b1;
                econet_shifter <= 8'b11111111;
                econet_bit_count <= 3'b0;
            end else if (serial_input_buffer_full == 1'b1) begin
                serial_input_buffer_full <= 1'b0;
                if (serial_shifter[8] == 1'b1) begin
                    outputting_frame <= 1'b1;
                end
                econet_transmitting <= 1'b1;
                econet_output_raw <= serial_shifter[8];
                econet_shifter <= serial_shifter[7:0];
                econet_bit_count <= 3'b0;
            end
        end
        if (econet_clock_sync[2] == 1'b1 && econet_clock_sync[1] == 1'b0) begin
            if (outputting_frame == 1'b1) begin
                if (econet_transmitting == 1'b0) begin
                    outputting_frame <= 1'b0;
                    econet_data_out <= 1'b1;
                end
            end
            if (econet_transmitting == 1'b0) begin
            end else begin
                econet_data_out <= econet_shifter[0];
                if (econet_output_raw == 1'b0 && econet_ones_count == 4 && econet_shifter[0] == 1'b1) begin
                    econet_ones_count <= 0;
                    econet_shifter[0] <= 1'b0;
                end else begin
                    if (econet_shifter[0] == 1'b1) begin
                        econet_ones_count <= econet_ones_count + 1;
                    end else begin
                        econet_ones_count <= 0;
                    end
                    econet_shifter <= {1'b1, econet_shifter[7:1]};
                    econet_bit_count <= econet_bit_count + 1;
                end
                if (econet_bit_count == 7) begin
                    econet_transmitting <= 1'b0;
                end
            end
        end
    end else begin  
        if (serial_bit_count != 0) begin
            serial_shifter <= {1'b1, serial_shifter[9:1]};
            serial_bit_count <= serial_bit_count - 1;
        end
        if (econet_clock_sync[2] == 1'b0 && econet_clock_sync[1] == 1'b1) begin
            if (econet_ones_count == 7 && econet_data_sync[2] == 1'b1) begin
            end else if (econet_ones_count == 6 && econet_data_sync[2] == 1'b1) begin
                econet_ones_count <= econet_ones_count + 1;
                econet_bit_count <= 0;
            end else if (econet_ones_count == 6 && econet_data_sync[2] == 1'b0) begin
                $display("received flag: put 1+%02x (1+%b) in serial shifter", {econet_shifter[6:0], 1'b0}, {econet_shifter[6:0], 1'b0});
                serial_shifter <= {
                    1'b1, 
                    {econet_data_sync[2],
                     econet_shifter[0],
                     econet_shifter[1],
                     econet_shifter[2],
                     econet_shifter[3],
                     econet_shifter[4],
                     econet_shifter[5],
                     econet_shifter[6]}, 
                    1'b0  
                };
                serial_bit_count <= 11;
                econet_ones_count <= 1'b0;
                econet_bit_count <= 0;
            end else if (econet_ones_count == 5 && econet_data_sync[2] == 1'b0) begin
                econet_ones_count <= 0;
            end else begin
                if (econet_data_sync[2] == 1'b1) begin
                    econet_ones_count <= econet_ones_count + 1;
                end else begin
                    econet_ones_count <= 0;
                end
                econet_shifter <= {econet_shifter[6:0], econet_data_sync[2]};
                econet_bit_count <= econet_bit_count + 1;
                if (econet_bit_count == 7) begin
                    $display("received byte: put 0+%02x (0+%b) in serial shifter", {econet_shifter[6:0], econet_data_sync[2]}, {econet_shifter[6:0], econet_data_sync[2]});
                    serial_shifter <= {
                        1'b0, 
                        {econet_data_sync[2],
                         econet_shifter[0],
                         econet_shifter[1],
                         econet_shifter[2],
                         econet_shifter[3],
                         econet_shifter[4],
                         econet_shifter[5],
                         econet_shifter[6]}, 
                        1'b0  
                    };
                    serial_bit_count <= 11;
                end
            end
        end  
    end  
end
endmodule
