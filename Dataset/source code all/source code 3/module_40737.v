`timescale 1 ns/10 ps
`timescale 1 ns/10 ps
module pcx_monitor (
	rclk,
	spc_pcx_req_pq, 
	spc_pcx_data_pa 
	);
    input rclk;
    input [4:0] spc_pcx_req_pq;
    input [123:0] spc_pcx_data_pa;
    parameter GOOD_TRAP_1 = 40'h1000122000;
    parameter GOOD_TRAP_2 = 40'h0000082000;
    parameter GOOD_TRAP_3 = 40'h1A00122000;
    parameter BAD_TRAP_1  = 40'h1000122020;
    parameter BAD_TRAP_2  = 40'h0000082020;
    parameter BAD_TRAP_3  = 40'h1A00122020;
    reg any_req_pa;
    always @(posedge rclk) begin
	any_req_pa <= | spc_pcx_req_pq;
    end
    always @(posedge rclk) begin
	if (any_req_pa && spc_pcx_data_pa[123] &&
	    spc_pcx_data_pa[122:118] == 5'b10000) begin
	    $display("PCX:  %t : I-fetch from address  0x%h", $time,
		spc_pcx_data_pa[103:64]);
	    if (spc_pcx_data_pa[103:64] === GOOD_TRAP_1 ||
		spc_pcx_data_pa[103:64] === GOOD_TRAP_2 ||
		spc_pcx_data_pa[103:64] === GOOD_TRAP_3) begin
	    $display("PCX:  %t : Reached good trap:  Diag Passed\n", $time);
	    #500;
	    $finish;
	    end
	    if (spc_pcx_data_pa[103:64] === BAD_TRAP_1 ||
		spc_pcx_data_pa[103:64] === BAD_TRAP_2 ||
		spc_pcx_data_pa[103:64] === BAD_TRAP_3) begin
	    $display( "PCX:  %t : Reached bad trap: Diag Failed\n", $time);
	    #500;
	    $finish;
	    end
	end
    end
endmodule
