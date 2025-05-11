`timescale 1ns / 1ps

module reg_file (
    input  clk,
    input  reset,
    input  RegWrite,
    input  [4:0] rs,
    input  [4:0] rt,
    input  [4:0] write_reg,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
// here i have made a reg file of 32*32 bits

    reg [31:0] registers [0:31];
    integer i;

    assign read_data1 = registers[rs];
    assign read_data2 = registers[rt];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (RegWrite && write_reg != 5'd0) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule
