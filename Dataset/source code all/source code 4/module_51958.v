module syncfifo
  #(
    parameter AW = 5,
    parameter DW = 16
    )
   (
    input                clk,
    input                reset,
    input [DW-1:0]       wdata,
    input                wen,
    input                ren,
    output wire [DW-1:0] rdata,
    output reg           empty,
    output reg           full
    );
   reg [AW-1:0]          waddr;
   reg [AW-1:0]          raddr;
   reg [AW-1:0]          count;
   always @ ( posedge clk ) begin
      if( reset ) begin
         waddr <= 'd0;
         raddr <= 'd0;
         count <= 'd0;
         empty <= 1'b1;
         full  <= 1'b0;
      end else begin
         if( wen & ren ) begin
            waddr <= waddr + 'd1;
            raddr <= raddr + 'd1;
         end else if( wen ) begin
            waddr <= waddr + 'd1;
            count <= count + 'd1;
            empty <= 1'b0;
            if( & count )
              full <= 1'b1;
         end else if( ren ) begin
            raddr <= raddr + 'd1;
            count <= count - 'd1;
            full <= 1'b0;
            if( count == 'd1 )
              empty <= 1'b1;
         end
      end 
   end 
   genvar               dn;
   generate for(dn=0; dn<DW; dn=dn+1)
     begin : genbits
        RAM32X1D RAM32X1D_inst
          (
           .DPO(rdata[dn] ),   
           .SPO(),            
           .A0(waddr[0]),     
           .A1(waddr[1]),     
           .A2(waddr[2]),     
           .A3(waddr[3]),     
           .A4(waddr[4]),     
           .D(wdata[dn]),     
           .DPRA0(raddr[0]),  
           .DPRA1(raddr[1]),  
           .DPRA2(raddr[2]),  
           .DPRA3(raddr[3]),  
           .DPRA4(raddr[4]),  
           .WCLK(clk),        
           .WE(wen)           
           );
     end
   endgenerate
endmodule 
