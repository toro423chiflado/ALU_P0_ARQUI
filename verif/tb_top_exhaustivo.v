`timescale 1ns / 1ps
// ============================================================================
// Verificación exhaustiva de top (shift + ALU):
//   32 (A) x 32 (B) x 4 (bshift) x 5 operaciones = 20480 casos
// ============================================================================
module tb_top_exhaustivo;
    reg  [4:0] A, B;
    reg  [1:0] bshift;
    reg  [2:0] ctrl;
    wire [4:0] Result;
    wire [3:0] ALUFlags;
    integer ia, ib, ish, ic, ad, sa, sb, r, s, errores, total;
    reg [4:0] eRes; reg eC, eV;

    top DUT(.A(A), .B(B), .bshift(bshift), .ALUControl(ctrl), .Result(Result), .ALUFlags(ALUFlags));

    initial begin
        errores = 0; total = 0;
        for (ic = 0; ic < 5; ic = ic + 1)
        for (ish = 0; ish < 4; ish = ish + 1)
        for (ia = 0; ia < 32; ia = ia + 1)
        for (ib = 0; ib < 32; ib = ib + 1) begin
            A = ia; B = ib; bshift = ish; ctrl = ic; #1;
            ad = (ia * (1 << ish)) % 32;          // A desplazado = A*2^n truncado a 5 bits
            sa = (ad > 15) ? ad - 32 : ad;
            sb = (ib > 15) ? ib - 32 : ib;
            eC = 0; eV = 0;
            case (ic)
                0: begin r = ad + ib; eC = (r > 31);   s = sa + sb; eV = (s > 15) || (s < -16); end
                1: begin r = ad - ib; eC = (ad >= ib); s = sa - sb; eV = (s > 15) || (s < -16); end
                2: r = ad & ib;
                3: r = ad | ib;
                4: r = ad ^ ib;
            endcase
            eRes = r[4:0];
            total = total + 1;
            if (Result !== eRes || ALUFlags !== {eRes[4], eRes == 0, eC, eV}) begin
                errores = errores + 1;
                if (errores < 10)
                    $display("[FAIL] ctrl=%b A=%0d sh=%0d B=%0d -> %b %b | esperado %b %b",
                             ctrl, A, bshift, B, Result, ALUFlags, eRes, {eRes[4], eRes==0, eC, eV});
            end
        end
        $display("EXHAUSTIVO top (shift+ALU): %0d/%0d casos correctos", total - errores, total);
        $finish;
    end
endmodule
