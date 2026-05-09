module tx_data_send(
			input pclk_tx,
			input send_null_tx,
			input enable_tx,
			input get_data,
			input get_data_0,
			input [7:0] timecode_tx_i,
			input tickin_tx,
			input [8:0] data_tx_i,
			input txwrite_tx,
			input fct_counter_p,
			output reg [8:0]  tx_data_in,
			output reg [8:0]  tx_data_in_0,
			output reg process_data,
			output reg process_data_0,
			output reg [7:0]  tx_tcode_in,
			output reg tcode_rdy_trnsp
		   );
	wire process_data_en;
	assign process_data_en = (txwrite_tx & fct_counter_p)?1'b1:1'b0;
always@(posedge pclk_tx or negedge enable_tx)
begin
	if(!enable_tx)
	begin
		process_data   <= 1'b0;
		process_data_0 <= 1'b0;
		tcode_rdy_trnsp <= 1'b0;
		tx_data_in      <= 9'd0;
		tx_data_in_0    <= 9'd0;
		tx_tcode_in     <= 8'd0;
	end
	else if(send_null_tx)
	begin
		if(tickin_tx)
		begin
			tx_tcode_in    <= timecode_tx_i;
			tcode_rdy_trnsp <= 1'b1;
		end
		else
		begin
			tx_tcode_in    <= tx_tcode_in;
			tcode_rdy_trnsp <= 1'b0;
		end
		if(!txwrite_tx)
		begin
			process_data   <= 1'b0;	
			process_data_0 <= 1'b0;	
		end
		else if(get_data && process_data_en)
		begin
			tx_data_in     <= data_tx_i;
			process_data   <= 1'b1;	
			process_data_0 <= 1'b0;		
		end
		else if(get_data_0 && process_data_en)
		begin
			tx_data_in_0   <= data_tx_i;
			process_data   <= 1'b0;	
			process_data_0 <= 1'b1;
		end
		else
		begin
			tx_data_in_0   <= tx_data_in_0;
			tx_data_in     <= tx_data_in;
			process_data   <= process_data;	
			process_data_0 <= process_data_0;
		end
	end
end
endmodule
