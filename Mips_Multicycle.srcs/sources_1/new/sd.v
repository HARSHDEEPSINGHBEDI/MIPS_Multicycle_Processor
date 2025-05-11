`timescale 1ns / 1ps

module alu (
    input  [31:0] alu_src_a_out,
    input  [31:0] alu_src_b_out,
    input  [2:0]  ALU_control,
    output reg [31:0] ALUOut,
    output Zero
);

    assign Zero = (ALUOut == 0);

    always @(*) begin
        case (ALU_control)
            3'b000: ALUOut = alu_src_a_out & alu_src_b_out;
            3'b001: ALUOut = alu_src_a_out | alu_src_b_out;
            3'b010: ALUOut = alu_src_a_out + alu_src_b_out;
            3'b011: ALUOut = alu_src_b_out >> alu_src_a_out[4:0];
            3'b100: ALUOut = ($unsigned(alu_src_a_out) < $unsigned(alu_src_b_out)) ? 32'd1 : 32'd0;
            3'b110: ALUOut = alu_src_a_out - alu_src_b_out;
            3'b111: ALUOut = ($signed(alu_src_a_out) < $signed(alu_src_b_out)) ? 32'd1 : 32'd0;
            default: ALUOut = 32'hDEADBEEF;
        endcase
    end

endmodule
