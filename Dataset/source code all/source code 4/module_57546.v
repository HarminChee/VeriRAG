`timescale 1 ns / 1 ps
	module sample_generator_v1_0_M_AXIS #
	(
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M_START_COUNT	= 32
	)
	(
		input wire [7:0] FrameSize,
		input wire 	 En,
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
	);
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] counterR;
	assign M_AXIS_TDATA = counterR;
	assign M_AXIS_TSTRB = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	always @(posedge M_AXIS_ACLK)
		if(!M_AXIS_ARESETN) begin	
		      counterR<=0;
		end
		else begin
			if( M_AXIS_TVALID && M_AXIS_TREADY)
			      counterR<= counterR+1;
		end
	reg		sampleGeneratorEnR;
	reg	[7:0]	afterResetCycleCounterR;
	always @(posedge M_AXIS_ACLK)
		if(!M_AXIS_ARESETN) begin
			sampleGeneratorEnR<= 0;
			afterResetCycleCounterR<=0;
		end
		else begin
		      afterResetCycleCounterR <= afterResetCycleCounterR + 1;
		      if(afterResetCycleCounterR == C_M_START_COUNT)
			    sampleGeneratorEnR <= 1;
		end
	reg 		tValidR;
	assign M_AXIS_TVALID = tValidR;
	always @(posedge M_AXIS_ACLK)
	    if(!M_AXIS_ARESETN) begin
		tValidR<= 0;
	    end
	    else begin
		    if(!En)
			tValidR<=0;
		    else if (sampleGeneratorEnR)
			tValidR <= 1;
	    end
	reg 		[7:0] packetCounter;
	always @(posedge M_AXIS_ACLK)
		if(!M_AXIS_ARESETN) begin
		    packetCounter <= 8'hff ;
		end
		else begin
		      if(M_AXIS_TVALID && M_AXIS_TREADY ) begin
			      if(packetCounter== (FrameSize - 1 ))
					packetCounter <= 8'hff;
			      else
					packetCounter <= packetCounter + 1;
		      end
		 end
	assign M_AXIS_TLAST = (packetCounter == (FrameSize -2 )) ?1:0;
	endmodule
`timescale 1 ns / 1 ps
	module sample_generator_v1_0_M_AXIS #
	(
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M_START_COUNT	= 32
	)
	(
		input wire [7:0] FrameSize,
		input wire 	 En,
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
	);
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] counterR;
	assign M_AXIS_TDATA = counterR;
	assign M_AXIS_TSTRB = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	always @(posedge M_AXIS_ACLK)
		if(!M_AXIS_ARESETN) begin	
		      counterR<=0;
		end
		else begin
			if( M_AXIS_TVALID && M_AXIS_TREADY)
			      counterR<= counterR+1;
		end
	reg		sampleGeneratorEnR;
	reg	[7:0]	afterResetCycleCounterR;
	always @(posedge M_AXIS_ACLK)
		if(!M_AXIS_ARESETN) begin
			sampleGeneratorEnR<= 0;
			afterResetCycleCounterR<=0;
		end
		else begin
		      afterResetCycleCounterR <= afterResetCycleCounterR + 1;
		      if(afterResetCycleCounterR == C_M_START_COUNT)
			    sampleGeneratorEnR <= 1;
		end
	reg 		tValidR;
	assign M_AXIS_TVALID = tValidR;
	always @(posedge M_AXIS_ACLK)
	    if(!M_AXIS_ARESETN) begin
		tValidR<= 0;
	    end
	    else begin
		    if(!En)
			tValidR<=0;
		    else if (sampleGeneratorEnR)
			tValidR <= 1;
	    end
	reg 		[7:0] packetCounter;
	always @(posedge M_AXIS_ACLK)
		if(!M_AXIS_ARESETN) begin
		    packetCounter <= 8'hff ;
		end
		else begin
		      if(M_AXIS_TVALID && M_AXIS_TREADY ) begin
			      if(packetCounter== (FrameSize - 1 ))
					packetCounter <= 8'hff;
			      else
					packetCounter <= packetCounter + 1;
		      end
		 end
	assign M_AXIS_TLAST = (packetCounter == (FrameSize -2 )) ?1:0;
	endmodule
