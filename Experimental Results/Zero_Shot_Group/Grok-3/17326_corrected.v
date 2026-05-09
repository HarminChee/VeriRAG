module yuv422_to_yuv444
(
    input  wire         iCLK,
    input  wire         iRST_N, 
    input  wire [15:0]  iYCbCr,
    input  wire         iYCbCr_valid,
    output wire [7:0]   oY,
    output wire [7:0]   oCb,
    output wire [7:0]   oCr,
    output wire         oYCbCr_valid
);
reg         every_other;
reg [7:0]   mY;
reg [7:0]   mCb;
reg [7:0]   mCr;
reg [7:0]   mCb_prev;  
reg [7:0]   mCr_prev;  
reg         mValid;

assign oY           = mY;
assign oCb          = every_other ? mCb_prev : mCb;  
assign oCr          = every_other ? mCr : mCr_prev;  
assign oYCbCr_valid = mValid;

always@(posedge iCLK or negedge iRST_N)
begin
    if(!iRST_N)
        begin
            every_other <= 0;
            mY          <= 0;
            mCb         <= 0;
            mCr         <= 0;
            mCb_prev    <= 0;
            mCr_prev    <= 0;
            mValid      <= 0;
        end
    else if(iYCbCr_valid)
        begin
            every_other <= ~every_other;
            mValid      <= iYCbCr_valid;
            mY          <= iYCbCr[15:8];  
            if(every_other)
                begin
                    mCr      <= iYCbCr[7:0];
                    mCr_prev <= iYCbCr[7:0];
                end
            else
                begin
                    mCb      <= iYCbCr[7:0];
                    mCb_prev <= iYCbCr[7:0];
                end
        end
end
endmodule