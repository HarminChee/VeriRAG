module matrix_arb (request, grant, success, clk, rst_n);
   parameter size= 4;
   parameter multistage = 0;
   parameter grant_hold = 0;
   parameter priority_support = 0;
   input [size-1:0] request;
   output [size-1:0] grant;
   input success;
   input clk, rst_n; 
   genvar i,j;
   logic [size-1:0] req;
   logic [size-1:0] newgrant;
   logic [size*size-1:0] next_state, current_state;
   logic [size-1:0] pri [size-1:0];
   logic [size*size-1:0] new_state;
   logic [size*size-1:0] state;
   logic  update;
   genvar r;
   integer k;
   assign req = request;
   generate
   for (i=0; i<size; i=i+1) begin:ol1
      for (j=0; j<size; j=j+1) begin:il1
         if (j==i) 
           assign pri[i][j]=req[i];
         else 
           if (j>i)
             assign pri[i][j]=!(req[j]&&state[j*size+i]);
           else
             assign pri[i][j]=!(req[j]&&!state[i*size+j]);
      end
      assign grant[i]=&pri[i];
   end
   endgenerate
   generate
   if (multistage==2) begin
      assign state = success ? next_state : current_state;
   end else begin
      assign state = current_state;
   end
   endgenerate
   comb_matrix_arb_next_state #(size) calc_next (.*);
   always@(posedge clk) begin
     if (!rst_n) begin
        current_state<='1; 
	next_state<='1; 
     end else begin
	if (multistage==2) begin
	   update<=|req;
	   if (|req) begin
	      next_state <= new_state;
	   end
	   if (update) begin
	      current_state <= state;
	   end
	end else begin
	   if ((multistage==1)&!success) begin
	   end else begin
              if (|req) begin
		 current_state<=new_state;
              end
	   end
	end 
     end
   end
endmodule
module comb_matrix_arb_next_state (state, grant, new_state);
   parameter size=4;
   input [size*size-1:0] state;
   input [size-1:0] grant;
   output [size*size-1:0] new_state;
   genvar i,j;
   generate
   for (i=0; i<size; i=i+1) begin:ol2
      for (j=0; j<size; j=j+1) begin:il2
         assign new_state[j*size+i]= (state[j*size+i]&&!grant[j])||(grant[i]);
      end
   end
   endgenerate
endmodule 
module matrix_arb (request, grant, success, clk, rst_n);
   parameter size= 4;
   parameter multistage = 0;
   parameter grant_hold = 0;
   parameter priority_support = 0;
   input [size-1:0] request;
   output [size-1:0] grant;
   input success;
   input clk, rst_n; 
   genvar i,j;
   logic [size-1:0] req;
   logic [size-1:0] newgrant;
   logic [size*size-1:0] next_state, current_state;
   logic [size-1:0] pri [size-1:0];
   logic [size*size-1:0] new_state;
   logic [size*size-1:0] state;
   logic  update;
   genvar r;
   integer k;
   assign req = request;
   generate
   for (i=0; i<size; i=i+1) begin:ol1
      for (j=0; j<size; j=j+1) begin:il1
         if (j==i) 
           assign pri[i][j]=req[i];
         else 
           if (j>i)
             assign pri[i][j]=!(req[j]&&state[j*size+i]);
           else
             assign pri[i][j]=!(req[j]&&!state[i*size+j]);
      end
      assign grant[i]=&pri[i];
   end
   endgenerate
   generate
   if (multistage==2) begin
      assign state = success ? next_state : current_state;
   end else begin
      assign state = current_state;
   end
   endgenerate
   comb_matrix_arb_next_state #(size) calc_next (.*);
   always@(posedge clk) begin
     if (!rst_n) begin
        current_state<='1; 
	next_state<='1; 
     end else begin
	if (multistage==2) begin
	   update<=|req;
	   if (|req) begin
	      next_state <= new_state;
	   end
	   if (update) begin
	      current_state <= state;
	   end
	end else begin
	   if ((multistage==1)&!success) begin
	   end else begin
              if (|req) begin
		 current_state<=new_state;
              end
	   end
	end 
     end
   end
endmodule
