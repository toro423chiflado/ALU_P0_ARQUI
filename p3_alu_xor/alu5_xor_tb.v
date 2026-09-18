`timescale 1ns / 1ps
// ============================================================================
// Testbench Pregunta 3 - ALU de 5 bits + XOR
// Casos pedidos (0-50 ns): 3+5, 5-5, 8 AND 1, 5 OR 7, 9 XOR 6
// Casos extra  (50-90 ns): activan N y V, que los casos pedidos nunca prenden,
//                          y muestran que C/V se anulan en operaciones lógicas.
//
// Tip Vivado: señal "caso" -> Radix -> ASCII.  Result -> Radix -> Signed
// Decimal para ver el valor con signo (rango -16..15).
// ============================================================================
module alu5_xor_tb;

    reg  [4:0] a, b;
    reg  [2:0] ALUControl;
    wire [4:0] Result;
    wire [3:0] ALUFlags;                  // {N, Z, C, V}

    wire N = ALUFlags[3];
    wire Z = ALUFlags[2];
    wire C = ALUFlags[1];
    wire V = ALUFlags[0];

    reg  [8*8-1:0] caso;
    integer errores = 0;
    integer total   = 0;

    alu5_xor DUT (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    task aplicar(input [8*8-1:0] nombre,
                 input [4:0]     va,
                 input [4:0]     vb,
                 input [2:0]     ctrl,
                 input [4:0]     expRes,
                 input [3:0]     expFlags);
        begin
            caso = nombre; a = va; b = vb; ALUControl = ctrl;
            #10;
            total = total + 1;
            if (Result !== expRes || ALUFlags !== expFlags) begin
                errores = errores + 1;
                $display("[FAIL] %s | ctrl=%b | Result=%b NZCV=%b | esperado %b NZCV=%b",
                         nombre, ctrl, Result, ALUFlags, expRes, expFlags);
            end else
                $display("[ OK ] %s | ctrl=%b | %b op %b = %b (u=%0d, s=%0d) | NZCV=%b",
                         nombre, ctrl, va, vb, Result, Result, $signed(Result), ALUFlags);
        end
    endtask

    initial begin
        $dumpfile("alu5_xor_tb.vcd");
        $dumpvars(0, alu5_xor_tb);

        // ---------------- Casos pedidos en la Pregunta 3 ----------------
        //        caso       A      B      ctrl    Result  NZCV
        aplicar("3+5",      5'd3,  5'd5,  3'b000, 5'd8,   4'b0000);
        aplicar("5-5",      5'd5,  5'd5,  3'b001, 5'd0,   4'b0110); // Z=1, C=1
        aplicar("8 and 1",  5'd8,  5'd1,  3'b010, 5'd0,   4'b0100); // Z=1
        aplicar("5 or 7",   5'd5,  5'd7,  3'b011, 5'd7,   4'b0000);
        aplicar("9 xor 6",  5'd9,  5'd6,  3'b100, 5'd15,  4'b0000);

        // ---------------- Casos extra (explicación de banderas) ----------
        aplicar("7+10",     5'd7,  5'd10, 3'b000, 5'd17,  4'b1001); // 17 no entra en -16..15 -> V=1, N=1
        aplicar("3-5",      5'd3,  5'd5,  3'b001, 5'd30,  4'b1000); // -2: N=1, C=0 (hubo borrow)
        aplicar("-16-1",    5'd16, 5'd1,  3'b001, 5'd15,  4'b0011); // -17 no entra -> V=1; C=1 (16>=1 sin signo)
        aplicar("31 and 1", 5'd31, 5'd1,  3'b010, 5'd1,   4'b0000); // el sumador da carry (31+1=32) pero C=0: op lógica

        $display("RESUMEN P3: %0d/%0d casos correctos", total - errores, total);
        #10 $finish;
    end

endmodule
