module alu (a_input, b_input, funct, res, z);
	input  [31:0] a_input;
	input  [31:0] b_input;
	input  [4:0]  funct;
	output [31:0] res;
	output        z;
	reg    [31:0] res = 0;
	reg			  z = 0;
	reg	   [31:0] hi = 0;
	reg    [31:0] lo = 0;
	always @(a_input or b_input or funct)
	begin
        if (funct == 'b00000)
        begin
			res = a_input << b_input;
			z = 0;
			$display("%d = %d << %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00001)
        begin
            res = a_input >> b_input;
			z = 0;
			$display("%d = %d >> %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00010)
        begin
           res = $signed(a_input) >>> $signed(b_input);
		   z = 0;
		   $display("%d = %d >>> %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00011)
        begin
           res = hi;
		   z = 0;
		   $display("HI = %d", res);
        end
        else if (funct == 'b00100)
        begin
			res = lo;
			z = 0;
			$display("LO = %d", res);
        end
        else if (funct == 'b00101)
        begin
            res = ($signed(a_input) * $signed(b_input));
			z = 0;
			$display("%d = %d * %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00110)
        begin
			lo = ($signed(a_input) / $signed(b_input));
			hi = ($signed(a_input) % $signed(b_input));
			$display("%d = %d / %d", $signed(lo), $signed(a_input), $signed(b_input));
            z = 0;
        end
        else if (funct == 'b00111)
        begin
			hi = ($unsigned(a_input) / $unsigned(b_input));
			lo = ($unsigned(a_input) % $unsigned(b_input));
            z = 0;
        end
        else if (funct == 'b01000)
        begin
            res = $signed(a_input) + $signed(b_input);
			z = 0;
			$display("%d = %d + %d", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b01001)
        begin
            res = a_input + b_input;
			z = 0;
			$display("%d = u%d + u%d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01010)
        begin
            res = $signed(a_input) - $signed(b_input);
			z = 0;
			$display("%d = %d - %d", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b01011)
        begin
            res = a_input - b_input;
			z = 0;
			$display("%d = u%d - u%d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01100)
        begin
            res = a_input & b_input;
			z = 0;
			$display("%d = %d & %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01101)
        begin
            res = a_input | b_input;
			z = 0;
			$display("%d = %d | %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01110)
        begin
            res = a_input ^ b_input;
			z = 0;
			$display("%d = %d ^ %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01111)
        begin
            res = ~(a_input | b_input);
			z = 0;
			$display("%d = ~(%d | %d)", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b10000)
        begin
            res = $signed(a_input) < $signed(b_input) ? 1 : 0;
			z = 0;
			$display("%d = (%d < %d)", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10001)
        begin
            res = a_input < b_input ? 1 : 0;
			z = 0;
			$display("%d = u%d < u%d", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10010)
        begin
            res = b_input << 16;
			z = 0;
			$display("%d = %d << 16", $signed(res), $signed(b_input));
        end
		else if (funct == 'b10011)
        begin
            z = a_input == b_input ? 1 : 0;
			res = 0;
			$display("%d = %d == %d", z, $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10100)
        begin
            z = $signed(a_input) < $signed(b_input) ? 1 : 0;
			res = 0;
			$display("%d = %d < %d", z, $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10101)
        begin
            z = a_input != b_input ? 1 : 0;
			res = 0;
			$display("%d = %d != %d", z, $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10110)
        begin
            z = $signed(a_input) <= $signed(b_input) ? 1 : 0;
			res = 0;
			$display("%d = %d <= %d", z, $signed(a_input), $signed(b_input));
        end
	end
endmodule
