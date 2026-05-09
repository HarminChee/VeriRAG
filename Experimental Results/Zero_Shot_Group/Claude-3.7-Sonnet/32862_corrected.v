`timescale 1ns / 1ps
module fastmem(
           input 	    CLKCPU,
           input 	    RESET,
           input [23:0]     A,
           inout [7:0] 	    D,
           input [1:0] 	    SIZ,
           input 	    AS20,
           input 	    RW20,
           input 	    DS20,
           output reg 	    RAM_MUX,
           output  	    RAMOE,
           output reg [3:0] CAS,
           output reg [1:0] RAS,
           output [1:0]     RAM_A,
           output 	    RAM_ACCESS,
	   output 	    Z2_ACCESS,
	   output reg	    WAIT
       );

wire [5:0] zaddr = {A[6:1]};
reg configured = 1'b0;
reg shutup = 1'b0;
reg [7:4] data_out;
reg [7:5] base_address;

wire Z2_WRITE = (Z2_ACCESS | RW20);
wire Z2_READ = (Z2_ACCESS | ~RW20);

always @(negedge DS20 or negedge RESET) begin
    if (RESET == 1'b0) begin
        configured <= 1'b0;
        shutup <= 1'b0;
    end else begin
        if (Z2_WRITE == 1'b0) begin
            case (zaddr)
                6'h24: begin
                    base_address[7:5] <= D[7:5];
                    configured <= 1'b1;
                end
                6'h26: shutup <= 1'b1;
            endcase
        end
        case (zaddr)
	  6'h00: data_out[7:4] <= 4'he;
	  6'h01: data_out[7:4] <= 4'h0;
	  6'h02: data_out[7:4] <= 4'hd;
	  6'h03: data_out[7:4] <= 4'h7;
	  6'h04: data_out[7:4] <= 4'h7;
	  6'h08: data_out[7:4] <= 4'he;
	  6'h09: data_out[7:4] <= 4'hc;
	  6'h0a: data_out[7:4] <= 4'h2;
	  6'h0b: data_out[7:4] <= 4'h7;
	  6'h11: data_out[7:4] <= 4'he;
	  6'h12: data_out[7:4] <= 4'hb;
	  6'h13: data_out[7:4] <= 4'h7;
	  default: data_out[7:4] <= 4'hf;
        endcase
    end
end

wire [3:0] bank;
assign bank[0] = A[23:21] != 3'b001; 
assign bank[1] = A[23:21] != 3'b010; 
assign bank[2] = A[23:21] != 3'b011; 
assign bank[3] = A[23:21] != 3'b100; 

wire [1:0] chip_ras = {&bank[3:2], &bank[1:0]};
wire chip_selected = &chip_ras[1:0] | ~configured;

wire [3:0] casint;
assign casint[3] = A[1] | A[0];
assign casint[2] = (~SIZ[1] & SIZ[0] & ~A[0]) | A[1];
assign casint[1] = (SIZ[1] & ~SIZ[0] & ~A[1] & ~A[0]) | (~SIZ[1] & SIZ[0] & ~A[1]) |(A[1] & A[0]);
assign casint[0] = (~SIZ[1] & SIZ[0] & ~A[1] ) | (~SIZ[1] & SIZ[0] & ~A[0] ) | (SIZ[1] & ~A[1] & ~A[0] ) | (SIZ[1] & ~SIZ[0] & ~A[1] );

assign RAM_A = RAM_MUX ? A[21:20] : A[3:2];

reg 	  AS20_D; 
reg [3:0] state = 4'd0;
reg [7:0] refresh_count = 8'd0;
reg 	  refresh_req = 1'b0;
reg [3:0] startup_count = 4'd0;

localparam CYCLE_IDLE = 4'd0,
           CYCLE_RAS = 4'd1,
           CYCLE_CAS = 4'd3,
           CYCLE_WAIT = 4'd4,
           CYCLE_CBR1 = 4'd8,
           CYCLE_CBR2 = 4'd9,
           CYCLE_CBR3 = 4'd10;

always @(posedge CLKCPU or posedge AS20) begin
    if(AS20 == 1'b1) begin
       state <= CYCLE_IDLE;
       AS20_D <= 1'b1;
       RAS <= 2'b11;
       CAS <= 4'b1111;
       WAIT <= 1'b1;
    end else begin
       AS20_D <= AS20;
       case (state)
	 CYCLE_IDLE: begin 
	    RAS <= 2'b11;
	    CAS <= 4'b1111;
	    if (AS20_D & ~AS20) begin 
	       refresh_count <= refresh_count + 8'd1;
	    end
	    if (refresh_count > 8'd220) begin
	       refresh_req <= 1'b1;
	       refresh_count <= 8'd0;
	    end
	    if (refresh_req & RW20) begin 
	       state <= CYCLE_CBR1;
	    end else if (chip_selected == 1'b0) begin
	       state <= CYCLE_RAS;
	    end
	 end
	 CYCLE_RAS: begin
	    RAS[0] <= chip_ras[0];
	    RAS[1] <= chip_ras[1];
	    state <= CYCLE_CAS;
	 end
	 CYCLE_CAS: begin
	    WAIT <= 1'b0;
	    CAS[0] <= casint[0] & ~RW20;
	    CAS[1] <= casint[1] & ~RW20;
	    CAS[2] <= casint[2] & ~RW20;
	    CAS[3] <= casint[3] & ~RW20; 
	    state <= CYCLE_WAIT;
	 end
	 CYCLE_WAIT: begin
	    state <= CYCLE_WAIT;
	 end
	 CYCLE_CBR1: begin 
	    CAS <= 4'b0000;
	    state <= CYCLE_CBR2;
	    refresh_req <= 1'b0;
	 end
	 CYCLE_CBR2: begin
	    RAS <= 2'b00;
	    state <= CYCLE_CBR3;
	 end
	 CYCLE_CBR3: begin    
	    CAS <= 4'b1111;
	    RAS <= 2'b11;
	    state <= CYCLE_IDLE;
	 end
	 default: state <= CYCLE_IDLE;
       endcase 
    end 
end

always @(negedge CLKCPU) begin
    if(&RAS == 1'b1) begin 
        RAM_MUX <= 1'b0;
    end else begin 
        RAM_MUX <= 1'b1;
    end
end

assign D = Z2_READ ? 8'bzzzzzzzz : {data_out,4'bzzzz};
assign RAM_ACCESS = (AS20 | chip_selected);
assign Z2_ACCESS = (A[23:16] != 8'hE8) | AS20 | DS20 | configured | shutup;
assign RAMOE = 1'b0;

endmodule