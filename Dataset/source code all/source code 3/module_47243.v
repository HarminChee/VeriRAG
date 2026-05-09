module SIPO(data_out, out_valid, serial_in, in_valid, reset_b, clk);
	output [7:0] data_out;
	output out_valid;
	input serial_in;
	input clk;
	input reset_b;
	input in_valid;
	reg out_valid;					
	reg [7:0] data_out;					
	reg [7:0] q_dff;				
	reg flag1;						
	reg flag2;						
	reg flag3;						
	reg flag4;						
	reg flag5;						
	reg flag6;						
	reg flag7;						
	reg flag8;						
	always @(~reset_b)
	begin
		out_valid<=1'd0;
		data_out<=8'd0;
		q_dff<=8'd0;
		flag1<=1'd1;
		flag2<=1'd1;
		flag3<=1'd1;
		flag4<=1'd1;
		flag5<=1'd1;
		flag6<=1'd1;
		flag7<=1'd1;
		flag8<=1'd1;
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b &&  (~out_valid))
		begin
			if(flag1==1)
			begin
$display($time,"Process input #1",serial_in);
				q_dff[0]<=serial_in;
				flag1<=1'd0;
			end
		end
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b && (~out_valid))
		begin
			if((flag2==1) && (flag1==0))
			begin
$display($time,"Process input #2",serial_in);
				q_dff[1]<=serial_in;
				flag2<=1'd0;
			end
		end
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b && (~out_valid))
		begin
			if((flag3==1) && (flag2==0))
			begin
$display($time,"Process input #3",serial_in);
				q_dff[2]<=serial_in;
				flag3<=1'd0;
			end
		end
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b && (~out_valid))
		begin
			if((flag4==1) && (flag3==0))
			begin
$display($time,"Process input #4",serial_in);
				q_dff[3]<=serial_in;
				flag4<=1'd0;
			end
		end
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b && (~out_valid))
		begin
			if((flag5==1) && (flag4==0))
			begin
$display($time,"Process input #5",serial_in);
				q_dff[4]<=serial_in;
				flag5<=1'd0;
			end
		end
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b && (~out_valid))
		begin
			if((flag6==1) && (flag5==0))
			begin
$display($time,"Process input #6",serial_in);
				q_dff[5]<=serial_in;
				flag6<=1'd0;
			end
		end
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b && (~out_valid))
		begin
			if((flag7==1) && (flag6==0))
			begin
$display($time,"Process input #7",serial_in);
				q_dff[6]<=serial_in;
				flag7<=1'd0;
			end
		end
	end
	always @(posedge clk)
	begin
		if(in_valid && reset_b && (~out_valid))
		begin
			if((flag8==1) && (flag7==0))
			begin
$display($time,"Process input #8",serial_in);
				q_dff[7]<=serial_in;
				flag8<=1'd0;
				out_valid<=1'd1;
			end
		end
		else if(out_valid)
		begin
$display($time,"Produce the output and reset data",serial_in);
			data_out<=q_dff;
			flag1<=1'd1;
			flag2<=1'd1;
			flag3<=1'd1;
			flag4<=1'd1;
			flag5<=1'd1;
			flag6<=1'd1;
			flag7<=1'd1;
			flag8<=1'd1;
			out_valid<=1'd0;
			q_dff<=8'd0;
		end
	end
endmodule
