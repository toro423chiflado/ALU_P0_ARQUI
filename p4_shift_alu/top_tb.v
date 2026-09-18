`timescale 1ns / 1ps
// ============================================================================
// Testbench Pregunta 4 - top (Shift + ALU)
// Como pide la diapositiva: B = 0 y ALU en suma (ALUControl = 000), así
// Result = A_desplazado + 0 = A_desplazado y se ve directamente el shift.
//
//   A = 3 (00011) con bshift = 0,1,2,3  -> 3, 6, 12, 24
//       24 = 11000 -> en C2 de 5 bits es -8 -> N = 1
//   A = 5 (00101) con bshift = 3        -> 101000 -> se pierde el MSB -> 8
//
// Tip Vivado: agregar DUT/A_desplazado al waveform (o usar la copia de abajo).
// ============================================================================
module top_tb;

    reg  [4:0] A, B;
    reg  [1:0] bshift;
    reg  [2:0] ALUControl;
    wire [4:0] Result;
    wire [3:0] ALUFlags;

    wire [4:0] A_desplazado = DUT.A_desplazado;   // señal interna, para el waveform
    wire N = ALUFlags[3];
    wire Z = ALUFlags[2];
    wire C = ALUFlags[1];
    wire V = ALUFlags[0];

    reg  [8*8-1:0] caso;
    integer errores = 0;
    integer total   = 0;

    top DUT (
        .A(A),
        .B(B),
        .bshift(bshift),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    task aplicar(input [8*8-1:0] nombre,
                 input [4:0]     vA,
                 input [1:0]     vsh,
                 input [4:0]     expRes,
                 input [3:0]     expFlags);
        begin
            caso = nombre; A = vA; bshift = vsh;
            #10;
            total = total + 1;
            if (Result !== expRes || ALUFlags !== expFlags) begin
                errores = errores + 1;
                $display("[FAIL] %s | A=%b bshift=%0d | Result=%b NZCV=%b | esperado %b NZCV=%b",
                         nombre, vA, vsh, Result, ALUFlags, expRes, expFlags);
            end else
                $display("[ OK ] %s | A=%b (%0d) << %0d -> A_desplazado=%b | Result=%0d | NZCV=%b",
                         nombre, vA, vA, vsh, A_desplazado, Result, ALUFlags);
        end
    endtask

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        B = 5'd0; ALUControl = 3'b000;      // B = 0, ALU en suma

        //        caso      A     bshift  Result  NZCV
        aplicar("3<<0",    5'd3, 2'd0,   5'd3,   4'b0000);
        aplicar("3<<1",    5'd3, 2'd1,   5'd6,   4'b0000);
        aplicar("3<<2",    5'd3, 2'd2,   5'd12,  4'b0000);
        aplicar("3<<3",    5'd3, 2'd3,   5'd24,  4'b1000); // 11000: MSB=1 -> N=1
        aplicar("5<<3",    5'd5, 2'd3,   5'd8,   4'b0000); // 101000 -> se pierde el bit 5

        $display("RESUMEN P4: %0d/%0d casos correctos", total - errores, total);
        #10 $finish;
    end

endmodule
