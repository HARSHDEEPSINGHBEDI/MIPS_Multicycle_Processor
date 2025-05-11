
module IR (
    input clk,
    input reset,
    input IRWrite,
    input [31:0] mem_data_out,

    output reg [5:0] opcode, funct,
    output reg [4:0] rs, rt, rd, shamt,
    output reg [15:0] imm,
    output reg [25:0] address
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            opcode   <= 6'b0;
            funct    <= 6'b0;
            rs       <= 5'b0;
            rt       <= 5'b0;
            rd       <= 5'b0;
            shamt    <= 5'b0;
            imm      <= 16'b0;
            address  <= 26'b0;
        end
        else if (IRWrite) begin
            opcode   <= mem_data_out[31:26];
            rs       <= mem_data_out[25:21];
            rt       <= mem_data_out[20:16];
            rd       <= mem_data_out[15:11];
            shamt    <= mem_data_out[10:6];
            funct    <= mem_data_out[5:0];
            imm      <= mem_data_out[15:0];
            address  <= mem_data_out[25:0];
        end
    end

endmodule
