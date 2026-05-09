`define STATE_IDLE 0
`define STATE_CALC 1
`define STATE_DONE 2
`define STATE_IDLE 0
`define STATE_CALC 1
`define STATE_DONE 2
module control_Machine
  (
    input wire Clock,
    input wire Reset,
    input wire iLSB,   
    input wire iValid_Data,
    input wire iAck,
    output reg oShift,
    output reg  oA_Sel,
    output reg oB_Sel,
    output reg oProduct_Sel,
    output reg oAdd_Sel
  );
  reg [5:0] rCounter;
  reg [1:0]rCurrentState;
  reg  [1:0]rNextState;
  reg rCountReset;
  reg firstBit;
  always @ ( posedge Clock )
    if (Reset)
      begin
        rCurrentState = `STATE_IDLE;
        rCountReset <=1'b1;
        firstBit <=1'b0;
      end
  else
		begin
      rCurrentState <= rNextState;
      if(rCountReset)
      begin
      rCounter<= 6'd0;
      end
      else
     begin
     rCounter<=  rCounter + 6'd1;
     end
		end
  always @ ( * )
    begin
      case (rCurrentState)
        `STATE_IDLE:
          begin
          rCountReset=1'b1;
          oShift=1'b0;
         oA_Sel=1'b0;
         oB_Sel=1'b0;
         oProduct_Sel=1'b0;
         oAdd_Sel=1'b0;
         if(iValid_Data)
			begin
            rNextState = `STATE_CALC;
            rCountReset=1'b0;
           firstBit=1'b1;
            end
          else
			begin
			rNextState= `STATE_IDLE;
			end
          end
      `STATE_CALC:
        begin
         oA_Sel=1'b1;
         oB_Sel=1'b1;
            oProduct_Sel=1'b1;
         if(iLSB)
         begin
           oShift=1'b1;
           oAdd_Sel=1'b1;
           end
           else
           begin
           oShift=1'b1;
           oAdd_Sel=1'b0;
           end
       if(rCounter<6'd32)
       begin
       rNextState=`STATE_CALC;
       end    
       else
       begin 
        rNextState=`STATE_DONE;
         rCountReset=1'b1;
       end
        end
      `STATE_DONE:
        begin
          rCounter= 6'd0;
          oShift=1'b0;
         oAdd_Sel=1'b0;
          if ( iAck)
            rNextState = `STATE_IDLE;
          else
            rNextState = `STATE_DONE;
        end
        default:
          begin
            rNextState = `STATE_IDLE;
          end
      endcase
    end
endmodule
