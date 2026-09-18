`timescale 1ns / 1ps
// ============================================================================
// Pregunta 2 - ALU de 5 bits (misma lógica que alu.v, adaptada a N = 5)
// A y B de 5 bits para poder ingresarlos con los switches de la Basys3.
//   Rango sin signo: 0..31    Rango con signo (C2): -16..15
//
//   ALUControl: 00 Add | 01 Subtract | 10 AND | 11 OR
//   ALUFlags  : {N, Z, C, V}
// ============================================================================
module alu5(
    input  [4:0] a, b,
    input  [1:0] ALUControl,
    output reg  [4:0] Result,
    output wire [3:0] ALUFlags
);

    wire       neg, zero, carry, overflow;
    wire [4:0] condinvb;
    wire [5:0] sum;          // sum[5] = carry out

    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum      = a + condinvb + ALUControl[0];

    always @(*) begin
        casex (ALUControl[1:0])
            2'b0?:   Result = sum[4:0];   // Add / Subtract
            2'b10:   Result = a & b;      // AND
            2'b11:   Result = a | b;      // OR
            default: Result = 5'b0;
        endcase
    end

    assign neg      = Result[4];
    assign zero     = (Result == 5'b0);
    assign carry    = (ALUControl[1] == 1'b0) & sum[5];
    assign overflow = (ALUControl[1] == 1'b0) &
                      ~(a[4] ^ b[4] ^ ALUControl[0]) &
                      (a[4] ^ sum[4]);

    assign ALUFlags = {neg, zero, carry, overflow};

endmodule
