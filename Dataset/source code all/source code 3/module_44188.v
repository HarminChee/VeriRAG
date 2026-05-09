`timescale 1ns / 1ps
`timescale 1ns / 1ps
module spiMode0(
    CLK,
    RST,
    sndRec,
    DIN,
    MISO,
    MOSI,
    SCLK,
	 BUSY,
    DOUT
    );
			input CLK;						
			input RST;						
			input sndRec;					
			input [7:0] DIN;				
			input MISO;						
			output MOSI;					
			output SCLK;					
			output BUSY;					
			output [7:0] DOUT;			
			wire MOSI;
			wire SCLK;
			wire [7:0] DOUT;
			reg BUSY;
			parameter [1:0] Idle = 2'd0,
								 Init = 2'd1,
								 RxTx = 2'd2,
								 Done = 2'd3;
			reg [4:0] bitCount;							
			reg [7:0] rSR = 8'h00;						
			reg [7:0] wSR = 8'h00;						
			reg [1:0] pState = Idle;					
			reg CE = 0;										
			assign SCLK = (CE == 1'b1) ? CLK : 1'b0;
			assign MOSI = wSR[7];
			assign DOUT = rSR;
			always @(negedge CLK) begin
					if(RST == 1'b1) begin
							wSR <= 8'h00;
					end
					else begin
							case(pState)
									Idle : begin
											wSR <= DIN;
									end
									Init : begin
											wSR <= wSR;
									end
									RxTx : begin
											if(CE == 1'b1) begin
													wSR <= {wSR[6:0], 1'b0};
											end
									end
									Done : begin
											wSR <= wSR;
									end
							endcase
					end
			end
			always @(posedge CLK) begin
					if(RST == 1'b1) begin
							rSR <= 8'h00;
					end
					else begin
							case(pState)
									Idle : begin
											rSR <= rSR;
									end
									Init : begin
											rSR <= rSR;
									end
									RxTx : begin
											if(CE == 1'b1) begin
													rSR <= {rSR[6:0], MISO};
											end
									end
									Done : begin
											rSR <= rSR;
									end
							endcase
					end
			end
			always @(negedge CLK) begin
					if(RST == 1'b1) begin
							CE <= 1'b0;				
							BUSY <= 1'b0;			
							bitCount <= 4'h0;		
							pState <= Idle;		
					end
					else begin
							case (pState)
								Idle : begin
										CE <= 1'b0;				
										BUSY <= 1'b0;			
										bitCount <= 4'd0;		
										if(sndRec == 1'b1) begin
											pState <= Init;
										end
										else begin
											pState <= Idle;
										end
								end
								Init : begin
										BUSY <= 1'b1;			
										bitCount <= 4'h0;		
										CE <= 1'b0;				
										pState <= RxTx;		
								end
								RxTx : begin
										BUSY <= 1'b1;						
										bitCount <= bitCount + 1'b1;	
										if(bitCount >= 4'd8) begin
												CE <= 1'b0;
										end
										else begin
												CE <= 1'b1;
										end
										if(bitCount == 4'd8) begin
												pState <= Done;
										end
										else begin
												pState <= RxTx;
										end
								end
								Done : begin
										CE <= 1'b0;			
										BUSY <= 1'b1;		
										bitCount <= 4'd0;	
										pState <= Idle;
								end
								default : pState <= Idle;
							endcase
					end
			end
endmodule
