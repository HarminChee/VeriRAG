`define ITERATE
`define RADIAN_16
 `define ROTATE
module rotator ( clk,
 rst,
 init,
 iteration,
 tangle,
 x_i,
 y_i,
 z_i,
 x_o,
 y_o,
 z_o);
input clk;
input rst;
input init;
input [4-1:0] iteration;
input [16:0] tangle;
input  [16:0]    x_i;
input  [16:0]    y_i;
input  [16:0] z_i;
output [16:0]    x_o;
output [16:0]    y_o;
output [16:0] z_o;
  reg [16:0] x_1;
  reg [16:0] y_1;
  reg [16:0] z_1;
  wire [16:0] x_i_shifted;
  wire [16:0] y_i_shifted;
  signed_shifter x_shifter(iteration,x_i,x_i_shifted);
  signed_shifter y_shifter(iteration,y_i,y_i_shifted);
  always @ (posedge clk)
    if (rst) begin
      x_1 <= 0;
      y_1 <= 0;
      z_1 <= 0;
    end else begin
      if (init) begin
        x_1 <= x_i;
        y_1 <= y_i;
        z_1 <= z_i;
      end else if (
      z_i < 0
      ) begin
        x_1 <= x_i + y_i_shifted; 
        y_1 <= y_i - x_i_shifted; 
        z_1 <= z_i + tangle;
      end else begin
        x_1 <= x_i - y_i_shifted; 
        y_1 <= y_i + x_i_shifted; 
        z_1 <= z_i - tangle;
      end
    end
  assign x_o = x_1;
  assign y_o = y_1;
  assign z_o = z_1;
endmodule
module cordic ( clk,
 rst,
 init,
 x_i,
 y_i,
 theta_i,
 x_o,
 y_o,
 theta_o);
input clk;
input rst;
input init;
input [16:0]    x_i;
input [16:0]    y_i;
input [16:0] theta_i;
output [16:0]    x_o;
output [16:0]    y_o;
output [16:0] theta_o;
wire [16:0] tanangle_values_0;
wire [16:0] tanangle_values_1;
wire [16:0] tanangle_values_2;
wire [16:0] tanangle_values_3;
wire [16:0] tanangle_values_4;
wire [16:0] tanangle_values_5;
wire [16:0] tanangle_values_6;
wire [16:0] tanangle_values_7;
wire [16:0] tanangle_values_8;
wire [16:0] tanangle_values_9;
wire [16:0] tanangle_values_10;
wire [16:0] tanangle_values_11;
wire [16:0] tanangle_values_12;
wire [16:0] tanangle_values_13;
wire [16:0] tanangle_values_14;
wire [16:0] tanangle_values_15;
reg [16:0] tanangle_of_iteration;
assign tanangle_values_0 = 17'd25735 ;   
assign tanangle_values_1 = 17'd15192;    
assign tanangle_values_2 = 17'd8027;     
assign tanangle_values_3 = 17'd4075;     
assign tanangle_values_4 = 17'd2045;     
assign tanangle_values_5 = 17'd1024;     
assign tanangle_values_6 = 17'd512;      
assign tanangle_values_7 = 17'd256;      
assign tanangle_values_8 = 17'd128;      
assign tanangle_values_9 = 17'd64;       
assign tanangle_values_10 = 17'd32;      
assign tanangle_values_11 = 17'd16;      
assign tanangle_values_12 = 17'd8;       
assign tanangle_values_13 = 17'd4;       
assign tanangle_values_14 = 17'd2;       
assign tanangle_values_15 = 17'd1;       
  reg [4:0] iteration;
  always @ (iteration or tanangle_values_0 or tanangle_values_1 or tanangle_values_2 or tanangle_values_3 or tanangle_values_4 or tanangle_values_5 or tanangle_values_6 or tanangle_values_7 or tanangle_values_8 or tanangle_values_9 or tanangle_values_10 or tanangle_values_11 or tanangle_values_12 or tanangle_values_13 or tanangle_values_14 or tanangle_values_15) begin
    case (iteration) 
		'd0:tanangle_of_iteration = tanangle_values_0; 
		'd1:tanangle_of_iteration = tanangle_values_1; 
		'd2:tanangle_of_iteration = tanangle_values_2; 
		'd3:tanangle_of_iteration = tanangle_values_3; 
		'd4:tanangle_of_iteration = tanangle_values_4; 
		'd5:tanangle_of_iteration = tanangle_values_5; 
		'd6:tanangle_of_iteration = tanangle_values_6; 
		'd7:tanangle_of_iteration = tanangle_values_7; 
		'd8:tanangle_of_iteration = tanangle_values_8; 
		'd9:tanangle_of_iteration = tanangle_values_9; 
		'd10:tanangle_of_iteration = tanangle_values_10; 
		'd11:tanangle_of_iteration = tanangle_values_11; 
		'd12:tanangle_of_iteration = tanangle_values_12; 
		'd13:tanangle_of_iteration = tanangle_values_13; 
		'd14:tanangle_of_iteration = tanangle_values_14; 
		default:tanangle_of_iteration = tanangle_values_15; 
	endcase
  end
  wire [16:0] x,y,z;
  assign x = init ? x_i : x_o;
  assign y = init ? y_i : y_o;
  assign z = init ? theta_i : theta_o;
  always @ (posedge clk or posedge init)
    if (init) iteration <= 0;
    else iteration <= iteration + 1;
  rotator U (clk,rst,init,iteration,tanangle_of_iteration,x,y,z,x_o,y_o,theta_o);
endmodule
`define ITERATE
`define RADIAN_16
 `define ROTATE
module signed_shifter ( i,
 D,
 Q);
input [4-1:0] i;
input [16:0] D;
output [16:0] Q;
reg    [16:0] Q;
  always @ (D or i) begin
    case (i)
      0: begin
        Q[16-0:0] = D[16: 0];
      end
      1: begin
        Q[16-1:0] = D[16: 1];
        Q[16:16-1+1] = 1'b0;
      end
      2: begin
        Q[16-2:0] = D[16: 2];
        Q[16:16-2+1] = 2'b0;
      end
      3: begin
        Q[16-3:0] = D[16: 3];
        Q[16:16-3+1] = 3'b0;
      end
      4: begin
        Q[16-4:0] = D[16: 4];
        Q[16:16-4+1] = 4'b0;
      end
      5: begin
        Q[16-5:0] = D[16: 5];
        Q[16:16-5+1] = 5'b0;
      end
      6: begin
        Q[16-6:0] = D[16: 6];
        Q[16:16-6+1] = 6'b0;
      end
      7: begin
        Q[16-7:0] = D[16: 7];
        Q[16:16-7+1] = 7'b0;
      end
      8: begin
        Q[16-8:0] = D[16: 8];
        Q[16:16-8+1] = 8'b0;
      end
      9: begin
        Q[16-9:0] = D[16: 9];
        Q[16:16-9+1] = 9'b0;
      end
      10: begin
        Q[16-10:0] = D[16:10];
        Q[16:16-10+1] = 10'b0;
      end
      11: begin
        Q[16-11:0] = D[16:11];
        Q[16:16-11+1] = 11'b0;
      end
      12: begin
        Q[16-12:0] = D[16:12];
        Q[16:16-12+1] = 12'b0;
      end
      13: begin
        Q[16-13:0] = D[16:13];
        Q[16:16-13+1] = 13'b0;
      end
      14: begin
        Q[16-14:0] = D[16:14];
        Q[16:16-14+1] = 14'b0;
      end
      15: begin
        Q[16-15:0] = D[16:15];
        Q[16:16-15+1] = 15'b0;
      end
    endcase
  end
endmodule
module rotator ( clk,
 rst,
 init,
 iteration,
 tangle,
 x_i,
 y_i,
 z_i,
 x_o,
 y_o,
 z_o);
input clk;
input rst;
input init;
input [4-1:0] iteration;
input [16:0] tangle;
input  [16:0]    x_i;
input  [16:0]    y_i;
input  [16:0] z_i;
output [16:0]    x_o;
output [16:0]    y_o;
output [16:0] z_o;
  reg [16:0] x_1;
  reg [16:0] y_1;
  reg [16:0] z_1;
  wire [16:0] x_i_shifted;
  wire [16:0] y_i_shifted;
  signed_shifter x_shifter(iteration,x_i,x_i_shifted);
  signed_shifter y_shifter(iteration,y_i,y_i_shifted);
  always @ (posedge clk)
    if (rst) begin
      x_1 <= 0;
      y_1 <= 0;
      z_1 <= 0;
    end else begin
      if (init) begin
        x_1 <= x_i;
        y_1 <= y_i;
        z_1 <= z_i;
      end else if (
      z_i < 0
      ) begin
        x_1 <= x_i + y_i_shifted; 
        y_1 <= y_i - x_i_shifted; 
        z_1 <= z_i + tangle;
      end else begin
        x_1 <= x_i - y_i_shifted; 
        y_1 <= y_i + x_i_shifted; 
        z_1 <= z_i - tangle;
      end
    end
  assign x_o = x_1;
  assign y_o = y_1;
  assign z_o = z_1;
endmodule
module cordic ( clk,
 rst,
 init,
 x_i,
 y_i,
 theta_i,
 x_o,
 y_o,
 theta_o);
input clk;
input rst;
input init;
input [16:0]    x_i;
input [16:0]    y_i;
input [16:0] theta_i;
output [16:0]    x_o;
output [16:0]    y_o;
output [16:0] theta_o;
wire [16:0] tanangle_values_0;
wire [16:0] tanangle_values_1;
wire [16:0] tanangle_values_2;
wire [16:0] tanangle_values_3;
wire [16:0] tanangle_values_4;
wire [16:0] tanangle_values_5;
wire [16:0] tanangle_values_6;
wire [16:0] tanangle_values_7;
wire [16:0] tanangle_values_8;
wire [16:0] tanangle_values_9;
wire [16:0] tanangle_values_10;
wire [16:0] tanangle_values_11;
wire [16:0] tanangle_values_12;
wire [16:0] tanangle_values_13;
wire [16:0] tanangle_values_14;
wire [16:0] tanangle_values_15;
reg [16:0] tanangle_of_iteration;
assign tanangle_values_0 = 17'd25735 ;   
assign tanangle_values_1 = 17'd15192;    
assign tanangle_values_2 = 17'd8027;     
assign tanangle_values_3 = 17'd4075;     
assign tanangle_values_4 = 17'd2045;     
assign tanangle_values_5 = 17'd1024;     
assign tanangle_values_6 = 17'd512;      
assign tanangle_values_7 = 17'd256;      
assign tanangle_values_8 = 17'd128;      
assign tanangle_values_9 = 17'd64;       
assign tanangle_values_10 = 17'd32;      
assign tanangle_values_11 = 17'd16;      
assign tanangle_values_12 = 17'd8;       
assign tanangle_values_13 = 17'd4;       
assign tanangle_values_14 = 17'd2;       
assign tanangle_values_15 = 17'd1;       
  reg [4:0] iteration;
  always @ (iteration or tanangle_values_0 or tanangle_values_1 or tanangle_values_2 or tanangle_values_3 or tanangle_values_4 or tanangle_values_5 or tanangle_values_6 or tanangle_values_7 or tanangle_values_8 or tanangle_values_9 or tanangle_values_10 or tanangle_values_11 or tanangle_values_12 or tanangle_values_13 or tanangle_values_14 or tanangle_values_15) begin
    case (iteration) 
		'd0:tanangle_of_iteration = tanangle_values_0; 
		'd1:tanangle_of_iteration = tanangle_values_1; 
		'd2:tanangle_of_iteration = tanangle_values_2; 
		'd3:tanangle_of_iteration = tanangle_values_3; 
		'd4:tanangle_of_iteration = tanangle_values_4; 
		'd5:tanangle_of_iteration = tanangle_values_5; 
		'd6:tanangle_of_iteration = tanangle_values_6; 
		'd7:tanangle_of_iteration = tanangle_values_7; 
		'd8:tanangle_of_iteration = tanangle_values_8; 
		'd9:tanangle_of_iteration = tanangle_values_9; 
		'd10:tanangle_of_iteration = tanangle_values_10; 
		'd11:tanangle_of_iteration = tanangle_values_11; 
		'd12:tanangle_of_iteration = tanangle_values_12; 
		'd13:tanangle_of_iteration = tanangle_values_13; 
		'd14:tanangle_of_iteration = tanangle_values_14; 
		default:tanangle_of_iteration = tanangle_values_15; 
	endcase
  end
  wire [16:0] x,y,z;
  assign x = init ? x_i : x_o;
  assign y = init ? y_i : y_o;
  assign z = init ? theta_i : theta_o;
  always @ (posedge clk or posedge init)
    if (init) iteration <= 0;
    else iteration <= iteration + 1;
  rotator U (clk,rst,init,iteration,tanangle_of_iteration,x,y,z,x_o,y_o,theta_o);
endmodule
