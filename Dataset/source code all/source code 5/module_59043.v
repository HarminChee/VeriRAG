module raw2rgb( 
    oRed,
    oGreen,
    oBlue,
    oDVAL,
    iX_Cont,
    iY_Cont,
    iDATA,
    iDVAL,
    iCLK,
    iRST
    );
    input   [10:0]  iX_Cont;
    input   [10:0]  iY_Cont;
    input   [11:0]  iDATA;
    input           iDVAL;
    input           iCLK;
    input           iRST;
    output  [11:0]  oRed;
    output  [11:0]  oGreen;
    output  [11:0]  oBlue;
    output          oDVAL;
reg     [11:0]  mCCD_R;
reg     [12:0]  mCCD_G;
reg     [11:0]  mCCD_B;
reg             mDVAL;
reg     [11:0]  upper_row_pixel;
reg     [11:0]  upper_row_pixel_delayed;
reg     [11:0]  lower_row_pixel;
reg     [11:0]  lower_row_pixel_delayed;
wire            fifo_read_en;
wire            fifo_write_en;
wire    [11:0]  fifo_data_out;
onchip_fifo fifo(
        .clock(iCLK),
        .aclr(!iRST),
        .rdreq(fifo_read_en),
        .wrreq(fifo_write_en),
        .data(iDATA),
        .q(fifo_data_out)
    );
    assign fifo_write_en = iDVAL & !iY_Cont[0];
    assign fifo_read_en = iDVAL & iY_Cont[0];
assign  oRed    =   mCCD_R[11:0];
assign  oGreen  =   mCCD_G[12:1];
assign  oBlue   =   mCCD_B[11:0];
assign  oDVAL   =   mDVAL;
always@(posedge iCLK or negedge iRST)
begin
    if(!iRST)
    begin
        mCCD_R  <=  0;
        mCCD_G  <=  0;
        mCCD_B  <=  0;
        upper_row_pixel_delayed <= 0;
        upper_row_pixel         <= 0;
        lower_row_pixel_delayed <= 0;
        lower_row_pixel         <= 0;
        mDVAL   <=  0;
    end
    else
    begin
        upper_row_pixel_delayed <= upper_row_pixel;
        upper_row_pixel         <= fifo_data_out;
        lower_row_pixel_delayed <= lower_row_pixel;
        lower_row_pixel         <= iDATA;
        mDVAL       <=  {iY_Cont[0] & iX_Cont[0]} ? iDVAL : 1'b0;
        if ({iY_Cont[0],iX_Cont[0]}==2'b11) begin
            mCCD_R  <=  lower_row_pixel;
            mCCD_G  <=  upper_row_pixel + lower_row_pixel_delayed;
            mCCD_B  <=  upper_row_pixel_delayed;
        end
    end
end
endmodule
