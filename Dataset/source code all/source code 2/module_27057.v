`timescale 1 ns/1 ps
`define wait_sf    3'd0  
`define bypass_sa1 3'd1  
`define bypass_sa2 3'd2  
`define bypass_sa3 3'd3  
`define bypass_sa4 3'd4  
`define bypass_sa5 3'd5  
`define bypass_sa6 3'd6  
`define pass_rof   3'd7  
`timescale 1 ns/1 ps
`define wait_sf    3'd0  
`define bypass_sa1 3'd1  
`define bypass_sa2 3'd2  
`define bypass_sa3 3'd3  
`define bypass_sa4 3'd4  
`define bypass_sa5 3'd5  
`define bypass_sa6 3'd6  
`define pass_rof   3'd7  
module address_swap_module_8 (
      rx_ll_clock,         
      rx_ll_reset,         
      rx_ll_data_in,       
      rx_ll_sof_in_n,      
      rx_ll_eof_in_n,      
      rx_ll_src_rdy_in_n,  
      rx_ll_data_out,      
      rx_ll_sof_out_n,     
      rx_ll_eof_out_n,     
      rx_ll_src_rdy_out_n, 
      rx_ll_dst_rdy_in_n   
   );
   input  rx_ll_clock;
   input  rx_ll_reset;
   input  [7:0] rx_ll_data_in;
   input  rx_ll_sof_in_n;
   input  rx_ll_eof_in_n;
   input  rx_ll_src_rdy_in_n;
   output [7:0] rx_ll_data_out;
   reg    [7:0] rx_ll_data_out;
   output rx_ll_sof_out_n;
   output rx_ll_eof_out_n;
   output rx_ll_src_rdy_out_n;
   input  rx_ll_dst_rdy_in_n;
   reg        sel_delay_path;        
   reg        enable_data_sr;        
   wire [7:0] data_sr5;              
   reg  [7:0] mux_out;               
   wire       rx_enable;             
   reg [2:0]  control_fsm_state;     
   reg [7:0]  data_sr_content[0:5];  
   reg        eof_sr_content[0:6];  
   reg        sof_sr_content[0:6];  
   reg        rdy_sr_content[0:6];   
   integer    i;  
   always @(posedge rx_ll_clock)
   begin
      if (enable_data_sr == 1'b1 && rx_enable == 1'b1)
      begin
       for(i=5; i >0; i=i-1)
         data_sr_content[i] <= data_sr_content [i-1];
       data_sr_content[0] <= rx_ll_data_in;
      end
   end 
   assign data_sr5 = data_sr_content[5];
   always @(rx_ll_data_in, data_sr5, sel_delay_path)
   begin
      if (sel_delay_path == 1'b1)
         mux_out = rx_ll_data_in;
      else
         mux_out = data_sr5;
   end 
   always @(posedge rx_ll_clock)
   begin
      if (rx_enable == 1'b1)
         rx_ll_data_out <= mux_out;
   end 
   assign rx_enable = ~(rx_ll_dst_rdy_in_n);
   always @(posedge rx_ll_clock)
   begin
      if (rx_enable == 1'b1)
      begin
         for(i=6; i>0; i=i-1)
         sof_sr_content[i] <= sof_sr_content[i-1];
         sof_sr_content[0] <= !rx_ll_sof_in_n;
      end
   end 
   assign rx_ll_sof_out_n = !sof_sr_content[6];
   always @(posedge rx_ll_clock)
   begin
      if (rx_enable == 1'b1)
      begin
       for(i=6; i>0; i=i-1)
         eof_sr_content[i] <= eof_sr_content[i-1];
         eof_sr_content[0] <= !rx_ll_eof_in_n;
      end
   end 
   assign rx_ll_eof_out_n = !eof_sr_content[6];
   always @(posedge rx_ll_clock)
   begin
      if (rx_enable == 1'b1)
      begin
         for(i=6; i>0; i=i-1)
         rdy_sr_content[i] <= rdy_sr_content[i-1];
         rdy_sr_content[0] <= !rx_ll_src_rdy_in_n;
      end
   end 
   assign rx_ll_src_rdy_out_n = !rdy_sr_content[6];
   always @(posedge rx_ll_clock)
   begin
      if (rx_ll_reset == 1)
         control_fsm_state <= `wait_sf;
      else
         if (rx_enable == 1'b1)
         begin
            case(control_fsm_state)
               `wait_sf :     if (sof_sr_content[4] == 1'b1)
                              control_fsm_state <= `bypass_sa1;  
                              else
                              control_fsm_state <= `wait_sf;     
                `bypass_sa1 : if (!(sof_sr_content[4] == 1'b0 && eof_sr_content[4] == 1'b1))
                              control_fsm_state <= `bypass_sa2;  
                              else
                              control_fsm_state <= `wait_sf;     
                `bypass_sa2 : if (!(sof_sr_content[4] == 1'b0 && eof_sr_content[4] == 1'b1))
                              control_fsm_state <= `bypass_sa3;  
                              else
                              control_fsm_state <= `wait_sf;     
                `bypass_sa3 : if (!(sof_sr_content[4] == 1'b0 && eof_sr_content[4] == 1'b1))
                              control_fsm_state <= `bypass_sa4;  
                              else
                              control_fsm_state <= `wait_sf;     
                `bypass_sa4 : if (!(sof_sr_content[4] == 1'b0 && eof_sr_content[4] == 1'b1))
                              control_fsm_state <= `bypass_sa5;  
                              else
                              control_fsm_state <= `wait_sf;     
                `bypass_sa5 : if (!(sof_sr_content[4] == 1'b0 && eof_sr_content[4] == 1'b1))
                              control_fsm_state <= `bypass_sa6;  
                              else
                              control_fsm_state <= `wait_sf;     
                `bypass_sa6 : if (!(sof_sr_content[4] == 1'b0 && eof_sr_content[4] == 1'b1))
                              control_fsm_state <= `pass_rof;    
                              else
                              control_fsm_state <= `wait_sf;     
                `pass_rof   : if (!(sof_sr_content[4] == 1'b0 && eof_sr_content[4] == 1'b1))
                              control_fsm_state <= `pass_rof;    
                              else
                              control_fsm_state <= `wait_sf;     
                 default    : control_fsm_state <= `wait_sf;
            endcase
        end
   end 
   always @(control_fsm_state)
   begin
   case (control_fsm_state)
         `wait_sf    : begin
                       sel_delay_path = 1'b0;  
                       enable_data_sr = 1'b1;  
                       end
         `bypass_sa1 : begin
                       sel_delay_path = 1'b1;  
                       enable_data_sr = 1'b0;  
                       end
         `bypass_sa2 : begin
                       sel_delay_path = 1'b1;  
                       enable_data_sr = 1'b0;  
                       end
         `bypass_sa3 : begin
                       sel_delay_path = 1'b1;  
                       enable_data_sr = 1'b0;  
                       end
         `bypass_sa4 : begin
                       sel_delay_path = 1'b1;  
                       enable_data_sr = 1'b0;  
                       end
         `bypass_sa5 : begin
                       sel_delay_path = 1'b1;  
                       enable_data_sr = 1'b0;  
                       end
         `bypass_sa6 : begin
                       sel_delay_path = 1'b1;  
                       enable_data_sr = 1'b0;  
                       end
         `pass_rof   : begin
                       sel_delay_path = 1'b0;  
                       enable_data_sr = 1'b1;  
                       end
          default    : begin
                       sel_delay_path = 1'b0;
                       enable_data_sr = 1'b1;
                       end
      endcase
   end 
endmodule
