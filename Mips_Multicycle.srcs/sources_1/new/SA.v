`timescale 1ns / 1ps

module alu_control (
    input [1:0] ALUOp,           
    input [5:0] funct,           
    output reg [2:0] ALU_control 
);

    always @(*) begin
    case (ALUOp)
        2'b00: ALU_control = 3'b010; 
        2'b01: ALU_control = 3'b110; 
        2'b10: begin                
            case (funct)
                6'b100000: ALU_control = 3'b010; 
                6'b100010: ALU_control = 3'b110; 
                6'b100100: ALU_control = 3'b000; 
                6'b100101: ALU_control = 3'b001;
                6'b101010: ALU_control = 3'b111; 
                6'b000010: ALU_control = 3'b011; 
                default:   ALU_control = 3'bxxx; 
            endcase
        end
        2'b11: ALU_control = 3'b100; // sltiu instr handled separate
        default: ALU_control = 3'bxxx;
    endcase
end


endmodule
