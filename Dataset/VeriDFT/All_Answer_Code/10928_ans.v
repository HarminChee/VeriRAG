module ALU(test_i,scan_diff,opcode,funct,in1,in2,result,rw,clk);
input clk,test_i;
input [31:0] scan_diff;
input [5:0] opcode, funct;
input [31:0] in1, in2;
output [31:0] result; 
reg [31:0] result;
output rw;
reg rw;  	
wire [31:0] sum, diff, product, sum_or,dft_diff;
thirtytwobitadder ADD(in1,in2,carryout,sum,1'b0);
thirtytwobitsubtractor SUBTRACT(in1,in2,carry,diff,1'b0);
AND prod(in1,in2,product);
OR orop(in1,in2,sum_or);
assign dft_diff =test_i ? scan_diff : diff ;
always @(test_i or dft_diff or opcode or funct or in1 or in2  or rw or clk)
begin

        if(opcode==6'b000000)
        begin
                if(funct==6'b100000) 
                begin
                        rw=1'b0;
                        result=sum;
                        rw=1'b1;
                end
                if(funct==6'b100010) 
                begin
                        rw=1'b0;
                        result=dft_diff;
                        rw=1'b1;
                end
                if(funct==6'b100100) 
                begin
                        rw=1'b0;
                        result=product;
                        rw=1'b1;
                end
                if(funct==6'b100101)
                begin
                        rw=1'b0;
                        result=sum_or;
                        rw=1'b1;
                end
        end
        if(opcode==6'b100011)
        begin
        rw=1'b0;
        result=sum;
        rw=1'b1;
        end
        if(opcode==6'b101011)
        begin
        rw=1'b0;
        result=sum;
        end
        if(opcode==6'b000100)
        begin
        rw=1'b0;
                if(diff==32'b00000000000000000000000000000000)
                begin
                result=dft_diff;
                end
        end
end
endmodule
