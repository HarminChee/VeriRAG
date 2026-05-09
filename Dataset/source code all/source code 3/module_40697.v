module MAC_rx_add_chk (     
Reset               ,                                
Clk                 ,                                
Init                ,                                
data                ,                                
MAC_add_en          ,                                
MAC_rx_add_chk_err  ,                                
MAC_rx_add_chk_en   ,                                
MAC_add_prom_data   ,       
MAC_add_prom_add    ,       
MAC_add_prom_wr             
);
input           Reset               ;
input           Clk                 ;
input           Init                ;
input   [7:0]   data                ;
input           MAC_add_en          ;
output          MAC_rx_add_chk_err  ;
input           MAC_rx_add_chk_en   ;   
input   [7:0]   MAC_add_prom_data   ;   
input   [2:0]   MAC_add_prom_add    ;   
input           MAC_add_prom_wr     ;   
reg [2:0]   addr_rd;
wire[2:0]   addr_wr;
wire[7:0]   din;
wire[7:0]   dout;
wire        wr_en;
reg         MAC_rx_add_chk_err;
reg         MAC_add_prom_wr_dl1;
reg         MAC_add_prom_wr_dl2;
reg [7:0]   data_dl1                ;
reg         MAC_add_en_dl1          ;
always @ (posedge Clk or posedge Reset)
    if (Reset)
        begin
        data_dl1            <=0;
        MAC_add_en_dl1      <=0;
        end
    else
        begin
        data_dl1            <=data;
        MAC_add_en_dl1      <=MAC_add_en;
        end        
always @ (posedge Clk or posedge Reset)
    if (Reset)
        begin
        MAC_add_prom_wr_dl1     <=0;
        MAC_add_prom_wr_dl2     <=0;
        end
    else
        begin
        MAC_add_prom_wr_dl1     <=MAC_add_prom_wr;
        MAC_add_prom_wr_dl2     <=MAC_add_prom_wr_dl1;
        end    
assign wr_en      =MAC_add_prom_wr_dl1&!MAC_add_prom_wr_dl2;
assign addr_wr    =MAC_add_prom_add;
assign din        =MAC_add_prom_data;
always @ (posedge Clk or posedge Reset)
    if (Reset)
        addr_rd       <=0;
    else if (Init)
        addr_rd       <=0;
    else if (MAC_add_en)
        addr_rd       <=addr_rd + 1;
always @ (posedge Clk or posedge Reset)
    if (Reset)
        MAC_rx_add_chk_err  <=0;
    else if (Init)
        MAC_rx_add_chk_err  <=0;
    else if (MAC_rx_add_chk_en&&MAC_add_en_dl1&&dout!=data_dl1)
        MAC_rx_add_chk_err  <=1;
duram #(8,3,"M512","DUAL_PORT") U_duram(
.data_a         (din       ),
.wren_a         (wr_en        ),
.address_a      (addr_wr      ),
.address_b      (addr_rd      ),
.clock_a        (Clk        ),
.clock_b        (Clk        ),
.q_b            (dout      ));
endmodule
