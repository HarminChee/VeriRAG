`timescale 1ps/1ps
`default_nettype none
module FX3_IF_corrected_clk (
    inout wire [31:0] fx3_bus,
    input wire fx3_wr,
    input wire fx3_oe,
    input wire fx3_cs,
    input wire fx3_clk,  // Primary clock input
    output reg fx3_rdy,
    output reg fx3_ack,
    output reg fx3_rd_finish,
    input wire fx3_rst,  // Primary reset input
    output wire         BUS_CLK,  // Output clock, now directly driven by fx3_clk
    output wire         BUS_RST,  // Output reset, driven by fx3_rst
    output reg          BUS_WR,
    output reg          BUS_RD,
    output reg [31:0]   BUS_ADD,
    inout wire [31:0]   BUS_DATA,
    input wire          BUS_BYTE_ACCESS,
    input wire FLAG1,
    input wire FLAG2
);

wire [31:0] DataOut;
reg [31:0] DataIn;
assign BUS_DATA = BUS_WR ? DataIn[31:0]: 32'bz;
assign DataOut[31:0] = BUS_WR ? 32'bz : BUS_DATA;
genvar gen;
reg  [31:0] DATA_MISO;
wire [31:0] DATA_MOSI;
reg  [31:0] ReqCountLimit;
reg  [31:0] ReqCount;
reg  OE;
reg  CS;
reg  FLAG1_reg;
reg  FLAG2_reg;
reg RD_VALID;
reg RDY;

// Assign primary reset directly to BUS_RST
assign BUS_RST = fx3_rst;

// Assign primary clock directly to BUS_CLK output
// Removed IBUFG and intermediate BUS_CLK wire for internal clocking.
// All internal FFs now use fx3_clk directly.
assign BUS_CLK = fx3_clk;

reg [7:0] DATA_BYTE_RD [3:0];
reg [7:0] DATA_BYTE_WR [3:0];
wire [1:0] BYTE;
assign BYTE = ReqCount[1:0]-1;
reg WR_BYTE;

// Use primary clock fx3_clk directly
always@ (posedge fx3_clk)
    DATA_BYTE_RD[BYTE] <= DataOut[7:0];

reg RD_FINISH;

// Use primary clock fx3_clk directly
always @ (posedge fx3_clk)
begin
 	fx3_ack <= RD_VALID;
 	fx3_rd_finish <= RD_FINISH;
	fx3_rdy <= RDY;
	if(BUS_RST) // Use BUS_RST which is derived from primary fx3_rst
	   DATA_MISO <= 0;
	else if(BUS_BYTE_ACCESS) begin
	   if(BYTE==0)
	       DATA_MISO <= { {3{8'b0}}, DataOut[7:0]};
	   else if(BYTE==1)
	       DATA_MISO <= { {2{8'b0}}, DataOut[7:0], DATA_BYTE_RD[0]};
	   else if(BYTE==2)
	       DATA_MISO <= {8'b0, DataOut[7:0], DATA_BYTE_RD[1], DATA_BYTE_RD[0]};
	   else
	       DATA_MISO <= {DataOut[7:0], DATA_BYTE_RD[2], DATA_BYTE_RD[1], DATA_BYTE_RD[0]};
    end
	else
	   DATA_MISO <= DataOut;
end

reg first_word_written_check;

// Use primary clock fx3_clk directly
always @ (posedge fx3_clk)
begin
 	if(BUS_BYTE_ACCESS)
 	   BUS_WR <= (fx3_wr | WR_BYTE);
 	else
 	   BUS_WR <= fx3_wr;
 	OE <= fx3_oe;
 	CS <= fx3_cs;
 	FLAG1_reg <= FLAG1;
    FLAG2_reg <= FLAG2;
    if(!CS | !BUS_BYTE_ACCESS)
        first_word_written_check <= 0;
 	if(BUS_BYTE_ACCESS & (fx3_wr | BUS_WR) & ((ReqCount+1) < ReqCountLimit)) begin
 	   if(((ReqCount[1:0]==0)|(ReqCount[1:0]==3)) & (!first_word_written_check)) begin
 	       {DATA_BYTE_WR[2], DATA_BYTE_WR[1], DATA_BYTE_WR[0], DataIn[7:0]} <= DATA_MOSI;
           first_word_written_check <= 1;
 	   end
 	   else if((ReqCount[1:0]==0) & first_word_written_check) begin
 	       DataIn[7:0] <= DATA_BYTE_WR[0];
 	       first_word_written_check <= 0;
 	   end
 	   else if(ReqCount[1:0]==1)
           DataIn[7:0] <= DATA_BYTE_WR[1];
       else if(ReqCount[1:0]==2)
           DataIn[7:0] <= DATA_BYTE_WR[2];
	end
	else
	   DataIn <= DATA_MOSI;
end

parameter IDLE        = 0;
parameter IN_ADDR     = 1;
parameter WR_ADDR_INC = 2;
parameter IN_COUNT    = 3;
parameter FINISH_RD   = 4;
parameter RD_ADDR_INC = 5;
parameter RD_WAIT     = 6;
parameter WAIT        = 7;

reg [4:0] state, next_state;

// Use primary clock fx3_clk directly
always @ (posedge fx3_clk)
    if (BUS_RST) // Use BUS_RST which is derived from primary fx3_rst
      state <= IDLE;
    else
      state <= next_state;

always @ (*) begin
    case(state)
        IDLE :
            if (CS & !OE & !first_word_written_check)
                next_state = IN_ADDR;
            else
                next_state = IDLE;
        IN_ADDR :
            next_state = IN_COUNT;
        IN_COUNT :
            if (OE)
                next_state = RD_ADDR_INC;
            else if (BUS_WR)
                next_state = WR_ADDR_INC;
            else
                next_state = WAIT;
        WR_ADDR_INC :
            if(BUS_BYTE_ACCESS)
            begin
                if (BUS_WR & ((ReqCount+1) != ReqCountLimit))
                    next_state = WR_ADDR_INC;
                else if ((ReqCount+1) == ReqCountLimit)
                    next_state = IDLE;
                else // Added default case if !BUS_WR
                    next_state = IDLE; // Or WAIT? Assuming IDLE if write stops mid-byte access
            end
            else
            begin
                if (BUS_WR)
                    next_state = WR_ADDR_INC;
                else if (!CS)
                    next_state = IDLE;
                else // Added default case if !BUS_WR and CS is still high
                    next_state = WAIT; // Or IDLE? Assuming WAIT
            end
        RD_ADDR_INC :
            if (OE & (ReqCount != ReqCountLimit))
                next_state = RD_ADDR_INC;
            else if (ReqCount == ReqCountLimit)
                next_state = FINISH_RD;
            else // Added default case if !OE
                next_state = IDLE; // Or WAIT? Assuming IDLE if read stops
        FINISH_RD:
            next_state = IDLE;
        RD_WAIT : // This state seems unused in the next_state logic, might be dead code
            next_state = IDLE;
        WAIT :
            if (OE)
               next_state = RD_ADDR_INC;
            else if (BUS_WR)
               next_state = WR_ADDR_INC;
            else if (!CS) // Added condition to return to IDLE
               next_state = IDLE;
            else
               next_state = WAIT;
        default : next_state = IDLE;
    endcase
end

// Use primary clock fx3_clk directly
always @ (posedge fx3_clk)
begin
    if (BUS_RST) // Use BUS_RST which is derived from primary fx3_rst
    begin
        BUS_ADD <= 32'd0;
        ReqCountLimit <= 32'd0;
        ReqCount <= 32'd0;
        BUS_RD <= 0;
        RD_VALID <= 0;
        RDY <= 0;
        RD_FINISH <= 0;
        WR_BYTE <= 0;
    end
    else
    begin
        // Default assignments for signals not explicitly assigned in every state branch
        // This helps prevent inferred latches if cases are missed.
        BUS_RD <= BUS_RD;
        RD_VALID <= RD_VALID;
        RDY <= RDY;
        RD_FINISH <= RD_FINISH;
        WR_BYTE <= WR_BYTE;
        BUS_ADD <= BUS_ADD;
        ReqCount <= ReqCount;
        ReqCountLimit <= ReqCountLimit;

        if (state == IDLE)
        begin
            ReqCountLimit <= 32'd0;
            ReqCount <= 32'd0;
            BUS_RD <= 0;
            RDY <= 0;
            RD_FINISH <= 0; // Ensure RD_FINISH is cleared
            WR_BYTE <= 0;   // Ensure WR_BYTE is cleared
            RD_VALID <= 0; // Ensure RD_VALID is cleared
        end
        else if (state == IN_ADDR)
        begin
            BUS_ADD <= DataIn[31:0];
            RD_FINISH <= 0;
            RDY <= 1;
            BUS_RD <= 0; // Ensure BUS_RD is low
            WR_BYTE <= 0; // Ensure WR_BYTE is low
            RD_VALID <= 0; // Ensure RD_VALID is low
        end
        else if (state == IN_COUNT)
        begin
            if (OE) begin
                BUS_RD <= 1;
                RDY <= 1; // Assume RDY stays high for read start
            end else if (BUS_WR)
            begin
                if(BUS_BYTE_ACCESS)
                begin
                    BUS_ADD[31:0] <= BUS_ADD[31:0] + 1;
                    ReqCount <= ReqCount + 1;
                    RDY <= 0; // RDY likely low during byte writes
                end
                else begin
                    BUS_ADD[31:0] <= BUS_ADD[31:0] + 4;
                    RDY <= 1; // RDY likely high during word writes
                end
            end
            else // Neither OE nor BUS_WR, receiving count
            begin
                ReqCountLimit <= (DataIn[31:0]);
                if (BUS_BYTE_ACCESS) begin
                    RDY <= 0; // Set RDY low, wait for WR/OE
                    if (fx3_wr) // Check if fx3_wr is asserted when count is received
                       WR_BYTE <= 1;
                    else
                       WR_BYTE <= 0;
                end else begin
                    RDY <= 1; // Set RDY high for word access
                    WR_BYTE <= 0;
                end
                 BUS_RD <= 0; // Ensure BUS_RD is low
            end
             RD_VALID <= 0; // Ensure RD_VALID is low
             RD_FINISH <= 0; // Ensure RD_FINISH is low
        end
        else if (state == WR_ADDR_INC)
        begin
            if(BUS_BYTE_ACCESS)
            begin
                if (BUS_WR & ((ReqCount+1) != ReqCountLimit))
                begin
                    BUS_ADD[31:0] <= BUS_ADD[31:0] + 1;
                    ReqCount <= ReqCount + 1;
                    if(ReqCount[1:0] == 2'b11 && ((ReqCount+4) < ReqCountLimit))
                        RDY <= 1; // Ready for next word input
                    else
                        RDY <= 0;
                    if (ReqCount+2 >= ReqCountLimit) // Check based on incremented count
                       WR_BYTE <= 0;
                    else
                       WR_BYTE <= 1; // Continue byte write mode
                end else if ((ReqCount+1) == ReqCountLimit) begin // Last byte written
                    ReqCount <= ReqCount + 1; // Update count for the last time
                    WR_BYTE <= 0;
                    RDY <= 0; // Not ready anymore
                end else begin // Write stopped before limit
                    WR_BYTE <= 0;
                    RDY <= 0;
                end
            end
            else // Word access
            begin
                if (BUS_WR) begin
                    BUS_ADD[31:0] <= BUS_ADD[31:0] + 4;
                    RDY <= 1; // Ready for next word
                end else begin
                    RDY <= 0; // Not ready if write stops
                end
                WR_BYTE <= 0; // Not in byte mode
            end
             BUS_RD <= 0; // Ensure BUS_RD is low
             RD_VALID <= 0; // Ensure RD_VALID is low
             RD_FINISH <= 0; // Ensure RD_FINISH is low
        end
        else if (state == RD_ADDR_INC)
        begin
            RDY <= 0; // Generally not ready during read data phase
            WR_BYTE <= 0; // Not writing
            if (OE & (ReqCount != ReqCountLimit))
            begin
                if(BUS_BYTE_ACCESS)
                begin
                    BUS_ADD[31:0] <= BUS_ADD + 1;
                    ReqCount <= ReqCount + 1;
                    if(ReqCount + 1 == ReqCountLimit) begin // Next state will be FINISH_RD
                        BUS_RD <= 0;
                        RD_VALID <= 1; // Valid data for the last byte
                    end else begin
                        BUS_RD <= 1;
                        if(ReqCount[1:0] == 2'b11) // Check previous count value's LSBs
                           RD_VALID <= 1; // Valid data at end of word boundary
                        else
                           RD_VALID <= 0;
                    end
                end
                else // Word access
                begin
                    BUS_ADD[31:0] <= BUS_ADD + 4;
                    ReqCount <= ReqCount + 4;
                    if(ReqCount + 4 >= ReqCountLimit) begin // Check against limit after increment
                        BUS_RD <= 0; // Stop requesting read data
                    end else begin
                        BUS_RD <= 1; // Continue requesting read data
                    end
                    RD_VALID <= 1; // Word read data is always valid on the next cycle
                end
            end
            else // Read finished or OE deasserted
            begin
                BUS_RD <= 0;
                RD_VALID <= 0;
                if (ReqCount == ReqCountLimit) begin // Normal finish
                    RD_FINISH <= 1;
                end else begin // Premature finish?
                    RD_FINISH <= 0; // Don't assert finish if count not reached
                end
            end
        end
        else if (state == FINISH_RD) begin
            // State only lasts one cycle, clear signals for IDLE
            BUS_RD <= 0;
            RD_VALID <= 0;
            RD_FINISH <= 0; // Cleared on next clock edge when state moves to IDLE
            RDY <= 0;
            WR_BYTE <= 0;
        end
        else if (state == WAIT)
        begin
            BUS_RD <= 0; // Default
            RD_VALID <= 0; // Default
            RD_FINISH <= 0; // Default
            RDY <= RDY; // Maintain RDY state? Or set based on BUS_BYTE_ACCESS? Let's clear it.
            RDY <= 0;
            WR_BYTE <= WR_BYTE; // Maintain WR_BYTE state? Let's clear it.
            WR_BYTE <= 0;

            if (OE) begin
                BUS_RD <= 1; // Start read
            end else if (BUS_WR)
            begin
                if(BUS_BYTE_ACCESS)
                begin
                    BUS_ADD[31:0] <= BUS_ADD[31:0] + 1;
                    ReqCount <= ReqCount + 1;
                    RDY <= 0;
                    if (ReqCount+1 >= ReqCountLimit) // Check if this write reaches the limit
                        WR_BYTE <= 0;
                    else
                        WR_BYTE <= 1; // Continue byte write
                end
                else begin
                    BUS_ADD[31:0] <= BUS_ADD[31:0] + 4;
                    RDY <= 1; // Ready for next word write
                end
            end
            else if (fx3_wr & BUS_BYTE_ACCESS) // Check if initiating byte write from WAIT
            begin
                if(ReqCountLimit > 1) // Assume count is already set
                    WR_BYTE <= 1;
                if ((ReqCount+4) < ReqCountLimit) // Check if ready for next word input later
                    RDY <= 1;
                else
                    RDY <= 0;
            end
        end
    end
end

generate
for (gen = 0; gen < 32; gen = gen + 1)
	begin : tri_buf
		IOBUF #(
			.DRIVE(12),
			.IBUF_LOW_PWR("FALSE"),
			.IOSTANDARD("LVCMOS33"),
			.SLEW("FAST")
		) IOBUF_inst (
			.O(DATA_MOSI[gen]),
			.IO(fx3_bus[gen]),
			.I(DATA_MISO[gen]),
			.T(!(fx3_oe & fx3_cs))
		);
	end
endgenerate

endmodule