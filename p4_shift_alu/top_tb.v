// Testbench Pregunta 4
// B = 0, ALUControl = Add (000), variamos bshift para notar el efecto del shift
`timescale 1ns/1ps

module top_tb;

    reg  [4:0] A, B;
    reg  [1:0] bshift;
    reg  [2:0] ALUControl;
    wire [4:0] Result;
    wire [3:0] ALUFlags;

    top DUT (
        .A(A),
        .B(B),
        .bshift(bshift),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        B = 5'd0; ALUControl = 3'b000; // Result = A_shifted + 0

        A = 5'd3; bshift = 2'd0; #10;
        $display("A=%0d bshift=%0d -> Result=%0d (esperado %0d)", A, bshift, Result, A << bshift);

        A = 5'd3; bshift = 2'd1; #10;
        $display("A=%0d bshift=%0d -> Result=%0d (esperado %0d)", A, bshift, Result, A << bshift);

        A = 5'd3; bshift = 2'd2; #10;
        $display("A=%0d bshift=%0d -> Result=%0d (esperado %0d)", A, bshift, Result, A << bshift);

        A = 5'd1; bshift = 2'd3; #10;
        $display("A=%0d bshift=%0d -> Result=%0d (esperado %0d)", A, bshift, Result, A << bshift);

        #10;
        $finish;
    end

endmodule
