`timescale 1ns / 1ps
// ============================================================================
// Pregunta 5 - Top para la placa Basys3 (Shift + ALU con XOR)
//
//   Entradas (switches)             Salidas (LEDs)
//   sw[4:0]   -> A                  led[4:0]   -> Result
//   sw[9:5]   -> B                  led[15:12] -> ALUFlags {N,Z,C,V}
//   sw[12:10] -> ALUControl         led[11:5]  -> apagados
//   sw[14:13] -> bshift
//   sw[15]    -> sin uso
//
//   ALUControl: 000 add | 001 sub | 010 and | 011 or | 100 xor
//   led15 = N, led14 = Z, led13 = C, led12 = V
// ============================================================================
module basys3_top(
    input  [15:0] sw,
    output [15:0] led
);

    wire [4:0] A          = sw[4:0];
    wire [4:0] B          = sw[9:5];
    wire [2:0] ALUControl = sw[12:10];
    wire [1:0] bshift     = sw[14:13];

    wire [4:0] Result;
    wire [3:0] ALUFlags;

    top top_inst (
        .A(A),
        .B(B),
        .bshift(bshift),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    assign led[4:0]   = Result;
    assign led[11:5]  = 7'b0;
    assign led[15:12] = ALUFlags;

endmodule
