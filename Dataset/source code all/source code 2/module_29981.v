module msix_manager_br #(
  parameter C_M_AXI_LITE_ADDR_WIDTH          = 9,
  parameter C_M_AXI_LITE_DATA_WIDTH          = 32,
  parameter C_M_AXI_LITE_STRB_WIDTH          = 32,
  parameter C_MSIX_TABLE_OFFSET              = 32'h0,
  parameter C_MSIX_PBA_OFFSET                = 32'h100, 
  parameter C_NUM_IRQ_INPUTS                 = 1
)( 
  input   wire                   clk,
  input   wire                   rst_n,
  input  wire [C_M_AXI_LITE_ADDR_WIDTH-1:0]   s_mem_iface_waddr,
  input  wire [C_M_AXI_LITE_ADDR_WIDTH-1:0]   s_mem_iface_raddr,
  input  wire [C_M_AXI_LITE_DATA_WIDTH-1:0]   s_mem_iface_wdata,
  output wire [C_M_AXI_LITE_DATA_WIDTH-1:0]   s_mem_iface_rdata,
  input  wire                                 s_mem_iface_we_norread,
  output wire [3:0]                           cfg_interrupt_int,                  
  output wire [1:0]                           cfg_interrupt_pending,              
  input  wire                                 cfg_interrupt_sent,                        
  input  wire [1:0]                           cfg_interrupt_msi_enable,          
  input  wire [5:0]                           cfg_interrupt_msi_vf_enable,       
  input  wire [5:0]                           cfg_interrupt_msi_mmenable,        
  input  wire                                 cfg_interrupt_msi_mask_update,             
  input  wire [31:0]                          cfg_interrupt_msi_data,           
  output wire [3:0]                           cfg_interrupt_msi_select,           
  output wire [31:0]                          cfg_interrupt_msi_int,             
  output wire [63:0]                          cfg_interrupt_msi_pending_status,  
  input  wire                                 cfg_interrupt_msi_sent,                    
  input  wire                                 cfg_interrupt_msi_fail,                    
  input  wire [1:0]                           cfg_interrupt_msix_enable,         
  input  wire [1:0]                           cfg_interrupt_msix_mask,           
  input  wire [5:0]                           cfg_interrupt_msix_vf_enable,      
  input  wire [5:0]                           cfg_interrupt_msix_vf_mask,        
  output reg  [31:0]                          cfg_interrupt_msix_data,           
  output wire [63:0]                          cfg_interrupt_msix_address,        
  output reg                                  cfg_interrupt_msix_int,                     
  input  wire                                 cfg_interrupt_msix_sent,                   
  input  wire                                 cfg_interrupt_msix_fail,                   
  output wire [2:0]                           cfg_interrupt_msi_attr,
  output wire                                 cfg_interrupt_msi_tph_present,              
  output wire [1:0]                           cfg_interrupt_msi_tph_type,         
  output wire [8:0]                           cfg_interrupt_msi_tph_st_tag,       
  output wire [2:0]                           cfg_interrupt_msi_function_number,
  input  wire [C_NUM_IRQ_INPUTS-1:0]          irq
);  
  assign cfg_interrupt_int = 4'b0;
  assign cfg_interrupt_pending = 2'h0;
  assign cfg_interrupt_msi_select = 4'h0;
  assign cfg_interrupt_msi_int = 32'b0;
  assign cfg_interrupt_msi_pending_status = 64'h0;
  assign cfg_interrupt_msi_attr = 3'h0;
  assign cfg_interrupt_msi_tph_present = 1'b0;
  assign cfg_interrupt_msi_tph_type = 2'h0;
  assign cfg_interrupt_msi_tph_st_tag = 9'h0;
  assign cfg_interrupt_msi_function_number = 3'h0;
  wire   [31:0]             doa;
  wire   [31:0]             dob;
  wire   [31:0]             dib;
  reg    [31:0]             dia;
  wire   [9:0]              addrbrdaddr;
  wire                      enbwren;
  reg                       enawren;
  reg    [9:0]              addrardaddr;
  assign s_mem_iface_rdata = dob[C_M_AXI_LITE_DATA_WIDTH-1:0];
  assign addrbrdaddr = s_mem_iface_we_norread == 1'b0 ? s_mem_iface_raddr : s_mem_iface_waddr; 
  assign dib         = s_mem_iface_wdata;
  assign enbwren     = s_mem_iface_we_norread; 
  bram_tdp #(
    .DATA(32),
    .ADDR(10)
  ) bram_tdp_i (
    .a_clk(clk),
    .a_wr(enawren),
    .a_addr(addrardaddr),
    .a_din(dia),
    .a_dout(doa),
    .b_clk(clk),
    .b_wr(enbwren),
    .b_addr(addrbrdaddr),
    .b_din(dib),
    .b_dout(dob)
  );
  integer irq_number, i;
  reg  [31:0] cfg_interrupt_msix_address_msb,cfg_interrupt_msix_address_lsb;
  assign cfg_interrupt_msix_address = {cfg_interrupt_msix_address_msb, cfg_interrupt_msix_address_lsb};
  reg     [C_NUM_IRQ_INPUTS-1:0] irq_s;     
  integer irq_count [C_NUM_IRQ_INPUTS-1:0]; 
  reg [31:0]                irq_pba, current_pba; 
  reg [3:0]                 state;
  reg [3:0]                 next_state;
  localparam IDLE       = 4'b0000;
  localparam TO_BINARY  = 4'b0001;
  localparam GET_ADDR1  = 4'b0010;
  localparam GET_ADDR2  = 4'b0011;
  localparam GET_DATA   = 4'b0100;
  localparam READ_PBA   = 4'b0101;
  localparam WRITE_PBA  = 4'b0110;
  localparam ACTIVE_IRQ = 4'b0111;
  localparam CLEAR_PBA  = 4'b1000;
  localparam WAIT       = 4'b1111;
  always @(negedge rst_n or posedge clk) begin
    if(~rst_n) begin
      irq_s                  <= {C_NUM_IRQ_INPUTS{1'b0}};
      cfg_interrupt_msix_int <= 1'b0;
      for(i=0; i<C_NUM_IRQ_INPUTS; i=i+1) begin
        irq_count[i] <= 0;
      end
    end else begin
      case(state) 
        ACTIVE_IRQ: begin
          for(i=0; i<C_NUM_IRQ_INPUTS; i=i+1) begin
            if(irq_number==i) begin
              irq_count[i] <= irq_count[i] +  irq[i] - 1;
            end else begin
              irq_count[i] <= irq_count[i] +  irq[i];
            end
          end
          for(i=0; i<C_NUM_IRQ_INPUTS; i=i+1) begin
            if(irq_number==i && irq_count[irq_number] == 1 ) begin
              irq_s[i] <= 1'b0;
            end else begin
              irq_s[i]   <= irq[i] | irq_s[i];
            end
          end
          cfg_interrupt_msix_int <= 1'b1;
        end
        default: begin
          for(i=0; i<C_NUM_IRQ_INPUTS; i=i+1) begin
            irq_count[i] <= irq_count[i] +  irq[i];
          end
          irq_s                  <= irq | irq_s;
          cfg_interrupt_msix_int <= 1'b0;
        end
      endcase
    end
  end
  always @(negedge rst_n or posedge clk) begin
    if(~rst_n) begin
      cfg_interrupt_msix_data        <= 32'h0; 
      cfg_interrupt_msix_address_msb <= 32'h0; 
      cfg_interrupt_msix_address_lsb <= 32'h0; 
      current_pba                    <= 32'h0;
    end else begin
      case(state) 
        GET_ADDR2: begin
          cfg_interrupt_msix_address_lsb <= doa; 
        end
        GET_DATA: begin
          cfg_interrupt_msix_address_msb <= doa; 
        end
        READ_PBA: begin
          cfg_interrupt_msix_data        <= doa; 
        end
        WRITE_PBA: begin
          current_pba                    <= doa;
        end
        default: begin
          cfg_interrupt_msix_data        <= cfg_interrupt_msix_data; 
          cfg_interrupt_msix_address_msb <= cfg_interrupt_msix_address_msb; 
          cfg_interrupt_msix_address_lsb <= cfg_interrupt_msix_address_lsb; 
          current_pba                    <= current_pba;
        end
      endcase
    end
  end
  always @(negedge rst_n or posedge clk) begin
    if(~rst_n) begin
      dia     <= 32'h0; 
      enawren <= 1'b0;
    end else begin
      case(state)
        WRITE_PBA: begin
          dia     <= doa | irq_pba;
          enawren <= 1'b1;
        end
        CLEAR_PBA: begin
          if(cfg_interrupt_msix_sent || cfg_interrupt_msix_fail) begin
            enawren     <= 1'b1;
            dia         <= current_pba & (~irq_pba); 
          end else begin
            enawren     <= 1'b0;
            dia         <= dia;
          end
        end
        WAIT: begin
          enawren <= enawren;
          dia     <= dia;
        end
        default: begin
          enawren <= 1'b0;
          dia     <= dia;
        end
      endcase
    end
  end
  always @(negedge rst_n or posedge clk) begin
    if(~rst_n) begin
      state                  <= IDLE;
      next_state             <= IDLE;
      irq_number             <= 0;
      irq_pba                <= 32'h0; 
    end else begin
      case(state) 
        IDLE: begin 
          if( cfg_interrupt_msix_enable && irq_s != {C_NUM_IRQ_INPUTS{1'b0}} ) begin   
            state   <= TO_BINARY;
          end else begin
            state   <= IDLE;
          end
          irq_number <= 0;
        end
        TO_BINARY:begin  
          for(i=0; i<C_NUM_IRQ_INPUTS; i=i+1) begin
            if(irq_s[i]) begin
              irq_number <= i;
              irq_pba    <= (1<<(i%32));
            end 
          end
          state   <= GET_ADDR1;
        end
        GET_ADDR1: begin 
          addrardaddr <= 9'h0 + C_MSIX_TABLE_OFFSET  + irq_number*9'h10;
          state       <= WAIT;
          next_state  <= GET_ADDR2;
        end
        GET_ADDR2: begin
          addrardaddr <= 9'h4 + C_MSIX_TABLE_OFFSET  + irq_number*9'h10;
          state       <= WAIT;
          next_state  <= GET_DATA;
        end
        GET_DATA: begin
          addrardaddr <= 9'h8 + C_MSIX_TABLE_OFFSET  + irq_number*9'h10;
          state       <= WAIT;
          next_state  <= READ_PBA;
        end
        READ_PBA: begin 
          addrardaddr <= C_MSIX_PBA_OFFSET  + ((irq_number/32)<<2);
          state       <= WAIT;
          next_state  <= WRITE_PBA;
        end
        WRITE_PBA: begin 
          addrardaddr <= C_MSIX_PBA_OFFSET  + ((irq_number/32)<<2); 
          state       <= WAIT;
          next_state  <= ACTIVE_IRQ;
        end
        ACTIVE_IRQ: begin 
          state                      <= CLEAR_PBA;
        end
        CLEAR_PBA: begin 
          if(cfg_interrupt_msix_sent || cfg_interrupt_msix_fail) begin
            addrardaddr <= C_MSIX_PBA_OFFSET  + ((irq_number/32)<<2);
            state       <= WAIT;
            next_state  <= IDLE;
          end else begin
            state       <= CLEAR_PBA;
          end
        end
        WAIT: begin 
          state   <= next_state;
        end
        default: begin
          state                    <= IDLE;
          next_state               <= IDLE;
        end
      endcase
    end
  end
endmodule
