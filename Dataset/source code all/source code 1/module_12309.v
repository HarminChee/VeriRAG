`timescale 1ns / 1ps
`timescale 1ns / 1ps
module dragster_spi_adapter #
(
    EXTENDED_CLOCKS = 3,
	TRANSACTION_DEPTH = 128,
	DATA_WIDTH = 16
)
(
    input wire clk,
    input wire reset,
    input wire internal_mosi,
    output wire internal_miso,
    input wire internal_sck,
    input wire[1:0] internal_ss,
    output reg external_mosi,
    input wire external_miso,
    output wire external_sck,
    output reg[1:0] external_ss
	);
reg[DATA_WIDTH - 1 : 0] transactions[TRANSACTION_DEPTH - 1 : 0];
reg[1:0] slaves[TRANSACTION_DEPTH - 1 : 0];
reg[3:0] bit_counter;
reg[3:0] internal_bit_count;
reg[7:0] external_clock_count;
reg generate_external_clock;
reg clock_enable;
reg[7:0] buffered_transaction_count;
reg[7:0] forwarded_transaction_count;
reg[7:0] transaction_about_to_be_buffered;
integer counter;
assign external_sck = clock_enable ? clk : 0;
always @ (negedge clk)
begin
    if(!reset) 
    begin
        forwarded_transaction_count <= 0;
        bit_counter <= 0;
        external_mosi <= 0;
        external_ss <= 3;
		clock_enable <= 0;
		generate_external_clock <= 0;
		external_clock_count <= 0;
    end
    else 
    begin
        if(buffered_transaction_count > 0 && forwarded_transaction_count < buffered_transaction_count) 
        begin
		    clock_enable <= 1;
		    if(clock_enable && ~generate_external_clock)
			begin
			    bit_counter <= bit_counter + 1;
                external_ss <= slaves[forwarded_transaction_count];
				external_mosi <= transactions[forwarded_transaction_count][bit_counter];             
                if(bit_counter == DATA_WIDTH - 1)
				    generate_external_clock <= 1;
			end
			else
			begin
			    external_clock_count <= external_clock_count + 1;
				if(EXTENDED_CLOCKS == 0 || external_clock_count == EXTENDED_CLOCKS)
				begin
				    external_clock_count <= 0;
					generate_external_clock <= 0;
					clock_enable <= 0;
					external_ss <= 3;
					external_mosi <= 0;
					if(forwarded_transaction_count == TRANSACTION_DEPTH - 1)
					    forwarded_transaction_count <= 0;
					else forwarded_transaction_count <= forwarded_transaction_count + 1;
					bit_counter <= 0;
				end
			end
        end
    end
end
reg[15:0] internal_transaction_buffer;
always @ (negedge reset or negedge internal_sck)
begin
    if(!reset) 
    begin
        for(counter = 0; counter < TRANSACTION_DEPTH; counter = counter + 1)
        begin
            slaves[counter] = 3;
            transactions[counter] = 0;
        end
        buffered_transaction_count = 0;
		internal_bit_count = 0;
    end
    else
    begin
	    internal_bit_count = internal_bit_count + 1;
        internal_transaction_buffer[internal_bit_count - 1] = internal_mosi;
        if(internal_bit_count == 0) 
        begin
		    internal_transaction_buffer[15] = internal_mosi;
            transactions[buffered_transaction_count] = internal_transaction_buffer;
            slaves[buffered_transaction_count] = internal_ss;
            if(buffered_transaction_count == TRANSACTION_DEPTH - 1)
                buffered_transaction_count = 0;
            else buffered_transaction_count = buffered_transaction_count + 1;
			internal_bit_count = 0;
        end
    end
end
endmodule
