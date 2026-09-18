`timescale 1ns / 1ps
// ============================================================================
// Pregunta 4 - Módulo top: Shift + ALU (5 bits, con XOR)
//
//          bshift
//            |
//   A ---> [shift] --A_desplazado--> +-------+
//                                    |  ALU  | ---> Result
//   B -----------------------------> |       | ---> ALUFlags {N,Z,C,V}
//                                    +-------+
//                                        ^
//                                   ALUControl
//
// El shift solo afecta a la entrada A; B entra directo al ALU.
// ============================================================================
module top(
    input  [4:0] A, B,
    input  [1:0] bshift,
    input  [2:0] ALUControl,
    output [4:0] Result,
    output [3:0] ALUFlags
);

    wire [4:0] A_desplazado;

    shift shift_inst (
        .A(A),
        .bshift(bshift),
        .A_desplazado(A_desplazado)
    );

    alu5_xor alu_inst (
        .a(A_desplazado),
        .b(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

endmodule
