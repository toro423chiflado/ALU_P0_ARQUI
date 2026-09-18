// Modulo top (Pregunta 4): Shift + ALU
// El shift solo afecta a la entrada A antes de entrar a la ALU
module top(
    input  [4:0] A, B,
    input  [1:0] bshift,
    input  [2:0] ALUControl,
    output [4:0] Result,
    output [3:0] ALUFlags
);

    wire [4:0] A_shifted;

    shift shift_inst (
        .A(A),
        .bshift(bshift),
        .A_shifted(A_shifted)
    );

    alu5_xor alu_inst (
        .a(A_shifted),
        .b(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

endmodule
