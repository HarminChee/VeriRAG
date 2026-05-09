module cordic_mult_core
    #(parameter N=16)           
    (input clk,                 
     input rst,                 
     input [N-1:0]a,            
     input [N-1:0]b,            
     input start,               
     output reg [N-1:0]c,       
     output reg rdy);           
reg [N:0]x;         
reg [N-1:0]y;       
reg [N-1:0]z;       
reg [N-1:0]subs;    
reg finish;         
always @(posedge clk, posedge rst)
    if(rst)
        begin
          x<=0;
          y<=0;
          z<=0; 
          subs[N-1]<=0;
          subs[N-2:0]<=0;
          c<=0;
          rdy <=0;
          finish <=0;
        end else
            begin
                if(start)
                    begin
                      x<={a[N-1],a};        
                      y<=b;                 
                      z<=0;                 
                      subs[N-1]<=1;        
                      subs[N-2:0]<=0;
                      finish <= 0;
                    end else
                    if(x[N])                        
                    begin
                        x <= x + {1'b0,subs};       
                        y <= {y[N-1],y[N-1:1]};     
                        z <= z - y;                 
                        {subs,finish} <= {1'b0,subs[N-1:0]};   
                    end else
                    begin                           
                        x <= x - {1'b0,subs};       
                        y <= {y[N-1],y[N-1:1]};     
                        z <= z + y;                 
                        {subs,finish} <= {1'b0,subs[N-1:0]};   
                    end
                    if(finish)                      
                        begin                      
                           rdy<=1;                  
                           c <= z;                  
                           finish <= 0;
                        end else
                            rdy<=0;   
            end
endmodule
