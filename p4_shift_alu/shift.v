`timescale 1ns / 1ps
// ============================================================================
// Pregunta 4 - Módulo shift
// Desplaza A a la izquierda 'bshift' posiciones (0..3) y entrega A_desplazado.
// Referencia: operador << de Verilog (nandland.com/shift-operator)
//
//   - Por la derecha entran ceros.
//   - A_desplazado es de 5 bits: los bits que salen por la izquierda se pierden.
//     Ej: 5 = 00101, bshift = 3 -> 101000 -> se queda 01000 = 8
//   - Mientras no se pierdan bits, A << n equivale a A * 2^n.
// ============================================================================
module shift(
    input  [4:0] A,
    input  [1:0] bshift,
    output [4:0] A_desplazado
);

    assign A_desplazado = A << bshift;

endmodule
