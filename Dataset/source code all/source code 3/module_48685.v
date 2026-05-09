module niosII_system_usb_0 (
	clk,
	reset,
	address,
	chipselect,
	read,
	write,
	writedata,
	OTG_INT0,
	OTG_INT1,
	OTG_DATA,
	readdata,
	irq,
	OTG_RST_N,
	OTG_ADDR,
	OTG_CS_N,
	OTG_RD_N,
	OTG_WR_N
);
input						clk;
input						reset;
input			[ 1: 0]	address;
input						chipselect;
input						read;
input						write;
input			[15: 0]	writedata;
input						OTG_INT0;
input						OTG_INT1;
inout			[15: 0]	OTG_DATA;
output reg	[15: 0]	readdata;
output reg				irq;
output reg				OTG_RST_N;
output reg	[ 1: 0]	OTG_ADDR;
output reg				OTG_CS_N;
output reg				OTG_RD_N;
output reg				OTG_WR_N;
reg			[15: 0]	data_to_usb_chip;
always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		readdata				<= 16'h0000;
		irq					<= 1'b0;
		data_to_usb_chip	<= 16'h0000;
		OTG_RST_N			<= 1'b0;
		OTG_ADDR				<= 2'h0;
		OTG_CS_N				<= 1'b1;
		OTG_RD_N				<= 1'b1;
		OTG_WR_N				<= 1'b1;
	end
	else
	begin
		readdata				<= OTG_DATA;
		irq					<= ~OTG_INT1 | ~OTG_INT0;
		data_to_usb_chip	<= writedata[15:0];
		OTG_RST_N			<= 1'b1;
		OTG_ADDR				<= address;
		OTG_CS_N				<= ~chipselect;
		OTG_RD_N				<= ~read;
		OTG_WR_N				<= ~write;
	end
end
assign OTG_DATA	= OTG_WR_N ? 16'hzzzz : data_to_usb_chip;
endmodule
