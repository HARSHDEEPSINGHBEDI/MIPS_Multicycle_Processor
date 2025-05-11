`timescale 1ns / 1ps

module alusrcb_mux (
    input [31:0] B_out,                
    input [31:0] imm_ext,              
    input [31:0] shift_left,          
    input [31:0] const_4,              
    input [1:0] ALUSrcB,               
    output reg [31:0] alu_src_b_out    
);

    always @(*) begin
        case (ALUSrcB)
            2'b00: alu_src_b_out = B_out;       
            2'b01: alu_src_b_out = const_4;     
            2'b10: alu_src_b_out = imm_ext;     
            2'b11: alu_src_b_out = shift_left;  
            default: alu_src_b_out = 32'b0;
        endcase
    end

endmodule
