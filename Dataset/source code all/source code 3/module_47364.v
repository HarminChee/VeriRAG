module PISO(serial_out, out_valid, data_in, load, reset_b, clk);
	output serial_out;
	output out_valid;
	input [7:0] data_in;
	input clk;
	input reset_b;
	input load;
	reg out_valid;					
	reg serial_out;					
	reg q_dff1;						
	reg q_dff2;						
	reg q_dff3;						
	reg q_dff4;						
	reg q_dff5;						
	reg q_dff6;						
	reg q_dff7;						
	reg flag2;						
	reg flag3;						
	reg flag4;						
	reg flag5;						
	reg flag6;						
	reg flag7;						
	always @(~reset_b)
	begin
		out_valid<=1'd0;
		q_dff1<=1'd0;
		q_dff2<=1'd0;
		q_dff3<=1'd0;
		q_dff4<=1'd0;
		q_dff5<=1'd0;
		q_dff6<=1'd0;
		q_dff7<=1'd0;
		serial_out<=1'd0;
		flag2<=1'd1;
		flag3<=1'd1;
		flag4<=1'd1;
		flag5<=1'd1;
		flag6<=1'd1;
		flag7<=1'd1;
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			q_dff1<=data_in[7];	
		end
		else
		begin
			q_dff1<=1'dx;
		end
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			q_dff2<=data_in[6];
		end
		else if(out_valid)
		begin
			$display($time, ">>>>>>> Bring in value from prev dff1");
			q_dff2<=q_dff1;
		end
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			q_dff3<=data_in[5];
		end
		else if(out_valid)
		begin
			$display($time, ">>>>>>> Bring in value from prev dff2");
			q_dff3<=q_dff2;
		end
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			q_dff4<=data_in[4];
		end
		else if(out_valid)
		begin
			$display($time, ">>>>>>> Bring in value from prev dff3");
			q_dff4<=q_dff3;
		end
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			q_dff5<=data_in[3];
		end
		else if(out_valid)
		begin
			$display($time, ">>>>>>> Bring in value from prev dff4");
			q_dff5<=q_dff4;
		end
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			q_dff6<=data_in[2];
		end
		else if(out_valid)
		begin
			$display($time, ">>>>>>> Bring in value from prev dff5");
			q_dff6<=q_dff5;
		end
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			q_dff7<=data_in[1];
		end
		else if(out_valid)
		begin
			$display($time, ">>>>>>> Bring in value from prev dff6");
			$display("q_dff6:::",q_dff6);
			q_dff7<=q_dff6;
			$display("q_dff7:::",q_dff7);
		end
	end
	always @(posedge clk)
	begin
		if(load && reset_b && (~out_valid))
		begin
			serial_out<=data_in[0];
			out_valid<=1'd1;
		end
		else if((out_valid==1) && (q_dff7!==1'dz) && (q_dff7!==1'dx))
		begin
$display($time, ">>>>>>> Bring in value from prev dff7");
if((q_dff7==1'dz) || (q_dff7==1'dx))
begin
	serial_out<=1'd0;
end
else
begin
	serial_out<=q_dff7;
end
		end
		else
		begin
$display($time, "########### REady for new input");
			out_valid<=1'd0;
			serial_out<=1'd0;
		end
	end
endmodule
