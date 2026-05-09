`timescale 1ps/1ps
`timescale 1ps/1ps
module PIO_TO_CTRL #(
  parameter TCQ = 1
) (
  input               clk,
  input               rst_n,
  input               req_compl,
  input               compl_done,
  input               cfg_to_turnoff,
  output  reg         cfg_turnoff_ok
  );
  reg                 trn_pending;
  always @ ( posedge clk ) begin
    if (!rst_n )
    begin
      trn_pending <= #TCQ 0;
    end
    else
    begin
      if (!trn_pending && req_compl)
        trn_pending <= #TCQ 1'b1;
      else if (compl_done)
        trn_pending <= #TCQ 1'b0;
    end
  end
  always @ ( posedge clk ) begin
    if (!rst_n )
    begin
      cfg_turnoff_ok <= #TCQ 1'b0;
    end
    else
    begin
      if ( cfg_to_turnoff  && !trn_pending)
        cfg_turnoff_ok <= #TCQ 1'b1;
      else
        cfg_turnoff_ok <= #TCQ 1'b0;
    end
  end
endmodule 
