#!/usr/bin/env python3
"""Dibuja waveforms de referencia (PNG) a partir de los .vcd de Icarus.
Uso: sh run_all.sh && python3 waveforms_ref.py"""
import re, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon

def parse_vcd(path, top):
    ids, scope, vals, t = {}, [], {}, 0
    for line in open(path):
        line = line.strip()
        if line.startswith("$scope"):
            scope.append(line.split()[2])
        elif line.startswith("$upscope"):
            scope.pop()
        elif line.startswith("$var"):
            p = line.split()
            if scope == [top]:
                ids.setdefault(p[3], []).append((p[4], int(p[2])))
        elif line.startswith("#"):
            t = int(line[1:])
        elif line and line[0] in "01xz" and len(line) > 1 and line[1:] in ids:
            for name, _ in ids[line[1:]]:
                vals.setdefault(name, []).append((t, line[0]))
        elif line.startswith("b"):
            v, i = line[1:].split()
            if i in ids:
                for name, w in ids[i]:
                    vals.setdefault(name, []).append((t, v.zfill(w)))
    return vals

def ascii_of(bits):
    if any(c in "xz" for c in bits): return ""
    n = int(bits, 2); s = ""
    while n: s = chr(n & 0xFF) + s; n >>= 8
    return s.strip("\x00 ")

def fmt(bits, mode):
    if any(c in "xz" for c in bits): return "X"
    if mode == "bin": return bits
    if mode == "sdec":
        n = int(bits, 2); w = len(bits)
        return str(n - (1 << w) if bits[0] == "1" else n)
    return str(int(bits, 2))

COLORES = {"N": "#E8735A", "Z": "#3B7DD8", "C": "#3AA67A", "V": "#E0A526"}

def dibujar(vcd, top, filas, t_fin_ns, titulo, salida):
    vals = parse_vcd(vcd, top)
    fig, ax = plt.subplots(figsize=(15, 0.62 * len(filas) + 1.4))
    H = 0.62
    # divisiones por caso
    cambios = sorted({t for t, _ in vals["caso"]})
    for t in cambios[1:]:
        ax.axvline(t / 1000, color="#bbbbbb", lw=0.8, ls="--", zorder=0)
    for k, (sig, label, mode) in enumerate(filas):
        y = (len(filas) - 1 - k) * 1.0
        ax.text(-0.6, y + H / 2, label, ha="right", va="center", fontsize=11,
                family="monospace", fontweight="bold",
                color=COLORES.get(sig, "#1f2d3d"))
        # último valor por instante (descarta glitches de tiempo cero) y fusiona valores iguales
        ult = {}
        for t, v in vals[sig]: ult[t] = v
        ev = []
        for t in sorted(ult):
            if not ev or ev[-1][1] != ult[t]: ev.append((t / 1000, ult[t]))
        ev += [(t_fin_ns, None)]
        for (t0, v), (t1, _) in zip(ev[:-1], ev[1:]):
            if t1 <= t0: continue
            if mode == "bit":
                c = COLORES.get(sig, "#1f2d3d")
                lvl = y + (H if v == "1" else 0)
                ax.plot([t0, t1], [lvl, lvl], color=c, lw=2)
                if v == "1":
                    ax.fill_between([t0, t1], y, y + H, color=c, alpha=0.18, lw=0)
                if t0 > 0:
                    ax.plot([t0, t0], [y, y + H], color=c, lw=1.2)
            else:
                d = min(0.6, (t1 - t0) / 5)
                pts = [(t0, y + H / 2), (t0 + d, y + H), (t1 - d, y + H),
                       (t1, y + H / 2), (t1 - d, y), (t0 + d, y)]
                fc = "#FDECE8" if mode == "ascii" else "#E8F0FB"
                ax.add_patch(Polygon(pts, closed=True, fc=fc, ec="#2F4A6D", lw=1.2))
                txt = ascii_of(v) if mode == "ascii" else fmt(v, mode)
                ax.text((t0 + t1) / 2, y + H / 2, txt, ha="center", va="center",
                        fontsize=10, family="monospace")
    ax.set_xlim(0, t_fin_ns)
    ax.set_ylim(-0.4, len(filas))
    ax.set_yticks([])
    ax.set_xlabel("tiempo (ns)")
    for s in ["left", "right", "top"]: ax.spines[s].set_visible(False)
    ax.set_title(titulo, fontsize=13, fontweight="bold", loc="left")
    fig.text(0.99, 0.01, "Referencia generada con Icarus Verilog 12 - capturar el equivalente en Vivado XSim",
             ha="right", fontsize=8, color="#777777")
    plt.tight_layout()
    fig.savefig(salida, dpi=130)
    print("->", salida)

OUT = "../docs/waveforms/"
flags = [("N", "N", "bit"), ("Z", "Z", "bit"), ("C", "C", "bit"), ("V", "V", "bit")]
dibujar("build/alu_tb.vcd", "alu_tb",
        [("caso", "caso", "ascii"), ("a", "a", "dec"), ("b", "b", "dec"),
         ("ALUControl", "ALUControl", "bin"), ("Result", "Result", "dec"),
         ("ALUFlags", "ALUFlags", "bin")] + flags,
        40, "Pregunta 1 - ALU 32 bits: 3+5, 5-5, 8 and 1, 5 or 7", OUT + "ref_p1_alu32.png")
dibujar("build/alu5_xor_tb.vcd", "alu5_xor_tb",
        [("caso", "caso", "ascii"), ("a", "a", "dec"), ("b", "b", "dec"),
         ("ALUControl", "ALUControl", "bin"), ("Result", "Result (bin)", "bin"),
         ("Result", "Result (signed)", "sdec"), ("ALUFlags", "ALUFlags", "bin")] + flags,
        90, "Pregunta 3 - ALU 5 bits + XOR (0-50 ns: casos pedidos | 50-90 ns: casos extra de banderas)",
        OUT + "ref_p3_alu5_xor.png")
dibujar("build/top_tb.vcd", "top_tb",
        [("caso", "caso", "ascii"), ("A", "A", "bin"), ("bshift", "bshift", "dec"),
         ("A_desplazado", "A_desplazado", "bin"), ("B", "B", "dec"),
         ("ALUControl", "ALUControl", "bin"), ("Result", "Result", "dec"),
         ("ALUFlags", "ALUFlags", "bin")] + flags,
        50, "Pregunta 4 - Shift + ALU (B = 0, ALU en suma)", OUT + "ref_p4_shift_alu.png")
