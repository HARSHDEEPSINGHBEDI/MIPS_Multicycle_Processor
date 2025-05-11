`timescale 1ns / 1ps

module pc_source_mux (
    input  [1:0]  PCSource,
    input  [31:0] ALUOut,
    input  [31:0] aluoutreg,
    input  [31:0] jump_address,
    output reg [31:0] pc_in
);

    always @(*) begin
        case (PCSource)
            2'b00: pc_in = ALUOut;
            2'b01: pc_in = aluoutreg;
            2'b10: pc_in = jump_address;
            default: pc_in = 32'bx;
        endcase
    end

endmodule
