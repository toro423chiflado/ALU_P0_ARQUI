`timescale 1ns / 1ps
// ============================================================================
// Pregunta 3 - ALU de 5 bits + XOR
// Al agregar una 5ta operación, ALUControl pasa de 2 a 3 bits:
//
//   ALUControl | Operación
//   -----------+----------------------------
//      000     | Add        (Sum, Cin = 0)
//      001     | Subtract   (Sum, Cin = 1, ~B)
//      010     | AND
//      011     | OR
//      100     | XOR        <- nueva ("??" en la diapositiva)
//    101..111  | sin uso -> Result = 0
//
//   ALUFlags = {N, Z, C, V}
//   C y V solo valen en Add/Sub. Antes se detectaba con ALUControl[1] == 0;
//   ahora hay que mirar ALUControl[2:1] == 00, porque XOR (100) también
//   tiene ALUControl[1] = 0 y NO es una operación del sumador.
// ============================================================================
module alu5_xor(
    input  [4:0] a, b,
    input  [2:0] ALUControl,
    output reg  [4:0] Result,
    output wire [3:0] ALUFlags
);

    wire       neg, zero, carry, overflow;
    wire       isAddSub;     // 1 si la operación es Add (000) o Sub (001)
    wire [4:0] condinvb;
    wire [5:0] sum;          // sum[5] = carry out

    assign isAddSub = (ALUControl[2:1] == 2'b00);
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum      = a + condinvb + ALUControl[0];

    always @(*) begin
        case (ALUControl)
            3'b000:  Result = sum[4:0];   // Add
            3'b001:  Result = sum[4:0];   // Subtract
            3'b010:  Result = a & b;      // AND
            3'b011:  Result = a | b;      // OR
            3'b100:  Result = a ^ b;      // XOR
            default: Result = 5'b0;       // códigos sin uso
        endcase
    end

    assign neg      = Result[4];
    assign zero     = (Result == 5'b0);
    assign carry    = isAddSub & sum[5];
    assign overflow = isAddSub &
                      ~(a[4] ^ b[4] ^ ALUControl[0]) &
                      (a[4] ^ sum[4]);

    assign ALUFlags = {neg, zero, carry, overflow};

endmodule
