`timescale 1ns / 1ps


module sign_ext (
    input [15:0] imm,            
    input ExtSel,                // Control: 1 = sign-extend, 0 = zero-extend
    output reg [31:0] imm_ext    
);

    always @(*) begin
        case (ExtSel)
            1'b1: imm_ext = {{16{imm[15]}}, imm};  // Sign-extend
            1'b0: imm_ext = {16'b0, imm};          // Zero-extend for sltiu instruction only
            default: imm_ext = 32'bx;             
        endcase
    end

endmodule


