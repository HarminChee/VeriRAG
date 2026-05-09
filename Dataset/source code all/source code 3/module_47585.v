`timescale  1 ps / 1 ps
`celldefine
`endcelldefine
`timescale  1 ps / 1 ps
`celldefine
module KEEPER (O);
    inout O;
`ifdef XIL_TIMING
    parameter LOC = "UNPLACED";
`endif
    reg   in;
    always @(O)
	if (O)
	    in <= 1;
	else
	    in <= 0;
    buf (pull1, pull0) B1 (O, in);
endmodule
`endcelldefine
