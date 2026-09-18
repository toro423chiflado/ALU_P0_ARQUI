// Testbench Pregunta 1
// Casos: 3+5, 5-5, 8 AND 1, 5 OR 7
`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] a, b;
    reg  [1:0]  ALUControl;
    wire [31:0] Result;
    wire [3:0]  ALUFlags; // {N, Z, C, V}

    alu DUT (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // Caso 1: 3 + 5 = 8
        a = 32'd3; b = 32'd5; ALUControl = 2'b00; #10;
        $display("A+B: 3+5  -> Result=%0d  Flags(NZCV)=%b", Result, ALUFlags);

        // Caso 2: 5 - 5 = 0  (activa Zero, y Carry porque no hay borrow en resta con complemento a 2)
        a = 32'd5; b = 32'd5; ALUControl = 2'b01; #10;
        $display("A-B: 5-5  -> Result=%0d  Flags(NZCV)=%b", Result, ALUFlags);

        // Caso 3: 8 AND 1 = 0
        a = 32'd8; b = 32'd1; ALUControl = 2'b10; #10;
        $display("A&B: 8&1  -> Result=%0d  Flags(NZCV)=%b", Result, ALUFlags);

        // Caso 4: 5 OR 7 = 7
        a = 32'd5; b = 32'd7; ALUControl = 2'b11; #10;
        $display("A|B: 5|7  -> Result=%0d  Flags(NZCV)=%b", Result, ALUFlags);

        #10;
        $finish;
    end

endmodule
