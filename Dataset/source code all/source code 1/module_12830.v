module sr_04(echo,clk,rst_n,distance_reg);
input echo,clk,rst_n;
output distance_reg;
reg[9:0]distance_reg,cnt;
wire start,finish;
reg echo_reg1,echo_reg2;
parameter idle=2'b00;
parameter state1=2'b01;
parameter state2=2'b10;
reg [1:0]state;
assign start=echo_reg1&~echo_reg2;   
assign finish=~echo_reg1&echo_reg2; 
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin echo_reg1<=0;echo_reg2<=0;end
        else begin echo_reg1<=echo;echo_reg2<=echo_reg1;end
   if(!rst_n)begin state<=idle;cnt<=0;end
     else begin
               case(state)
               idle: begin
                     if(start)begin state<=state1;end
                     else begin state<=idle;end
                     end
              state1:begin
                     if(finish)begin state<=state2;end
                     else begin cnt<=cnt+1'b1;state<=state1;end
                     end
              state2:begin
                     cnt<=0;
                     distance_reg<=cnt;
                     state<=idle;
                     end
             default: state<=idle;
             endcase
          end
end
endmodule
