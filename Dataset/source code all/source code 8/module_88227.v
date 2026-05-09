`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module alt_mem_ddrx_ecc_encoder #
    ( parameter
        CFG_DATA_WIDTH              =   40,
        CFG_ECC_CODE_WIDTH          =   8,
        CFG_ECC_ENC_REG             =   0,
        CFG_MMR_DRAM_DATA_WIDTH     =   7,
        CFG_MMR_LOCAL_DATA_WIDTH    =   7,
        CFG_PORT_WIDTH_ENABLE_ECC   =   1
    )
    (
        ctl_clk,
        ctl_reset_n,
        cfg_local_data_width,
        cfg_dram_data_width,
        cfg_enable_ecc,
        input_data,
        input_ecc_code,
        input_ecc_code_overwrite,
        output_data
    );
localparam CFG_ECC_DATA_WIDTH = (CFG_DATA_WIDTH > 8) ? (CFG_DATA_WIDTH - CFG_ECC_CODE_WIDTH) : (CFG_DATA_WIDTH);
input  ctl_clk;
input  ctl_reset_n;
input  [CFG_MMR_DRAM_DATA_WIDTH   - 1 : 0] cfg_local_data_width;
input  [CFG_MMR_LOCAL_DATA_WIDTH  - 1 : 0] cfg_dram_data_width;
input  [CFG_PORT_WIDTH_ENABLE_ECC - 1 : 0] cfg_enable_ecc;
input  [CFG_DATA_WIDTH     - 1 : 0] input_data;
input  [CFG_ECC_CODE_WIDTH - 1 : 0] input_ecc_code;
input                               input_ecc_code_overwrite;
output [CFG_DATA_WIDTH - 1 : 0] output_data;
    reg  [CFG_DATA_WIDTH     - 1 : 0] int_encoder_input;
    reg  [CFG_DATA_WIDTH     - 1 : 0] int_input_data;
    reg  [CFG_ECC_CODE_WIDTH - 1 : 0] int_input_ecc_code;
    reg                               int_input_ecc_code_overwrite;
    reg  [CFG_DATA_WIDTH     - 1 : 0] int_encoder_output;
    reg  [CFG_DATA_WIDTH     - 1 : 0] output_data;
    reg  [CFG_DATA_WIDTH     - 1 : 0] int_encoder_output_modified;
    wire [CFG_ECC_DATA_WIDTH - 1 : 0] encoder_input;
    wire [CFG_DATA_WIDTH     - 1 : 0] encoder_output;
    generate
        genvar i_data;
        for (i_data = 0;i_data < CFG_DATA_WIDTH;i_data = i_data + 1)
        begin : encoder_input_per_data_width
            always @ (*)
            begin
                int_encoder_input [i_data] = input_data [i_data];
            end
        end
    endgenerate
    assign encoder_input = int_encoder_input [CFG_ECC_DATA_WIDTH - 1 : 0];
    always @ (*)
    begin
        int_encoder_output = encoder_output;
    end
    generate
        if (CFG_DATA_WIDTH <= 8)
        begin
            always @ (*)
            begin
                int_encoder_output_modified = int_encoder_output;
            end
        end
        else
        begin
            always @ (*)
            begin
                int_encoder_output_modified [CFG_ECC_DATA_WIDTH - 1 : 0] = int_encoder_output [CFG_ECC_DATA_WIDTH - 1 : 0];
                if (int_input_ecc_code_overwrite)
                begin
                    int_encoder_output_modified [CFG_DATA_WIDTH - 1 : CFG_ECC_DATA_WIDTH] = int_input_ecc_code;
                end
                else
                begin
                    int_encoder_output_modified [CFG_DATA_WIDTH - 1 : CFG_ECC_DATA_WIDTH] = int_encoder_output [CFG_DATA_WIDTH - 1 : CFG_ECC_DATA_WIDTH];
                end
            end
        end
    endgenerate
    always @ (*)
    begin
        if (cfg_enable_ecc)
            output_data = int_encoder_output_modified;
        else
            output_data = int_input_data;
    end
    generate
        if (CFG_ECC_ENC_REG)
        begin
            always @ (posedge ctl_clk or negedge ctl_reset_n)
            begin
                if (!ctl_reset_n)
                begin
                    int_input_data               <= 0;
                    int_input_ecc_code           <= 0;
                    int_input_ecc_code_overwrite <= 0;
                end
                else
                begin
                    int_input_data               <= input_data;
                    int_input_ecc_code           <= input_ecc_code;
                    int_input_ecc_code_overwrite <= input_ecc_code_overwrite;
                end
            end
        end
        else
        begin
            always @ (*)
            begin
                int_input_data               = input_data;
                int_input_ecc_code           = input_ecc_code;
                int_input_ecc_code_overwrite = input_ecc_code_overwrite;
            end
        end
    endgenerate
    generate
    begin
        if (CFG_ECC_DATA_WIDTH == 8 && CFG_DATA_WIDTH > 8) 
        begin
            wire [39 : 0] internal_encoder_output;
            assign internal_encoder_output [39] = 1'b0;
            assign encoder_output [CFG_ECC_DATA_WIDTH - 1 : 0]              = internal_encoder_output [31 :  0];
            assign encoder_output [CFG_DATA_WIDTH - 1 : CFG_ECC_DATA_WIDTH] = internal_encoder_output [39 : 32];
            alt_mem_ddrx_ecc_encoder_32 #
                (
                    .CFG_ECC_ENC_REG    (CFG_ECC_ENC_REG                 )
                )
            encoder_inst
                (
                    .clk                (ctl_clk                         ),
                    .reset_n            (ctl_reset_n                     ),
            	    .data               ({24'd0, encoder_input}          ),
                    .q                  (internal_encoder_output [38 : 0])
                );
        end
        else if (CFG_ECC_DATA_WIDTH == 16)
        begin
            wire [39 : 0] internal_encoder_output;
            assign internal_encoder_output [39] = 1'b0;
            assign encoder_output [CFG_ECC_DATA_WIDTH - 1 : 0]              = internal_encoder_output [31 :  0];
            assign encoder_output [CFG_DATA_WIDTH - 1 : CFG_ECC_DATA_WIDTH] = internal_encoder_output [39 : 32];
            alt_mem_ddrx_ecc_encoder_32 #
                (
                    .CFG_ECC_ENC_REG    (CFG_ECC_ENC_REG                 )
                )
            encoder_inst
                (
                    .clk                (ctl_clk                         ),
                    .reset_n            (ctl_reset_n                     ),
            	    .data               ({16'd0, encoder_input}          ),
                    .q                  (internal_encoder_output [38 : 0])
                );
        end
        else if (CFG_ECC_DATA_WIDTH == 32)
        begin
            assign encoder_output [39] = 1'b0;
            alt_mem_ddrx_ecc_encoder_32 #
                (
                    .CFG_ECC_ENC_REG    (CFG_ECC_ENC_REG        )
                )
            encoder_inst
                (
                    .clk                (ctl_clk                ),
                    .reset_n            (ctl_reset_n            ),
            	    .data               (encoder_input          ),
                    .q                  (encoder_output [38 : 0])
                );
        end
        else if (CFG_ECC_DATA_WIDTH == 64)
        begin
            alt_mem_ddrx_ecc_encoder_64 #
                (
                    .CFG_ECC_ENC_REG    (CFG_ECC_ENC_REG)
                )
            encoder_inst
                (
                    .clk                (ctl_clk        ),
                    .reset_n            (ctl_reset_n    ),
            	    .data               (encoder_input  ),
                    .q                  (encoder_output )
                );
        end
        else
        begin
        	assign encoder_output = {CFG_DATA_WIDTH{1'b0}};
        end        
    end
    endgenerate
endmodule
