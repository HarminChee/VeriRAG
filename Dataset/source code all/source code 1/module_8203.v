module uc(input wire clock,reset,z, input wire [1:0] id_out, input wire [5:0] opcode, 
          output reg s_inc, s_inm, we3, rwe1, rwe2, rwe3, rwe4, sec, sece, s_es, s_rel, swe, s_ret, output wire [2:0] op);
  assign op = opcode[2:0];
  always @(*)
  begin
    rwe1 <= 1'b0;      
    rwe2 <= 1'b0;      
    rwe3 <= 1'b0;      
    rwe4 <= 1'b0;      
    swe <= 1'b0;      
    s_ret <= 1'b0;    
    sece <= 1'b0;     
    if (reset == 1'b1)
    begin
      we3 <= 1'b0;   
      s_inm <= 1'b0; 
      s_inc <= 1'b1; 
      sec <= 1'b0;      
      sece <= 1'b0;     
      s_es <= 1'b0;     
      s_rel <= 1'b0;    
      swe <= 1'b0;      
      s_ret <= 1'b0;    
    end
    else
    begin
      casex (opcode)              
        6'bxx0xxx:
        begin
          we3 <= 1'b1;       
          s_inm <= 1'b0;     
          s_inc <= 1'b1;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
        end
        6'bxx1010:
        begin
          we3 <= 1'b1;       
          s_inm <= 1'b1;     
          s_inc <= 1'b1;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
        end
        6'bxx1001:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          s_inc <= 1'b0;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
        end
        6'bxx1011:
        begin
          we3 <= 1'b1;       
          s_inm <= 1'b0;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b1;     
          s_inc <= 1'b1;   
          s_rel <= 1'b0;    
        end
        6'bxx1101:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          sec <= 1'b1;      
          sece <= 1'b1;     
          s_es <= 1'b0;     
          s_inc <= 1'b1;   
          s_rel <= 1'b0;    
          if (id_out == 2'b00)
            rwe1 <= 1'b1;
          else if(id_out == 2'b01)
            rwe2 <= 1'b1;
          else if(id_out == 2'b10)
            rwe3 <= 1'b1;
          else
            rwe4 <= 1'b1;                      
        end
        6'bxx1110:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          sec <= 1'b0;      
          sece <= 1'b1;     
          s_es <= 1'b0;     
          s_inc <= 1'b1;   
          s_rel <= 1'b0;    
          if (id_out == 2'b00)
            rwe1 <= 1'b1;
          else if(id_out == 2'b01)
            rwe2 <= 1'b1;
          else if(id_out == 2'b10)
            rwe3 <= 1'b1;
          else
            rwe4 <= 1'b1;              
        end                
        6'b011111:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
          if (z == 1'b0)
            s_inc <= 1'b0;   
          else
            s_inc <= 1'b1;   
        end
        6'b001111:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
          if (z == 1'b0)
            s_inc <= 1'b1;   
          else
            s_inc <= 1'b0;   
        end
        6'b011000:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          s_inc <= 1'b1;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b1;    
        end
        6'b101000:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          s_inc <= 1'b0;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
          swe <= 1'b1;      
        end
        6'b111000:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          s_inc <= 1'b0;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
          s_ret <= 1'b1;    
        end
        6'b111111:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          s_inc <= 1'b1;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
          s_ret <= 1'b0;    
        end
        default:
        begin
          we3 <= 1'b0;       
          s_inm <= 1'b0;     
          s_inc <= 1'b1;     
          sec <= 1'b0;      
          sece <= 1'b0;     
          s_es <= 1'b0;     
          s_rel <= 1'b0;    
          s_ret <= 1'b0;    
        end
      endcase
    end
  end
endmodule
