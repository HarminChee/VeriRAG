module spl_pt_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     we0,
	input  wire                     re0, 
    input  wire [ADDR_WIDTH-1:0]    addr0,  
    input  wire [DATA_WIDTH-1:0]    din0,	
    output reg  [DATA_WIDTH-1:0]    dout0,
	input  wire                     re1,
    input  wire [ADDR_WIDTH-1:0]    addr1,
    output reg  [DATA_WIDTH-1:0]    dout1    
);
`ifdef VENDOR_XILINX
    (* ram_extract = "yes", ram_style = "block" *)
    reg  [DATA_WIDTH-1:0]         mem[0:2**ADDR_WIDTH-1];
`else
    (* ramstyle = "AUTO, no_rw_check" *) 
    reg  [DATA_WIDTH-1:0]         mem[0:2**ADDR_WIDTH-1];
`endif
    always @(posedge clk) begin
        if (we0)
            mem[addr0] <= din0;  
		if (re0)
        	dout0 <= mem[addr0];
		if (re1)			
        	dout1 <= mem[addr1];             			
    end    
endmodule
