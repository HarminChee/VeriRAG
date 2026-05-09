module control_DAT(input logic writeRead,
                   input logic multiblock,
                   input logic timeoutenable,
                   input logic  [15:0] timeout ,
                   input logic newService,
                   input logic clock,
                   input logic reset,
                   input logic[3:0] blockSize,
                   input logic IDLE_in,
                   input logic fifo_full,
                   input logic recibido,
                   input logic transferComplete,
                   output  logic newService_fisica,
                   output  logic [15:0]  timeout_fisica,
                   output  logic writeRead_fisica,
                   output  logic reset_fisica,
                   output  logic complete,
                   output logic IDLE_out
                  );
  parameter RESET=6'b000001, IDLE  = 6'b000010, checkfifo  = 6'b000100 ,solicitud=6'b001000 , waitResponse= 6'b010000 ,  waitIdle= 6'b100000  ;
  reg [5:0] state;
  reg [5:0] next_state;
  reg [4:0] blockCount;
  reg [4:0] blockCountFlip;
  always @ ( posedge clock ) begin
    if (reset == 1'b1) begin
      state <=    RESET;
    end else begin
      state <=   next_state;
    end
  end
  always @ (posedge clock)begin
    if (reset == 1'b1) begin
      newService_fisica<=1'b0;
      timeout_fisica<=16'b0000000000000000;
      writeRead_fisica<=1'b0;
      reset_fisica<=1'b1;
      complete<=1'b0;
      IDLE_out<=1'b0;
      blockCountFlip<=5'b00000 ;
    end
    else begin
      case(state)
        RESET : begin
          newService_fisica<=1'b0;
          timeout_fisica<=16'b0000000000000000;
          writeRead_fisica<=1'b0;
          reset_fisica<=1'b0;
          complete<=1'b0;
          IDLE_out<=1'b0;
          blockCountFlip<=5'b00000 ;
        end
        IDLE : begin
          newService_fisica<=1'b0;
          timeout_fisica<=16'b0000000000000000;
          writeRead_fisica<=1'b0;
          reset_fisica<=1'b0;
          complete<=1'b0;
          IDLE_out<=1'b1;
          blockCountFlip<=5'b00000 ;
        end
        checkfifo : begin
          newService_fisica<=1'b0;
          if (timeoutenable==1'b1) begin
            timeout_fisica<=timeout;
          end
          else begin
            timeout_fisica<=16'b0000000000000000;
          end
          writeRead_fisica<=writeRead;
          reset_fisica<=1'b0;
          complete<=1'b0;
          IDLE_out<=1'b0;
          blockCountFlip<=blockCount ;
        end
        solicitud : begin 
          newService_fisica<=1'b1;
          writeRead_fisica<=writeRead;
          reset_fisica<=1'b0;
          complete<=1'b0;
          IDLE_out<=1'b0;
          blockCountFlip<=blockCount ;
        end
        waitResponse : begin
          newService_fisica<=1'b0;
          writeRead_fisica<=writeRead;
          reset_fisica<=1'b0;
          complete<=1'b0;
          IDLE_out<=1'b0;
          blockCountFlip<=blockCount ;
        end
        waitIdle : begin
          newService_fisica<=1'b0;
          writeRead_fisica<=writeRead;
          reset_fisica<=1'b0;
          complete<=1'b1;
          IDLE_out<=1'b0;
          blockCountFlip<=blockCount ;
        end
        default : begin
          newService_fisica<=1'b0;
          timeout_fisica<=16'b0000000000000000;
          writeRead_fisica<=1'b0;
          reset_fisica<=1'b0;
          complete<=1'b0;
          IDLE_out<=1'b0;
          blockCountFlip<=blockCount ;
        end
      endcase
    end
  end 
  always @ ( * ) begin
    next_state = 6'b000000;
    blockCount=blockCountFlip;
  case(state)
    RESET : if (IDLE_in== 1'b1)begin
      next_state=IDLE;
      blockCount=5'b00000 ;
    end
    else begin
next_state=RESET;
blockCount=5'b00000 ;
    end
    IDLE :if (newService== 1'b1) begin
      next_state=checkfifo;
      blockCount=5'b00000 ;
    end
    else begin
next_state=IDLE;
blockCount=5'b00000 ;
    end
    checkfifo :if (fifo_full== 1'b1)  begin
      next_state=solicitud;
    end
    else begin
next_state=checkfifo;
    end
    solicitud :if (recibido== 1'b1) begin
      next_state=waitResponse;
    end
    else  begin
next_state=solicitud;
    end
    waitResponse :if (transferComplete== 1'b1)  begin
      next_state=waitIdle;
    end
    else  begin
next_state=waitResponse;
    end
    waitIdle:
     if (IDLE_in== 1'b1) begin
       if ((multiblock==0)||(blockCountFlip==blockSize)) begin
          next_state=IDLE;
blockCount=5'b00000 ;
        end
    else   begin
          blockCount=blockCountFlip+5'b00001;
          next_state=checkfifo;
        end
end
else  begin
next_state=waitIdle;
end
    default : begin
      next_state=IDLE;
    end
  endcase
  end
endmodule
