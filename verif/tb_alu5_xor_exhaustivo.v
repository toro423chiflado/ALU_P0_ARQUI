`timescale 1ns / 1ps
// ============================================================================
// Verificación exhaustiva de alu5_xor: 32 x 32 valores x 8 códigos = 8192 casos
// El modelo de referencia NO copia la lógica del ALU: usa aritmética entera
//   C (suma)  = A + B > 31           C (resta) = A >= B  (sin signo, "no borrow")
//   V         = resultado con signo fuera de -16..15
// ============================================================================
module tb_alu5_xor_exhaustivo;
    reg  [4:0] a, b;
    reg  [2:0] ctrl;
    wire [4:0] Result;
    wire [3:0] ALUFlags;
    integer ia, ib, ic, ua, ub, sa, sb, r, s, errores, total;
    reg [4:0] eRes; reg eN, eZ, eC, eV;

    alu5_xor DUT(.a(a), .b(b), .ALUControl(ctrl), .Result(Result), .ALUFlags(ALUFlags));

    initial begin
        errores = 0; total = 0;
        for (ic = 0; ic < 8; ic = ic + 1)
        for (ia = 0; ia < 32; ia = ia + 1)
        for (ib = 0; ib < 32; ib = ib + 1) begin
            a = ia; b = ib; ctrl = ic; #1;
            ua = ia; ub = ib;
            sa = (ia > 15) ? ia - 32 : ia;       // valor con signo (C2, 5 bits)
            sb = (ib > 15) ? ib - 32 : ib;
            eC = 0; eV = 0;
            case (ic)
                0: begin r = ua + ub; eC = (r > 31);    s = sa + sb; eV = (s > 15) || (s < -16); end
                1: begin r = ua - ub; eC = (ua >= ub);  s = sa - sb; eV = (s > 15) || (s < -16); end
                2: r = ua & ub;
                3: r = ua | ub;
                4: r = ua ^ ub;
                default: r = 0;
            endcase
            eRes = r[4:0]; eN = eRes[4]; eZ = (eRes == 0);
            total = total + 1;
            if (Result !== eRes || ALUFlags !== {eN, eZ, eC, eV}) begin
                errores = errores + 1;
                if (errores < 10)
                    $display("[FAIL] ctrl=%b a=%0d b=%0d -> %b %b | esperado %b %b",
                             ctrl, a, b, Result, ALUFlags, eRes, {eN,eZ,eC,eV});
            end
        end
        $display("EXHAUSTIVO alu5_xor: %0d/%0d casos correctos", total - errores, total);
        $finish;
    end
endmodule
