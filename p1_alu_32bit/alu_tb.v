`timescale 1ns / 1ps
// ============================================================================
// Testbench Pregunta 1 - ALU de 32 bits
// Casos pedidos: 3+5, 5-5, 8 AND 1, 5 OR 7
// Es auto-verificable: compara Result y ALUFlags contra el valor esperado.
//
// Tip Vivado: la señal "caso" se puede ver como texto
//   (clic derecho sobre la señal -> Radix -> ASCII)
// ============================================================================
module alu_tb;

    reg  [31:0] a, b;
    reg  [1:0]  ALUControl;
    wire [31:0] Result;
    wire [3:0]  ALUFlags;                 // {N, Z, C, V}

    // Banderas separadas para verlas como trazas individuales en el waveform
    wire N = ALUFlags[3];
    wire Z = ALUFlags[2];
    wire C = ALUFlags[1];
    wire V = ALUFlags[0];

    reg  [8*8-1:0] caso;                  // etiqueta del caso (8 caracteres)
    integer errores = 0;
    integer total   = 0;

    alu DUT (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    task aplicar(input [8*8-1:0] nombre,
                 input [31:0]    va,
                 input [31:0]    vb,
                 input [1:0]     ctrl,
                 input [31:0]    expRes,
                 input [3:0]     expFlags);
        begin
            caso = nombre; a = va; b = vb; ALUControl = ctrl;
            #10;
            total = total + 1;
            if (Result !== expRes || ALUFlags !== expFlags) begin
                errores = errores + 1;
                $display("[FAIL] %s | ALUControl=%b | Result=%0d NZCV=%b | esperado Result=%0d NZCV=%b",
                         nombre, ctrl, Result, ALUFlags, expRes, expFlags);
            end else
                $display("[ OK ] %s | ALUControl=%b | Result=%0d (0x%h) | NZCV=%b",
                         nombre, ctrl, Result, Result, ALUFlags);
        end
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");      // para Icarus/EDA Playground (Vivado lo ignora sin problema)
        $dumpvars(0, alu_tb);

        //        caso      A      B      ctrl   Result  NZCV
        aplicar("3+5",     32'd3, 32'd5, 2'b00, 32'd8, 4'b0000);
        aplicar("5-5",     32'd5, 32'd5, 2'b01, 32'd0, 4'b0110); // Z=1, C=1 (no hubo borrow)
        aplicar("8 and 1", 32'd8, 32'd1, 2'b10, 32'd0, 4'b0100); // Z=1
        aplicar("5 or 7",  32'd5, 32'd7, 2'b11, 32'd7, 4'b0000);

        $display("RESUMEN P1: %0d/%0d casos correctos", total - errores, total);
        #10 $finish;
    end

endmodule
