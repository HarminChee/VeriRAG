`define FLOP_RETRY_USE_FLOPS 1
`define USE_SELF_W2R1 1
`define FLOP_RETRY_USE_FLOPS 1
`define USE_SELF_W2R1 1
module fflop
  #(parameter Size=1)
    (input                     clk
     ,input                    reset
     ,input  logic [Size-1:0]  din
     ,input  logic             dinValid
     ,output logic             dinRetry
     ,output logic [Size-1:0]  q
     ,input  logic             qRetry
     ,output logic             qValid
     );
`ifdef USE_SELF_W2R1
  logic [Size-1:0] shadowq;
  logic c1;
  logic c2;
  logic shadowValid;
  logic          priv_qValid;
  always_comb begin
    qValid = priv_qValid;
  end
  logic          priv_dinRetry;
  always_comb begin
    dinRetry = priv_dinRetry;
  end
  logic          priv_qRetry;
  always_comb begin
    priv_qRetry = qRetry;
  end
  logic          priv_dinValid;
  always_comb begin
    priv_dinValid = dinValid;
  end
  always_comb begin
    c1 = (priv_qValid & priv_qRetry); 
    c2 = priv_dinValid | shadowValid; 
  end
  always @(posedge clk) begin
    if (reset) begin
      shadowValid <= 'b0;
    end else begin
      shadowValid <= (c1 & c2);
    end 
  end 
  logic s_enable;
  always_comb begin
    s_enable = !shadowValid;
  end
  always@ (posedge clk) begin
    if (s_enable) begin
      shadowq <= din;
    end
  end 
  always @(posedge clk) begin
    if (c1) begin
      q <= q;
    end else if (s_enable) begin
      q <= din;
    end else begin
      q <= shadowq;
    end
  end 
  logic priv_qValidla2;
  always @(posedge clk) begin
    if (reset) begin
      priv_qValidla2 <='b0;
    end else begin
      priv_qValidla2 <= (c1 | c2);
    end 
  end 
  always_comb begin
    priv_qValid = priv_qValidla2;
  end
  always_comb begin
   priv_dinRetry = shadowValid | reset;
  end
`else
  logic [Size-1:0] shadowq;
  logic c1;
  logic c2;
  logic shadowValid;
  logic          priv_qValid;
  always @
    qValid = priv_qValid;
  end
  logic          priv_dinRetry;
  always @
    dinRetry = priv_dinRetry;
  end
  logic          priv_qRetry;
  always @
    priv_qRetry = qRetry;
  end
  logic          priv_dinValid;
  always @
    priv_dinValid = dinValid;
  end
  always @
    c1 = (priv_qValid & priv_qRetry); 
    c2 = priv_dinValid | shadowValid; 
  end
`ifdef FLOP_RETRY_USE_FLOPS
  always @(posedge clk) begin
    if (reset) begin
      shadowValid <= 'b0;
    end else begin
      shadowValid <= (c1 & c2);
    end 
  end 
`else 
  logic shadowValid_nclk;
  always_latch begin
    if (~clk) begin
      if (reset) begin
        shadowValid_nclk<= 'b0;
      end else begin
        shadowValid_nclk<= (c1 & c2); 
      end
    end
  end
  always_latch begin
    if (clk) begin
      shadowValid <= shadowValid_nclk;
    end
  end
`endif 
  logic s_enable;
  always @
    s_enable = !shadowValid;
  end
  always@ (posedge clk) begin
    if (s_enable) begin
      shadowq <= din;
    end
  end 
  logic q_enable;
`ifdef FLOP_RETRY_USE_FLOPS
  always @(negedge clk) begin
    q_enable <= !c1; 
  end
`else
  always @
    if (!clk) begin
       q_enable <= !c1; 
    end
  end
`endif
  always @ (negedge clk) begin
      if (q_enable) begin
        q <= shadowq;
      end 
  end 
  logic priv_qValidla2;
`ifdef FLOP_RETRY_USE_FLOPS
  always @(posedge clk) begin
    if (reset) begin
      priv_qValidla2 <='b0;
    end else begin
      priv_qValidla2 <= (c1 | c2);
    end 
  end 
`else 
  logic priv_qValidla;
  always_latch begin
    if (~clk) begin
      if (reset) begin
        priv_qValidla    <= 'b0;
      end else begin
        priv_qValidla    <= (c1 | c2);
      end
    end
  end
  always_latch begin
    if (clk) begin
      priv_qValidla2 <= priv_qValidla;
    end
  end
`endif 
  always @
    priv_qValid = priv_qValidla2;
  end
  always @
   priv_dinRetry = shadowValid | reset;
  end
`endif
endmodule 
