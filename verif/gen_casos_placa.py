#!/usr/bin/env python3
"""Genera las tablas de prueba en placa (P2 y P5) y sus testbenches.
Una sola fuente de verdad: el mismo modelo de referencia produce la tabla del
README y los valores esperados de los testbenches tb_basys3_*.v"""

def alu5(a, b, ctrl):
    sa = a - 32 if a > 15 else a
    sb = b - 32 if b > 15 else b
    C = V = 0
    if ctrl == 0:   r = a + b; C = int(r > 31);  s = sa + sb; V = int(not -16 <= s <= 15)
    elif ctrl == 1: r = a - b; C = int(a >= b);  s = sa - sb; V = int(not -16 <= s <= 15)
    elif ctrl == 2: r = a & b
    elif ctrl == 3: r = a | b
    elif ctrl == 4: r = a ^ b
    else:           r = 0
    r &= 31
    return r, (r >> 4) & 1, int(r == 0), C, V

def fila(nombre, A, B, ctrl, sh, ctrl_bits, con_shift):
    ad = (A << sh) & 31
    r, N, Z, C, V = alu5(ad, B, ctrl)
    sw = A | (B << 5) | (ctrl << 10) | ((sh << 13) if con_shift else 0)
    led = r | (V << 12) | (C << 13) | (Z << 14) | (N << 15)
    return dict(nombre=nombre, A=A, B=B, ctrl=ctrl, sh=sh, ad=ad, r=r, flags=(N, Z, C, V),
                sw=sw, led=led, ctrl_bits=ctrl_bits,
                sw_up=[i for i in range(16) if sw >> i & 1],
                led_on=[i for i in range(16) if led >> i & 1])

P2 = [fila(n, a, b, c, 0, 2, False) for n, a, b, c in
      [("3+5", 3, 5, 0), ("5-5", 5, 5, 1), ("8 and 1", 8, 1, 2), ("5 or 7", 5, 7, 3)]]
P5 = [fila(n, a, 0, 0, s, 3, True) for n, a, s in
      [("3<<0", 3, 0), ("3<<1", 3, 1), ("3<<2", 3, 2), ("3<<3", 3, 3), ("5<<3", 5, 3)]]
P5_extra = [fila(n, a, b, c, 0, 3, True) for n, a, b, c in
      [("9 xor 6", 9, 6, 4), ("5-5", 5, 5, 1)]]

def lst(v): return ", ".join(str(x) for x in v) if v else "ninguno"

def tabla_md(rows, con_shift):
    h = "| Caso | A | B | ALUControl |" + (" bshift |" if con_shift else "") + \
        " Switches ARRIBA (sw) | LEDs encendidos esperados | Result | N Z C V |\n"
    h += "|---|---|---|---|" + ("---|" if con_shift else "") + "---|---|---|---|\n"
    for f in rows:
        cb = format(f["ctrl"], f"0{f['ctrl_bits']}b")
        h += f"| `{f['nombre']}` | {f['A']} (`{f['A']:05b}`) | {f['B']} (`{f['B']:05b}`) | `{cb}` |"
        if con_shift: h += f" `{f['sh']:02b}` |"
        N, Z, C, V = f["flags"]
        h += f" {lst(f['sw_up'])} | {lst(f['led_on'])} | {f['r']} (`{f['r']:05b}`) | {N} {Z} {C} {V} |\n"
    return h

def tb(modulo, rows, archivo):
    s = f"""`timescale 1ns / 1ps
// AUTOGENERADO por gen_casos_placa.py - verifica el mapeo switches -> LEDs de {modulo}
module tb_{modulo};
    reg  [15:0] sw;
    wire [15:0] led;
    integer errores = 0, total = 0;
    {modulo} DUT(.sw(sw), .led(led));
    task probar(input [8*8-1:0] nombre, input [15:0] vsw, input [15:0] esperado);
        begin
            sw = vsw; #10; total = total + 1;
            if (led !== esperado) begin
                errores = errores + 1;
                $display("[FAIL] %s sw=%b led=%b esperado=%b", nombre, vsw, led, esperado);
            end else
                $display("[ OK ] %s sw=%b -> led=%b", nombre, vsw, led);
        end
    endtask
    initial begin
"""
    for f in rows:
        s += f'        probar("{f["nombre"]}", 16\'b{f["sw"]:016b}, 16\'b{f["led"]:016b});\n'
    s += f"""        $display("PLACA {modulo}: %0d/%0d casos correctos", total - errores, total);
        $finish;
    end
endmodule
"""
    open(archivo, "w").write(s)

if __name__ == "__main__":
    tb("basys3_alu_top", P2, "tb_basys3_alu_top.v")
    tb("basys3_top", P5 + P5_extra, "tb_basys3_top.v")
    open("tablas_placa.md", "w").write(
        "### P2\n\n" + tabla_md(P2, False) + "\n### P5 (casos de la Pregunta 4)\n\n" +
        tabla_md(P5, True) + "\n### P5 (extra: ALU completa con bshift = 00)\n\n" + tabla_md(P5_extra, True))
    print(open("tablas_placa.md").read())
