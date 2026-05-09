module zscale_wrapper (
                       input wire clk,
                       input wire reset,
                       output wire [7:0] led
                       );
   wire csr_resp_valid;
   wire [63:0] csr_resp_data;
   wire [31:0] io_bootmem_haddr;
   wire        io_bootmem_hwrite;
   wire [2:0]  io_bootmem_hsize;
   wire [2:0]  io_bootmem_hburst;
   wire [3:0]  io_bootmem_hprot;
   wire [1:0]  io_bootmem_htrans;
   wire        io_bootmem_hmastlock;
   wire [31:0] io_bootmem_hwdata;
   wire [31:0] io_bootmem_hrdata;
   wire        io_bootmem_hsel;
   wire        io_bootmem_hreadyin;
   wire        io_bootmem_hreadyout;
   wire        io_bootmem_hresp;
   wire [31:0] io_led_paddr;
   wire        io_led_pwrite;
   wire        io_led_psel;
   wire        io_led_penable;
   wire [31:0] io_led_pwdata;
   wire [31:0] io_led_prdata;
   wire        io_led_pready;
   wire        io_led_pslverr;
   reg         led_ready;
   reg [31:0]  led_reg;
   assign led = led_reg[7:0];
ZscaleTop zs(
             .clk(clk),
             .reset(reset),
             .io_host_reset(reset),
             .io_host_id(1'b0),
             .io_host_pcr_req_ready(),
             .io_host_pcr_req_valid(1'b1),
             .io_host_pcr_req_bits_rw(1'b0),
             .io_host_pcr_req_bits_addr(12'h780), 
             .io_host_pcr_req_bits_data(64'd0),
             .io_host_pcr_rep_ready(1'b1),
             .io_host_pcr_rep_valid(csr_resp_valid),
             .io_host_pcr_rep_bits(csr_resp_data),
             .io_host_ipi_req_ready(1'b1),
             .io_host_ipi_req_valid(),
             .io_host_ipi_req_bits(),
             .io_host_ipi_rep_ready(),
             .io_host_ipi_rep_valid(1'b0),
             .io_host_ipi_rep_bits(),
             .io_host_debug_stats_pcr(),
             .io_bootmem_haddr(io_bootmem_haddr),
             .io_bootmem_hwrite(io_bootmem_hwrite),
             .io_bootmem_hsize(io_bootmem_hsize),
             .io_bootmem_hburst(io_bootmem_hburst),
             .io_bootmem_hprot(io_bootmem_hprot),
             .io_bootmem_htrans(io_bootmem_htrans),
             .io_bootmem_hmastlock(io_bootmem_hmastlock),
             .io_bootmem_hwdata(io_bootmem_hwdata),
             .io_bootmem_hrdata(io_bootmem_hrdata),
             .io_bootmem_hsel(io_bootmem_hsel),
             .io_bootmem_hreadyin(io_bootmem_hreadyin),
             .io_bootmem_hreadyout(io_bootmem_hreadyout),
             .io_bootmem_hresp(io_bootmem_hresp),
             .io_led_paddr(io_led_paddr),
             .io_led_pwrite(io_led_pwrite),
             .io_led_psel(io_led_psel),
             .io_led_penable(io_led_penable),
             .io_led_pwdata(io_led_pwdata),
             .io_led_prdata(io_led_prdata),
             .io_led_pready(io_led_pready),
             .io_led_pslverr(io_led_pslverr)
             );
   assign io_led_pslverr = 1'b0;
   assign io_led_pready = led_ready;
   assign io_led_prdata = led_reg;
   always @(posedge reset or posedge clk)
     begin
        if (reset)
          begin
             led_reg = 32'h80;
             led_ready = 1'b0;
          end
        else
          begin
             if (clk)
               begin
                  if (led_ready && io_led_penable)
                    begin
                       led_reg = io_led_pwdata;
                       led_ready = 1'b0;
                    end
                  else
                    if (io_led_psel && io_led_paddr == 32'h80000000)
                      begin
                         led_ready = 1'b1;
                      end
                    else
                      begin
                         led_ready = 1'b0;
                      end
               end
          end
     end
   ROM bm (
           .clk(clk),
           .reset(reset),
           .haddr(io_bootmem_haddr),
           .hwrite(io_bootmem_hwrite),
           .hsize(io_bootmem_hsize),
           .hburst(io_bootmem_hburst),
           .hprot(io_bootmem_hprot),
           .htrans(io_bootmem_htrans),
           .hmastlock(io_bootmem_hmastlock),
           .hwdata(32'd0),
           .hrdata(io_bootmem_hrdata),
           .hsel(io_bootmem_hsel),
           .hreadyin(io_bootmem_hreadyin),
           .hreadyout(io_bootmem_hreadyout),
           .hresp(io_bootmem_hresp)
           );
endmodule
