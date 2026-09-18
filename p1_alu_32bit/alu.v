`timescale 1ns / 1ps
// ============================================================================
// Pregunta 1 - ALU de 32 bits
// Diseño tomado de las diapositivas "P0: ALU Implementation" (Harris & Harris)
//
//   ALUControl | Operación
//   -----------+-----------------------------
//       00     | Add       Result = A + B
//       01     | Subtract  Result = A - B  (A + ~B + 1, complemento a 2)
//       10     | AND       Result = A & B
//       11     | OR        Result = A | B
//
//   ALUFlags = {N, Z, C, V}
//     N: Result negativo  -> MSB de Result
//     Z: Result es cero   -> todos los bits en 0
//     C: carry out del sumador, solo si la operación es Add/Sub
//     V: overflow con signo, solo si la operación es Add/Sub
// ============================================================================
module alu(
    input  [31:0] a, b,
    input  [1:0]  ALUControl,
    output reg  [31:0] Result,
    output wire [3:0]  ALUFlags
);

    wire        neg, zero, carry, overflow;
    wire [31:0] condinvb;   // B o ~B según la operación
    wire [32:0] sum;        // 33 bits: sum[32] es el carry out del sumador

    // ALUControl[0] = 1 -> resta: se invierte B y se suma 1 (Cin = ALUControl[0])
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum      = a + condinvb + ALUControl[0];

    always @(*) begin
        casex (ALUControl[1:0])
            2'b0?:   Result = sum[31:0];   // 00 Add / 01 Subtract
            2'b10:   Result = a & b;       // AND
            2'b11:   Result = a | b;       // OR
            default: Result = 32'b0;       // no se alcanza; evita latches
        endcase
    end

    assign neg      = Result[31];
    assign zero     = (Result == 32'b0);
    assign carry    = (ALUControl[1] == 1'b0) & sum[32];
    assign overflow = (ALUControl[1] == 1'b0) &
                      ~(a[31] ^ b[31] ^ ALUControl[0]) &
                      (a[31] ^ sum[31]);

    assign ALUFlags = {neg, zero, carry, overflow};

endmodule
