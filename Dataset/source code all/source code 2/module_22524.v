module LAG_tree_arbiter (request, grant, success, clk, rst_n);
   parameter multistage=0;
   parameter size=20;
   parameter groupsize=4;
   parameter numgroups=size/groupsize;
   input [size-1:0] request;
   output [size-1:0] grant;
   input 	     success;
   input 	     clk, rst_n;
   logic [size-1:0] intra_group_grant;
   logic [numgroups-1:0] group_grant, any_group_request;
   logic [numgroups-1:0] current_group_success, last_group_success;
   logic [numgroups-1:0] group_success;
   genvar i;
   generate
   for (i=0; i<numgroups; i=i+1) begin:arbiters
      if (multistage==0) begin
	 matrix_arb #(.size(groupsize),
		      .multistage(1)) arb
	   (.request(request[(i+1)*groupsize-1:i*groupsize]),
	    .grant(intra_group_grant[(i+1)*groupsize-1:i*groupsize]),
	    .success(group_success[i]), 
	    .clk, .rst_n);
      end else begin
	 matrix_arb #(.size(groupsize),
		      .multistage(multistage)) arb
	   (.request(request[(i+1)*groupsize-1:i*groupsize]),
	    .grant(intra_group_grant[(i+1)*groupsize-1:i*groupsize]),
	    .success(group_success[i] & success),
	    .clk, .rst_n);
      end
      assign any_group_request[i] = |request[(i+1)*groupsize-1:i*groupsize];
      assign grant[(i+1)*groupsize-1:i*groupsize]=
      	     intra_group_grant[(i+1)*groupsize-1:i*groupsize] & {groupsize{group_grant[i]}};
      assign current_group_success[i]= group_grant[i];
   end
   if (multistage==2) begin
      always@(posedge clk) begin
	 if (!rst_n) begin
	    last_group_success<='0;
	 end else begin
	    last_group_success<=current_group_success;
	 end
      end
      assign group_success=last_group_success;
   end else begin
      assign group_success=current_group_success;
   end
   endgenerate
   matrix_arb #(.size(numgroups),
		.multistage(multistage)) group_arb 
     (.request(any_group_request),
      .grant(group_grant),
      .success(success),
      .clk, .rst_n);
endmodule 
