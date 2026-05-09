module acl_iface_address_to_bankaddress #(    
    parameter integer ADDRESS_W = 32,               
    parameter integer NUM_BANKS = 2,                
    parameter integer BANK_SEL_BIT = ADDRESS_W-$clog2(NUM_BANKS)
)
(
    input  logic [ADDRESS_W-1:0] address,
    output logic [NUM_BANKS-1:0] bank_sel_1hot,   
    output logic [$clog2(NUM_BANKS)-1:0] bank_sel_fe,   
    output logic [ADDRESS_W-$clog2(NUM_BANKS)-1:0] bank_address
);
integer i;
logic [ADDRESS_W:0] wider_address;
assign wider_address = {1'b0,address};
always@*
begin
  for (i=0; i<NUM_BANKS; i=i+1)
    bank_sel_1hot[i] = (wider_address[BANK_SEL_BIT+$clog2(NUM_BANKS)-1 : BANK_SEL_BIT] == i);
end
always@*
begin
  bank_sel_fe = (wider_address>>BANK_SEL_BIT) & ~(64'b1<<$clog2(NUM_BANKS));
end
assign bank_address = ((address>>(BANK_SEL_BIT+$clog2(NUM_BANKS)))<<(BANK_SEL_BIT)) |
    address[BANK_SEL_BIT-1:0];
endmodule
