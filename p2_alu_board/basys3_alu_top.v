`timescale 1ns / 1ps
// ============================================================================
// Pregunta 2 - Top para la placa Basys3 (ALU de 5 bits)
//
//   Entradas (switches)             Salidas (LEDs)
//   sw[4:0]   -> A                  led[4:0]   -> Result
//   sw[9:5]   -> B                  led[15:12] -> ALUFlags {N,Z,C,V}
//   sw[11:10] -> ALUControl         led[11:5]  -> apagados
//   sw[15:12] -> sin uso
//
//   "los primeros 5 leds para el result y los 4 últimos para los flags":
//   led15 = N, led14 = Z, led13 = C, led12 = V  (se leen N Z C V de izq. a der.)
// ============================================================================
module basys3_alu_top(
    input  [15:0] sw,
    output [15:0] led
);

    wire [4:0] A          = sw[4:0];
    wire [4:0] B          = sw[9:5];
    wire [1:0] ALUControl = sw[11:10];

    wire [4:0] Result;
    wire [3:0] ALUFlags;

    alu5 alu_inst (
        .a(A),
        .b(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    assign led[4:0]   = Result;
    assign led[11:5]  = 7'b0;
    assign led[15:12] = ALUFlags;

endmodule
