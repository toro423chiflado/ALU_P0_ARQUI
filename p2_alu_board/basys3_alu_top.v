// Modulo top para la placa Basys3 - Pregunta 2
// sw[4:0]   -> A
// sw[9:5]   -> B
// sw[11:10] -> ALUControl
// led[4:0]  -> Result
// led[8:5]  -> ALUFlags {N,Z,C,V}
module basys3_alu_top(
    input  [15:0] sw,
    output [15:0] led
);

    wire [4:0] a          = sw[4:0];
    wire [4:0] b          = sw[9:5];
    wire [1:0] ALUControl = sw[11:10];

    wire [4:0] Result;
    wire [3:0] ALUFlags;

    alu5 alu_inst (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    assign led[4:0]  = Result;
    assign led[8:5]  = ALUFlags;
    assign led[15:9] = 7'b0;

endmodule
