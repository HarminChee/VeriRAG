module ctu_level_mon (
 hi,
 lo,
 mon_en,
 mon_num,
 off_on
);
  input hi;   
  input lo;   
  input mon_en;   
  input [31:0] mon_num;   
  input off_on;   
always @(hi or lo) 
begin
if ( !$test$plusargs("ctu_mon_off")) begin
 if ((mon_en == 1'b1)&& (off_on != 1'b1)) begin
   $display("ERROR : Signal hi or lo toggled when it shouldnt ; hi= %h ,lo=%d \n", hi,lo);
   $display("****NOTE : IF YOUR TEST INTEND TO TOGGLE THESE SIGNALS ******\n");
   $display("****  use -sim_run_args=+ctu_mon_off  as run argument******\n");
   finish_test(" Signal toggles when not supposed to", mon_num);
 end
end
end
task finish_test;
input [512:0] message;
input [31:0]   id;
begin
  $display("%0d ERROR: CTU Monitor : %s MONITOR NUMBER : %d", $time, message,mon_num);
  $error ("ctu_mon", "CTU monitor exited") ;
end
endtask
endmodule
