module hazard_detect(instruction1, instruction2, instruction3, 
		hz1_a_or_d, hz1_b,  hz3_a_or_d, hz3_b);
	input [0:31] instruction1, instruction2, instruction3;
	output hz1_a_or_d, hz1_b,  hz3_a_or_d, hz3_b;
	reg hz1_a_or_d, hz1_b,  hz3_a_or_d, hz3_b;
	parameter zero = 1'b0;
	parameter one = 1'b1;
	always @ (instruction1 or instruction3)
		begin
		if (instruction1[2] == 1'b1) 
			begin
				if (instruction3[2] == 1'b1) 
					begin
						hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
						hz1_b<=zero;
					end 
				else if (instruction3[3] == 1'b1) 
					begin
					if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
							hz1_b<=zero;
						end
					else if (instruction3[26:31]==6'b001000) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
							hz1_b<=zero;
						end
					else 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
							hz1_b<=zero;
						end
					end 
				else if (instruction3[4]==1'b1) 
					begin
						hz1_a_or_d <= zero;
						hz1_b<=zero;
					end 
				else if (instruction3[5]==1'b1) 
					begin
						hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
						hz1_b<=zero;
					end 
				else 
					begin
						hz1_a_or_d <= zero;
						hz1_b<=zero;
					end 
			end 
		else if (instruction1[3] == 1'b1) 
			begin
			if ({instruction1[26:28], instruction1[31]} == 4'b0101) 
				begin
					if (instruction3[2] == 1'b1) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
							hz1_b<=zero;
						end 
					else if (instruction3[3] == 1'b1) 
						begin
						if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
								hz1_b<=zero;
							end
						else if (instruction3[26:31]==6'b001000) 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
								hz1_b<=zero;
							end
						else 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
								hz1_b<=zero;
							end
						end 
					else if (instruction3[4]==1'b1) 
						begin
							hz1_a_or_d <= zero;
							hz1_b<=zero;
						end 
					else if (instruction3[5]==1'b1) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
							hz1_b<=zero;
						end 
					else 
						begin
							hz1_a_or_d <= zero;
							hz1_b<=zero;
						end 
				end
			else if (instruction1[26:31]==6'b001000) 
				begin
					if (instruction3[2] == 1'b1) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
							hz1_b<=zero;
						end 
					else if (instruction3[3] == 1'b1) 
						begin
						if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
								hz1_b<=zero;
							end
						else if (instruction3[26:31]==6'b001000) 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
								hz1_b<=zero;
							end
						else 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
								hz1_b<=zero;
							end
						end 
					else if (instruction3[4]==1'b1) 
						begin
							hz1_a_or_d <= zero;
							hz1_b<=zero;
						end 
					else if (instruction3[5]==1'b1) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero;
							hz1_b<=zero;
						end 
					else 
						begin
							hz1_a_or_d <= zero;
							hz1_b<=zero;
						end 
				end
			else 
				begin
					if (instruction3[2] == 1'b1) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero; 
							hz1_b <= (instruction1[16:20]==instruction3[6:10])? one : zero;
						end 
					else if (instruction3[3] == 1'b1) 
						begin
						if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero; 
								hz1_b <= (instruction1[16:20]==instruction3[6:10])? one : zero;
							end
						else if (instruction3[26:31]==6'b001000) 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero; 
								hz1_b <= (instruction1[16:20]==instruction3[6:10])? one : zero;
							end
						else 
							begin
								hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero; 
								hz1_b <= (instruction1[16:20]==instruction3[6:10])? one : zero;
							end
						end 
					else if (instruction3[4]==1'b1) 
						begin
							hz1_a_or_d <= zero;
							hz1_b <= zero;
						end 
					else if (instruction3[5]==1'b1) 
						begin
							hz1_a_or_d <= (instruction1[11:15]==instruction3[6:10])? one : zero; 
							hz1_b <= (instruction1[16:20]==instruction3[6:10])? one : zero;
						end 
					else 
						begin
							hz1_a_or_d <= zero;
							hz1_b <= zero;
						end 
				end
			end 
		else if (instruction1[4]==1'b1) 
			begin
				if (instruction3[2] == 1'b1) 
					begin
						hz1_a_or_d <= (instruction1[6:10]==instruction3[6:10])? one : zero;
						hz1_b <= zero;
					end 
				else if (instruction3[3] == 1'b1) 
					begin
					if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
						begin
							hz1_a_or_d <= (instruction1[6:10]==instruction3[6:10])? one : zero;
							hz1_b <= zero;
						end
					else if (instruction3[26:31]==6'b001000) 
						begin
							hz1_a_or_d <= (instruction1[6:10]==instruction3[6:10])? one : zero;
							hz1_b <= zero;
						end
					else 
						begin
							hz1_a_or_d <= (instruction1[6:10]==instruction3[6:10])? one : zero;
							hz1_b <= zero;
						end
					end 
				else if (instruction3[4]==1'b1) 
					begin
						hz1_a_or_d <= zero;
						hz1_b <= zero;
					end 
				else if (instruction3[5]==1'b1) 
					begin
						hz1_a_or_d <= (instruction1[6:10]==instruction3[6:10])? one : zero;
						hz1_b <= zero;
					end 
				else 
					begin
						hz1_a_or_d <= zero;
						hz1_b <= zero;
					end 
			end 
		else if (instruction1[5]==1'b1) 
			begin
				hz1_a_or_d <= zero;
				hz1_b <= zero;
			end 
		else 
			begin
				hz1_a_or_d <= zero;
				hz1_b <= zero;
			end 
		end 
	always @ (instruction2 or instruction3)
		begin
		if (instruction2[2] == 1'b1) 
			begin
				if (instruction3[2] == 1'b1) 
					begin
						hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
						hz3_b <= zero;
					end 
				else if (instruction3[3] == 1'b1) 
					begin
					if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end
					else if (instruction3[26:31]==6'b001000) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end
					else 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end
					end 
				else if (instruction3[4]==1'b1) 
					begin
						hz3_a_or_d <= zero;
						hz3_b <= zero;
					end 
				else if (instruction3[5]==1'b1) 
					begin
						hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
						hz3_b <= zero;
					end 
				else 
					begin
						hz3_a_or_d <= zero;
						hz3_b <= zero;
					end 
			end 
		else if (instruction2[3] == 1'b1) 
			begin
			if ({instruction2[26:28], instruction2[31]} == 4'b0101) 
				begin
					if (instruction3[2] == 1'b1) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end 
					else if (instruction3[3] == 1'b1) 
						begin
						if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= zero;
							end
						else if (instruction3[26:31]==6'b001000) 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= zero;
							end
						else 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= zero;
							end
						end 
					else if (instruction3[4]==1'b1) 
						begin
							hz3_a_or_d <= zero;
							hz3_b <= zero;
						end 
					else if (instruction3[5]==1'b1) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end 
					else 
						begin
							hz3_a_or_d <= zero;
							hz3_b <= zero;
						end 
				end
			else if (instruction2[26:31]==6'b001000) 
				begin
					if (instruction3[2] == 1'b1) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end 
					else if (instruction3[3] == 1'b1) 
						begin
						if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= zero;
							end
						else if (instruction3[26:31]==6'b001000) 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= zero;
							end
						else 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= zero;
							end
						end 
					else if (instruction3[4]==1'b1) 
						begin
							hz3_a_or_d <= zero;
							hz3_b <= zero;
						end 
					else if (instruction3[5]==1'b1) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end 
					else 
						begin
							hz3_a_or_d <= zero;
							hz3_b <= zero;
						end 
				end
			else 
				begin
					if (instruction3[2] == 1'b1) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= (instruction2[16:20]==instruction3[6:10])? one : zero;
						end 
					else if (instruction3[3] == 1'b1) 
						begin
						if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= (instruction2[16:20]==instruction3[6:10])? one : zero;
							end
						else if (instruction3[26:31]==6'b001000) 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= (instruction2[16:20]==instruction3[6:10])? one : zero;
							end
						else 
							begin
								hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
								hz3_b <= (instruction2[16:20]==instruction3[6:10])? one : zero;
							end
						end 
					else if (instruction3[4]==1'b1) 
						begin
							hz3_a_or_d <= zero;
							hz3_b <= zero;
						end 
					else if (instruction3[5]==1'b1) 
						begin
							hz3_a_or_d <= (instruction2[11:15]==instruction3[6:10])? one : zero;
							hz3_b <= (instruction2[16:20]==instruction3[6:10])? one : zero;
						end 
					else 
						begin
							hz3_a_or_d <= zero;
							hz3_b <= zero;
						end 
				end
			end 
		else if (instruction2[4]==1'b1) 
			begin
				if (instruction3[2] == 1'b1) 
					begin
						hz3_a_or_d <= (instruction2[6:10]==instruction3[6:10])? one : zero;
						hz3_b <= zero;
					end 
				else if (instruction3[3] == 1'b1) 
					begin
					if ({instruction3[26:28], instruction3[31]} == 4'b0101) 
						begin
							hz3_a_or_d <= (instruction2[6:10]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end
					else if (instruction3[26:31]==6'b001000) 
						begin
							hz3_a_or_d <= (instruction2[6:10]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end
					else 
						begin
							hz3_a_or_d <= (instruction2[6:10]==instruction3[6:10])? one : zero;
							hz3_b <= zero;
						end
					end 
				else if (instruction3[4]==1'b1) 
					begin
						hz3_a_or_d <= zero;
						hz3_b <= zero;
					end 
				else if (instruction3[5]==1'b1) 
					begin
						hz3_a_or_d <= (instruction2[6:10]==instruction3[6:10])? one : zero;
						hz3_b <= zero;
					end 
				else 
					begin
						hz3_a_or_d <= zero;
						hz3_b <= zero;
					end 
			end 
		else if (instruction2[5]==1'b1) 
			begin
				hz3_a_or_d <= zero;
				hz3_b <= zero;
			end 
		else 
			begin
				hz3_a_or_d <= zero;
				hz3_b <= zero;
			end 
		end 
endmodule
