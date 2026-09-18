// Modulo top para la placa Basys3 - Pregunta 5 (shift + ALU con xor)
// sw[4:0]   -> A
// sw[9:5]   -> B
// sw[12:10] -> ALUControl (3 bits: 000 add,001 sub,010 and,011 or,100 xor)
// sw[14:13] -> bshift
// led[4:0]  -> Result
// led[8:5]  -> ALUFlags {N,Z,C,V}
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

    assign led[4:0]  = Result;
    assign led[8:5]  = ALUFlags;
    assign led[15:9] = 7'b0;

endmodule
