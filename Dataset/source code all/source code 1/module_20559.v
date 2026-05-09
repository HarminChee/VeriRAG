`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Search_8Comparators(
	input clock,
	input reset,
	input [1023:0] data,
	input [63:0] key,
	output reg match
);
reg [7:0] counter;
reg [63:0] data1, data2, data3, data4, data5, data6, data7, data8;
wire match1, match2, match3, match4, match5, match6, match7, match8;
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
Comparator c5
(
	.data(data5),
	.key(key),
	.match(match5)
);
Comparator c6
(
	.data(data6),
	.key(key),
	.match(match6)
);
Comparator c7
(
	.data(data7),
	.key(key),
	.match(match7)
);
Comparator c8
(
	.data(data8),
	.key(key),
	.match(match8)
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
		if (counter == 120)
			counter <= 0;
		else
			counter <= counter + 1;
		if (match1 || match2 || match3 || match4)
			match <= 1;
		else
			match <= 0;
	end
end
always @*
begin
	if (counter == 120)
	begin
		data1 = data[1023-4*counter-:64];
		data2 = data[1023-4*counter-:64];
		data3 = data[1023-4*counter-:64];
		data4 = data[1023-4*counter-:64];
		data5 = data[1023-4*counter-:64];
		data6 = data[1023-4*counter-:64];
		data7 = data[1023-4*counter-:64];
		data8 = data[1023-4*counter-:64];
	end
	else
	begin
		data1 = data[1023-4*counter-:64];
		data2 = data[1022-4*counter-:64];
		data3 = data[1021-4*counter-:64];
		data4 = data[1020-4*counter-:64];
		data5 = data[1019-4*counter-:64];
		data6 = data[1018-4*counter-:64];
		data7 = data[1017-4*counter-:64];
		data8 = data[1016-4*counter-:64];
	end
end
endmodule
