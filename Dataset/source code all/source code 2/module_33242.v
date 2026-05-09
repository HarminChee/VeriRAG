module MAC_tx_addr_add ( 
Reset               ,
Clk                 ,
MAC_tx_addr_init    ,
MAC_tx_addr_rd      ,
MAC_tx_addr_data    ,
MAC_add_prom_data   ,
MAC_add_prom_add    ,
MAC_add_prom_wr     
);
input           Reset               ;
input           Clk                 ;
input           MAC_tx_addr_rd      ;
input           MAC_tx_addr_init    ;
output  [7:0]   MAC_tx_addr_data    ;
input   [7:0]   MAC_add_prom_data   ;
input   [2:0]   MAC_add_prom_add    ;
input           MAC_add_prom_wr     ;
reg [2:0]       add_rd;
wire[2:0]       add_wr;
wire[7:0]       din;
wire[7:0]       dout;
wire            wr_en;
reg             MAC_add_prom_wr_dl1;
reg             MAC_add_prom_wr_dl2;
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
assign # 2 wr_en   =MAC_add_prom_wr_dl1&!MAC_add_prom_wr_dl2;
assign # 2 add_wr  =MAC_add_prom_add;
assign # 2 din     =MAC_add_prom_data;
always @ (posedge Clk or posedge Reset)
    if (Reset)
        add_rd       <=0;
    else if (MAC_tx_addr_init)
        add_rd       <=0;
    else if (MAC_tx_addr_rd)
        add_rd       <=add_rd + 1;
assign MAC_tx_addr_data=dout;      
duram #(8,3,"M512","DUAL_PORT") U_duram(           
.data_a         (din            ), 
.wren_a         (wr_en          ), 
.address_a      (add_wr         ), 
.address_b      (add_rd         ), 
.clock_a        (Clk            ), 
.clock_b        (Clk            ), 
.q_b            (dout           ));  
endmodule                        
