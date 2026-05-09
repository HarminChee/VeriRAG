`timescale 1 ps/1 ps
`timescale 1 ps/1 ps
module axi_lite_sm #(
      parameter            MAC_BASE_ADDR = 32'h0
) (
      input                s_axi_aclk,
      input                s_axi_resetn,
      input       [1:0]    mac_speed,
      input                update_speed,
      input                serial_command,
      output               serial_response,
      input                phy_loopback,
      output reg  [31:0]   s_axi_awaddr,
      output reg           s_axi_awvalid,
      input                s_axi_awready,
      output reg  [31:0]   s_axi_wdata,
      output reg           s_axi_wvalid,
      input                s_axi_wready,
      input       [1:0]    s_axi_bresp,
      input                s_axi_bvalid,
      output reg           s_axi_bready,
      output reg  [31:0]   s_axi_araddr,
      output reg           s_axi_arvalid,
      input                s_axi_arready,
      input       [31:0]   s_axi_rdata,
      input       [1:0]    s_axi_rresp,
      input                s_axi_rvalid,
      output reg           s_axi_rready
);
parameter RUN_HALF_DUPLEX        = 0;     
parameter  STARTUP               = 0,
           MDIO_RD               = 1,
           MDIO_POLL_CHECK       = 2,
           MDIO_1G               = 3,
           MDIO_10_100           = 4,
           MDIO_RESTART          = 11,
           MDIO_LOOPBACK         = 12,
           MDIO_STATS            = 13,
           MDIO_STATS_POLL_CHECK = 14,
           UPDATE_SPEED          = 15,
           RESET_MAC_TX          = 16,
           RESET_MAC_RX          = 17,
           CNFG_MDIO             = 18,
           CNFG_FLOW             = 19,
           CNFG_LO_ADDR          = 20,
           CNFG_HI_ADDR          = 21,
           CNFG_FILTER           = 22,
           CNFG_HD1              = 23,
           CNFG_HD2              = 24,
           CHECK_SPEED           = 25;
parameter  IDLE                  = 0,
           SET_DATA              = 1,
           INIT                  = 2,
           POLL                  = 3;
parameter  READ                  = 1,
           WRITE                 = 2,
           DONE                  = 3;           
parameter CONFIG_MANAGEMENT_ADD  = MAC_BASE_ADDR + 18'h500;
parameter CONFIG_FLOW_CTRL_ADD   = MAC_BASE_ADDR + 18'h40C;
parameter RECEIVER_ADD           = MAC_BASE_ADDR + 18'h404;
parameter TRANSMITTER_ADD        = MAC_BASE_ADDR + 18'h408;
parameter SPEED_CONFIG_ADD       = MAC_BASE_ADDR + 18'h410;
parameter CONFIG_UNI0_CTRL_ADD   = MAC_BASE_ADDR + 18'h700;
parameter CONFIG_UNI1_CTRL_ADD   = MAC_BASE_ADDR + 18'h704;
parameter CONFIG_ADDR_CTRL_ADD   = MAC_BASE_ADDR + 18'h708;
parameter MDIO_CONTROL           = MAC_BASE_ADDR + 18'h504;
parameter MDIO_TX_DATA           = MAC_BASE_ADDR + 18'h508;
parameter MDIO_RX_DATA           = MAC_BASE_ADDR + 18'h50C;
parameter MDIO_OP_RD             = 2'b10;
parameter MDIO_OP_WR             = 2'b01;
parameter PHY_ADDR               = 8'h7;
parameter PHY_CONTROL_REG        = 8'h0;
parameter PHY_STATUS_REG         = 8'h1;  
parameter PHY_ABILITY_REG        = 8'h4; 
parameter PHY_1000BASET_CONTROL_REG = 8'h9;
reg      [4:0]    axi_status;          
reg               mdio_ready;          
reg      [31:0]   axi_rd_data;
reg      [31:0]   axi_wr_data;
reg      [31:0]   mdio_wr_data;
reg      [4:0]    axi_state;           
reg      [1:0]    mdio_access_sm;      
reg      [1:0]    axi_access_sm;       
reg               start_access;        
reg               start_mdio;          
reg               drive_mdio;          
reg      [1:0]    mdio_op;             
reg      [7:0]    mdio_reg_addr;
reg               writenread;
reg      [17:0]   addr;
reg      [1:0]    speed;
reg               update_speed_reg;
reg      [20:0]   count_shift = {21{1'b1}};
reg      [36:0]   serial_command_shift;
reg               load_data;
reg               capture_data;
reg               write_access;
reg               read_access;
wire              s_axi_reset;
assign s_axi_reset = !s_axi_resetn;
always @(posedge s_axi_aclk)
begin
   if (s_axi_reset) begin
      update_speed_reg <= 0;
   end
   else begin
      update_speed_reg <= update_speed;
   end
end
always @(posedge s_axi_aclk)
begin
   if (s_axi_reset) begin
      axi_state      <= STARTUP;
      start_access   <= 0;
      start_mdio     <= 0;
      drive_mdio     <= 0;
      mdio_op        <= 0;
      mdio_reg_addr  <= 0;
      writenread     <= 0;
      addr           <= 0;
      axi_wr_data    <= 0;
      speed          <= mac_speed;
   end
   else if (axi_access_sm == IDLE && mdio_access_sm == IDLE && !start_access && !start_mdio) begin
      case (axi_state)
         STARTUP : begin
            if (count_shift[20] === 1'b0) begin
               $display("** Note: Setting MDC Frequency to 2.5MHZ....");
               start_access   <= 1;
               writenread     <= 1;
               addr           <= CONFIG_MANAGEMENT_ADD;
               axi_wr_data    <= 32'h68;
               axi_state      <= MDIO_RD;
            end
         end
         MDIO_RD : begin
            speed          <= mac_speed;
            $display("** Note: Checking for PHY");
            drive_mdio     <= 1;   
            start_mdio     <= 1;
            writenread     <= 0;
            mdio_reg_addr  <= PHY_STATUS_REG;
            mdio_op        <= MDIO_OP_RD;
            axi_state      <= MDIO_POLL_CHECK;
         end
         MDIO_POLL_CHECK : begin
            if (axi_rd_data[16:0] == 17'h1ffff)
               axi_state      <= UPDATE_SPEED;
            else
               axi_state      <= MDIO_1G;
         end
         MDIO_1G : begin
            $display("** Note: Setting PHY 1G advertisement");
            start_mdio     <= 1;
            mdio_reg_addr  <= PHY_1000BASET_CONTROL_REG;
            mdio_op        <= MDIO_OP_WR;
            if (RUN_HALF_DUPLEX)
               axi_wr_data    <= {16'h0, 7'h0, speed[1], 8'h0};
            else
               axi_wr_data    <= {16'h0, 6'h0, speed[1], 9'h0};
            axi_state      <= MDIO_10_100;
         end
         MDIO_10_100 : begin
            $display("** Note: Setting PHY 10/100M advertisement");
            start_mdio     <= 1;
            mdio_reg_addr  <= PHY_ABILITY_REG;
            mdio_op        <= MDIO_OP_WR;
            if (RUN_HALF_DUPLEX)
               axi_wr_data    <= {16'h0, 8'h0, !speed[1] & speed[0], 1'b0, !speed[1] & !speed[0], 5'h0};
            else
               axi_wr_data    <= {16'h0, 7'h0, !speed[1] & speed[0], 1'b0, !speed[1] & !speed[0], 6'h0};
            axi_state      <= MDIO_RESTART;
         end
         MDIO_RESTART : begin
            $display("** Note: Applying PHY software reset");
            start_mdio     <= 1;
            mdio_reg_addr  <= PHY_CONTROL_REG;
            mdio_op        <= MDIO_OP_WR;
            if (phy_loopback) begin
               axi_wr_data    <= {16'h0, 2'b10, !speed[1] & speed[0], 4'h0, 1'b1,  1'b0, speed[1], 6'h0};
               axi_state   <= MDIO_LOOPBACK;
            end
            else begin
               axi_wr_data    <= {16'h0, 4'h9, 12'h0};
               axi_state   <= MDIO_STATS;
            end
         end
         MDIO_LOOPBACK : begin
            $display("** Note: Settling PHY Loopback");
            start_mdio     <= 1;
            mdio_reg_addr  <= PHY_CONTROL_REG;
            mdio_op        <= MDIO_OP_WR;
            axi_wr_data    <= {16'h0, 2'b01, !speed[1] & speed[0], 4'h0, 1'b1,  1'b0, speed[1], 6'h0};
            axi_state      <= UPDATE_SPEED;
         end
         MDIO_STATS : begin
            start_mdio     <= 1;
            $display("** Note: Wait for Autonegotiation to complete");
            mdio_reg_addr  <= PHY_STATUS_REG;
            mdio_op        <= MDIO_OP_RD;
            axi_state      <= MDIO_STATS_POLL_CHECK;
         end
         MDIO_STATS_POLL_CHECK : begin
            if (axi_rd_data[5] === 1'b1 && axi_rd_data[16] === 1'b1)
               axi_state      <= UPDATE_SPEED;
            else
               axi_state      <= MDIO_STATS;
         end
         UPDATE_SPEED : begin
            $display("** Note: Programming MAC speed");
            drive_mdio     <= 0;
            start_access   <= 1;
            writenread     <= 1;
            addr           <= SPEED_CONFIG_ADD;
            axi_wr_data    <= {speed, 30'h0};
            axi_state      <= RESET_MAC_RX;
         end
         RESET_MAC_RX : begin
            $display("** Note: Reseting MAC RX");
            start_access   <= 1;
            writenread     <= 1;
            addr           <= RECEIVER_ADD;
            axi_wr_data    <= 32'h90000000;
            axi_state      <= RESET_MAC_TX;
         end
         RESET_MAC_TX : begin
            $display("** Note: Reseting MAC TX");
            start_access   <= 1;
            writenread     <= 1;
            addr           <= TRANSMITTER_ADD;
            axi_wr_data    <= 32'h90000000;
            axi_state      <= CNFG_MDIO;
         end
         CNFG_MDIO : begin
            $display("** Note: Setting MDC Frequency to 2.5MHZ....");
            start_access   <= 1;
            writenread     <= 1;
            addr           <= CONFIG_MANAGEMENT_ADD;
            axi_wr_data    <= 32'h68;
            axi_state      <= CNFG_FLOW;
         end
         CNFG_FLOW : begin
            $display("** Note: Disabling Flow control....");
            start_access   <= 1;
            writenread     <= 1;
            addr           <= CONFIG_FLOW_CTRL_ADD;
            axi_wr_data    <= 32'h0;
            axi_state      <= CNFG_LO_ADDR;
         end
         CNFG_LO_ADDR : begin
            $display("** Note: Configuring unicast address(low word)....");
            start_access   <= 1;
            writenread     <= 1;
            addr           <= CONFIG_UNI0_CTRL_ADD;
            axi_wr_data    <= 32'h040302DA;
            axi_state      <= CNFG_HI_ADDR;
         end
         CNFG_HI_ADDR : begin
            $display("** Note: Configuring unicast address(high word)....");
            start_access   <= 1;
            writenread     <= 1;
            addr           <= CONFIG_UNI1_CTRL_ADD;
            axi_wr_data    <= 32'h0605;
            axi_state      <= CNFG_FILTER;
         end
         CNFG_FILTER : begin
            $display("** Note: Setting core to promiscuous mode....");
            start_access   <= 1;
            writenread     <= 1;
            addr           <= CONFIG_ADDR_CTRL_ADD;
            axi_wr_data    <= 32'h80000000;
            if (RUN_HALF_DUPLEX)
               axi_state      <= CNFG_HD1;
            else
               axi_state      <= CHECK_SPEED;
         end
         CNFG_HD1 : begin
            start_access   <= 1;
            writenread     <= 1;
            addr           <= RECEIVER_ADD;
            axi_wr_data    <= 32'h14000000;
            axi_state      <= CNFG_HD2;
         end
         CNFG_HD2 : begin
            start_access   <= 1;
            writenread     <= 1;
            addr           <= TRANSMITTER_ADD;
            axi_wr_data    <= 32'h14000000;
            axi_state      <= CHECK_SPEED;
         end
         CHECK_SPEED : begin
            if (update_speed_reg) begin
              axi_state      <= MDIO_RD;
            end
            else begin
               if (capture_data)
                  axi_wr_data <= serial_command_shift[33:2];
               if (write_access || read_access) begin
                  addr        <= serial_command_shift[13:2];
                  start_access <= 1;
                  writenread   <= write_access;
               end
            end
         end
         default : begin
            axi_state <= STARTUP;
         end
      endcase
   end
   else begin
      start_access <= 0;
      start_mdio   <= 0;
   end
end
always @(posedge s_axi_aclk)
begin
   if (s_axi_reset) begin
      mdio_access_sm <= IDLE;
   end
   else if (axi_access_sm == IDLE || axi_access_sm == DONE) begin
      case (mdio_access_sm)
         IDLE : begin
            if (start_mdio) begin
               if (mdio_op == MDIO_OP_WR) begin
                  mdio_access_sm <= SET_DATA;
                  mdio_wr_data   <= axi_wr_data;        
               end
               else begin
                  mdio_access_sm <= INIT;
                  mdio_wr_data   <= {PHY_ADDR, mdio_reg_addr, mdio_op, 3'h1, 11'h0};        
               end
            end
         end
         SET_DATA : begin
            mdio_access_sm <= INIT;    
            mdio_wr_data   <= {PHY_ADDR, mdio_reg_addr, mdio_op, 3'h1, 11'h0};        
         end
         INIT : begin
            mdio_access_sm <= POLL;    
         end
         POLL : begin
            if (mdio_ready)
               mdio_access_sm <= IDLE;
         end
      endcase
   end
   else if (mdio_access_sm == POLL && mdio_ready) begin
      mdio_access_sm <= IDLE;
   end
end
always @(posedge s_axi_aclk)
begin
   if (s_axi_reset) begin
      axi_access_sm <= IDLE;
   end
   else begin
      case (axi_access_sm)
         IDLE : begin
            if (start_access || start_mdio || mdio_access_sm != IDLE) begin
               if (mdio_access_sm == POLL) begin
                  axi_access_sm <= READ;
               end
               else if ((start_access && writenread) || 
                        (mdio_access_sm == SET_DATA || mdio_access_sm == INIT) || start_mdio) begin
                  axi_access_sm <= WRITE;
               end
               else begin
                  axi_access_sm <= READ;
               end
            end
         end
         WRITE : begin
            if (axi_status[4:2] == 3'b111)
               axi_access_sm <= DONE;
         end
         READ : begin
            if (axi_status[1:0] == 2'b11)
               axi_access_sm <= DONE;
         end
         DONE : begin
            axi_access_sm <= IDLE;
         end
      endcase
   end
end
always @(posedge s_axi_aclk)
begin
   if (axi_access_sm == READ) begin
      if (!axi_status[0]) begin
         if (drive_mdio) begin
            s_axi_araddr   <= MDIO_RX_DATA;
         end
         else begin
            s_axi_araddr   <= addr;      
         end
         s_axi_arvalid  <= 1'b1;
         if (s_axi_arready === 1'b1 && s_axi_arvalid) begin
            axi_status[0] <= 1;
            s_axi_araddr      <= 0;
            s_axi_arvalid     <= 0;
         end
      end
   end
   else begin
      axi_status[0]     <= 0;
      s_axi_araddr      <= 0;
      s_axi_arvalid     <= 0;
   end
end
always @(posedge s_axi_aclk)
begin
   if (axi_access_sm == READ) begin
      if (!axi_status[1]) begin
         s_axi_rready  <= 1'b1;
         if (s_axi_rvalid === 1'b1 && s_axi_rready) begin
            axi_status[1] <= 1;
            s_axi_rready  <= 0;
            axi_rd_data   <= s_axi_rdata;
            if (drive_mdio & s_axi_rdata[16])
               mdio_ready <= 1;
         end
      end
   end
   else begin
      s_axi_rready      <= 0;
      axi_status[1]     <= 0;
      if (axi_access_sm == IDLE & (start_access || start_mdio)) begin
         mdio_ready     <= 0;
         axi_rd_data    <= 0;
      end
   end
end
always @(posedge s_axi_aclk)
begin
   if (axi_access_sm == WRITE) begin
      if (!axi_status[2]) begin
         if (drive_mdio) begin
            if (mdio_access_sm == SET_DATA)
               s_axi_awaddr <= MDIO_TX_DATA;
            else
               s_axi_awaddr <= MDIO_CONTROL;
         end
         else begin
            s_axi_awaddr   <= addr;
         end
         s_axi_awvalid  <= 1'b1;
         if (s_axi_awready === 1'b1 && s_axi_awvalid) begin
            axi_status[2] <= 1;
            s_axi_awaddr      <= 0;
            s_axi_awvalid     <= 0;
         end
      end
   end
   else begin
      s_axi_awaddr      <= 0;
      s_axi_awvalid     <= 0;
      axi_status[2]     <= 0;
   end
end
always @(posedge s_axi_aclk)
begin
   if (axi_access_sm == WRITE) begin
      if (!axi_status[3]) begin
         if (drive_mdio) begin
            s_axi_wdata   <= mdio_wr_data;
         end
         else begin
            s_axi_wdata   <= axi_wr_data;
         end
         s_axi_wvalid  <= 1'b1;
         if (s_axi_wready === 1'b1 && s_axi_wvalid) begin
            axi_status[3] <= 1;
            s_axi_wdata      <= 0;
            s_axi_wvalid     <= 0;
         end
      end
   end
   else begin
      s_axi_wdata      <= 0;
      s_axi_wvalid     <= 0;
      axi_status[3]     <= 0;
   end
end
always @(posedge s_axi_aclk)
begin
   if (axi_access_sm == WRITE) begin
      if (!axi_status[4]) begin
         s_axi_bready  <= 1'b1;
         if (s_axi_bvalid === 1'b1 && s_axi_bready) begin
            axi_status[4] <= 1;
            s_axi_bready     <= 0;
         end
      end
   end
   else begin
      s_axi_bready     <= 0;
      axi_status[4]     <= 0;
   end
end
always @(posedge s_axi_aclk)
begin
    if (load_data)
       serial_command_shift <= {serial_command_shift[35:33], axi_rd_data, serial_command_shift[0], serial_command};
    else
       serial_command_shift <= {serial_command_shift[35:0], serial_command};
end
assign serial_response = (axi_state == CHECK_SPEED) ? serial_command_shift[35] : 1'b1;
always @(posedge s_axi_aclk)
begin
    load_data <= 0;
    capture_data <= 0;
    write_access <= 0;
    read_access  <= 0;
    if (!serial_command_shift[36] & serial_command_shift[35] & serial_command_shift[0])
       if (serial_command_shift[34] & serial_command_shift[33])       
          load_data <= 1;
       else if (serial_command_shift[34] & !serial_command_shift[33]) 
          capture_data <= 1;
       else if (!serial_command_shift[34] & serial_command_shift[33]) 
          write_access <= 1;
       else                                                           
          read_access <= 1;
end
always @(posedge s_axi_aclk)
begin
    count_shift <= {count_shift[19:0], s_axi_reset};
end
endmodule  
