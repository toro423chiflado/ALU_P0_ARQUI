`timescale 1ns / 1ps
// ============================================================================
// Verificación de alu (32 bits): esquinas + 20000 casos aleatorios por operación
// Modelo de referencia con aritmética de 64 bits (independiente del diseño).
// ============================================================================
module tb_alu32_aleatorio;
    reg  [31:0] a, b;
    reg  [1:0]  ctrl;
    wire [31:0] Result;
    wire [3:0]  ALUFlags;
    reg  [31:0] esq [0:6];
    integer i, j, k, errores, total;

    alu DUT(.a(a), .b(b), .ALUControl(ctrl), .Result(Result), .ALUFlags(ALUFlags));

    task verificar;
        reg [63:0] ua, ub, r;
        reg signed [63:0] s;
        reg [31:0] eRes; reg eC, eV;
        begin
            #1;
            ua = {32'b0, a}; ub = {32'b0, b};
            eC = 0; eV = 0;
            case (ctrl)
                2'b00: begin r = ua + ub; eC = r[32];
                             s = $signed(a) + $signed(b); end
                2'b01: begin r = ua - ub; eC = (a >= b);
                             s = $signed(a) - $signed(b); end
                2'b10: r = ua & ub;
                2'b11: r = ua | ub;
            endcase
            if (ctrl[1] == 1'b0)
                eV = (s > 64'sd2147483647) || (s < -64'sd2147483648);
            eRes = r[31:0];
            total = total + 1;
            if (Result !== eRes || ALUFlags !== {eRes[31], eRes == 0, eC, eV}) begin
                errores = errores + 1;
                if (errores < 10)
                    $display("[FAIL] ctrl=%b a=%h b=%h -> %h %b | esperado %h %b",
                             ctrl, a, b, Result, ALUFlags, eRes, {eRes[31], eRes==0, eC, eV});
            end
        end
    endtask

    initial begin
        errores = 0; total = 0;
        esq[0] = 32'h0000_0000; esq[1] = 32'h0000_0001; esq[2] = 32'h7FFF_FFFF;
        esq[3] = 32'h8000_0000; esq[4] = 32'hFFFF_FFFF; esq[5] = 32'h8000_0001;
        esq[6] = 32'h0000_0005;
        for (k = 0; k < 4; k = k + 1)
            for (i = 0; i < 7; i = i + 1)
                for (j = 0; j < 7; j = j + 1) begin
                    ctrl = k; a = esq[i]; b = esq[j]; verificar;
                end
        for (k = 0; k < 4; k = k + 1)
            for (i = 0; i < 20000; i = i + 1) begin
                ctrl = k; a = $random; b = $random; verificar;
            end
        $display("ALEATORIO alu 32 bits: %0d/%0d casos correctos", total - errores, total);
        $finish;
    end
endmodule
