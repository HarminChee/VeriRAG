`timescale 1ns / 1ps
`timescale 1ns / 1ps
module mem(
	clk_i,
	mem_cyc_i,
	mem_stb_i,
	mem_we_i,       
	mem_ack_o,   
	mem_adr_i,    
	mem_dat_i,   
	mem_dat_o,   
	readorg   
    );
input  clk_i;
input  readorg;
input  mem_cyc_i;
input  mem_stb_i;
input  mem_we_i;
output reg mem_ack_o = 1'b0;
input[21:0]   mem_adr_i;
input[31:0]   mem_dat_i ;
output[31:0]    mem_dat_o;               
wire            mem_stb_i;
reg [31:0] mem_dat_o=0;
reg mem_en_1;  
reg D_mem_en_1;
wire [31:0] dat_out_mem_1;   
wire [31:0] dat_out_D_mem_1;
blk_mem_gen_0 mem_1 (
  .clka(clk_i),    
  .ena(mem_en_1),      
  .wea(mem_we_i),      
  .addra(mem_adr_i[21:2]),  
  .dina(mem_dat_i),    
  .douta(dat_out_mem_1)  
);
blk_mem_gen_0 D_mem_1 (
  .clka(clk_i),    
  .ena(D_mem_en_1),      
  .wea(mem_we_i),      
  .addra(mem_adr_i[21:2]),  
  .dina(mem_dat_i),    
  .douta(dat_out_D_mem_1)  
);
always @(posedge clk_i) begin
    if(mem_cyc_i && mem_stb_i) begin
        if (!mem_we_i) begin    
            if (readorg) begin     
                    mem_en_1 <= 0;
                    D_mem_en_1 <=1;		     
				    mem_dat_o <= dat_out_D_mem_1;
				    mem_ack_o = 1'b1;
			end        
			else begin       
                    mem_en_1 <= 1;
                    D_mem_en_1 <=0;	     
                    mem_dat_o <= dat_out_mem_1;
                    mem_ack_o = 1'b1;
			end
		end  
		else if(mem_we_i) begin   
            if (readorg) begin    
                    mem_en_1 <= 1;
                    D_mem_en_1 <=0;              
                    mem_ack_o = 1'b1; 
			end      
			else begin      
                    mem_en_1 <= 0;
                    D_mem_en_1 <=1;                
                    mem_ack_o = 1'b1;
		    end
	    end
	    else begin
		   mem_ack_o = 1'b0;
		end
    end
    else begin
         mem_ack_o = 1'b0;
    end
end
endmodule
