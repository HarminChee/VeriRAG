module ezusb_io #(
	parameter OUTEP = 2,
	parameter INEP = 6
    ) (
        output ifclk,
        input reset,
        output reset_out,
        input ifclk_in,
        inout [15:0] fd,
	output reg SLWR, PKTEND,
	output SLRD, SLOE,
	output [1:0] FIFOADDR,
	input EMPTY_FLAG, FULL_FLAG,
        input [15:0] DI,
        input DI_valid,
        output DI_ready,
        input DI_enable,
        input [15:0] pktend_timeout,
        output reg [15:0] DO,
        output reg DO_valid,
        input DO_ready,
        output [3: