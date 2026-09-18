// Testbench Pregunta 3
// Casos: 3+5, 5-5, 8 AND 1, 5 OR 7, 9 XOR 6
`timescale 1ns/1ps

module alu5_xor_tb;

    reg  [4:0] a, b;
    reg  [2:0] ALUControl;
    wire [4:0] Result;
    wire [3:0] ALUFlags; // {N, Z, C, V}

    alu5_xor DUT (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    initial begin
        $dumpfile("alu5_xor_tb.vcd");
        $dumpvars(0, alu5_xor_tb);

        a = 5'd3; b = 5'd5; ALUControl = 3'b000; #10;
        $display("3+5    -> Result=%0d Flags(NZCV)=%b", Result, ALUFlags);

        a = 5'd5; b = 5'd5; ALUControl = 3'b001; #10;
        $display("5-5    -> Result=%0d Flags(NZCV)=%b", Result, ALUFlags);

        a = 5'd8; b = 5'd1; ALUControl = 3'b010; #10;
        $display("8&1    -> Result=%0d Flags(NZCV)=%b", Result, ALUFlags);

        a = 5'd5; b = 5'd7; ALUControl = 3'b011; #10;
        $display("5|7    -> Result=%0d Flags(NZCV)=%b", Result, ALUFlags);

        a = 5'd9; b = 5'd6; ALUControl = 3'b100; #10;
        $display("9^6    -> Result=%0d Flags(NZCV)=%b", Result, ALUFlags);

        #10;
        $finish;
    end

endmodule
