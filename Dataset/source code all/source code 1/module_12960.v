`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Search_4Comparators(
	input clock,
	input reset,
	input [1023:0] data,
	input [63:0] key,
	output reg match
);
reg [7:0] counter;
reg [63:0] data1, data2, data3, data4;
wire match1, match2, match3, match4;
Comparator c1
(
	.data(data1),
	.key(key),
	.match(match1)
);
Comparator c2
(
	.data(data2),
	.key(key),
	.match(match2)
);
Comparator c3
(
	.data(data3),
	.key(key),
	.match(match3)
);
Comparator c4
(
	.data(data4),
	.key(key),
	.match(match4)
);
always @(posedge clock, posedge reset)
begin
	if (reset)
	begin
		counter <= 0;
		match <= 0;
	end
	else
	begin
		if (counter == 240)
		begin
			counter <= 0;
		end
		else
		begin
			counter <= counter + 1;
		end
		if (match1 || match2 || match3 || match4)
			match <= 1;
		else
			match <= 0;
	end
end
always @*
begin
	if (counter == 240)
	begin
		data1 = data[1023-4*counter-:64];
		data2 = data[1023-4*counter-:64];
		data3 = data[1023-4*counter-:64];
		data4 = data[1023-4*counter-:64];
	end
	else
	begin
		data1 = data[1023-4*counter-:64];
		data2 = data[1022-4*counter-:64];
		data3 = data[1021-4*counter-:64];
		data4 = data[1020-4*counter-:64];
	end
end
endmodule
