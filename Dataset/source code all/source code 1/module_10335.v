`timescale 1ns / 1ps
`timescale 1ns / 1ps
module dragster_configurator #
(
)
(
    input clk,
    input reset_n,
    input wire miso,
    output wire mosi,
    output wire sclk,
    output wire[1:0] ss_n
);
    reg [15:0] command_buffer;
    wire[7:0] incoming_data;
    reg [3:0] register_counter;
    reg configuration_done;
    reg [1:0] slave;
    reg enable;
    reg start_transaction;
    wire end_of_transaction;
    quick_spi spi_iml(
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .start_transaction(start_transaction),
        .slave(slave),
        .incoming_data(incoming_data),
        .outgoing_data(command_buffer),
        .operation(1'b1),
        .end_of_transaction(end_of_transaction),
        .miso(miso),
        .sclk(sclk),
        .ss_n(ss_n),
        .mosi(mosi));
    always @ (posedge clk) begin
        if(!reset_n) begin
            register_counter <= 0;
        end
        else begin
            if(!register_counter) begin
                enable <= 1'b1;
                start_transaction <= 1'b1;
                command_buffer <= get_dragster_config(register_counter);
                register_counter <= register_counter + 1;
            end
            if(end_of_transaction) begin
                if(register_counter < 4) begin
                    command_buffer <= get_dragster_config(register_counter);
                    register_counter <= register_counter + 1;
                end
                if(register_counter == 4) begin
                    enable <= 1'b0;
                    start_transaction <= 1'b0;
                end
            end
        end
    end
    function[15:0] get_dragster_config(reg [3:0] index);
    reg[15:0] result;
    begin
       case (index)          
          0:
           begin
            result = {8'b00010011,8'b00000101};
           end
           1:
           begin
            result = {8'b00110010, 8'b00000010};
           end
           2: begin
            result = {8'b11000000, 8'b00000011};
           end
          3:
           begin
            result = {8'b00000111 , 8'b00001001};
           end
           4:
           begin
                result = {8'b10101001, 8'b00000001};
           end
           default:
           begin
               result = 16'b0000000000000000;
           end
       endcase
       get_dragster_config = result;
    end
    endfunction
endmodule
