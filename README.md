# P0: ALU Implementation — CS3051 Arquitectura de Computadoras

Implementación de una ALU (Arithmetic Logic Unit) en Verilog, desarrollada paso a
paso siguiendo el "Proyecto - paso 0" del curso, desde una ALU básica de 32 bits
hasta un módulo `top` con shift + ALU de 5 operaciones, sintetizado sobre la
placa **Digilent Basys3**.

Basado en: Harris & Harris, *Digital Design and Computer Architecture, RISC-V Edition*.

## Estructura del repositorio

```
.
├── p1_alu_32bit/       # Pregunta 1: ALU de 32 bits + testbench (add, sub, and, or)
│   ├── alu.v
│   └── alu_tb.v
│
├── p2_alu_board/        # Pregunta 2: misma ALU adaptada a 5 bits + top para placa
│   ├── alu5.v
│   ├── basys3_alu_top.v
│   └── basys3_alu_top.xdc
│
├── p3_alu_xor/          # Pregunta 3: ALU de 5 bits + operación XOR (control de 3 bits)
│   ├── alu5_xor.v
│   └── alu5_xor_tb.v
│
├── p4_shift_alu/        # Pregunta 4: módulo shift + ALU, unidos en un top de simulación
│   ├── alu5_xor.v
│   ├── shift.v
│   ├── top.v
│   └── top_tb.v
│
├── p5_top_board/        # Pregunta 5: mismo top de P4 pero mapeado a switches/leds del Basys3
│   ├── alu5_xor.v
│   ├── shift.v
│   ├── top.v
│   ├── basys3_top.v
│   └── basys3_top.xdc
│
├── docs/
│   └── waveforms/        # Capturas del waveform viewer de Vivado (agregar aquí)
│
└── .gitignore
```

> Cada carpeta es **autocontenida**: tiene todo lo necesario para abrirse como un
> proyecto de Vivado independiente, sin depender de archivos de otras carpetas.

## Diseño de la ALU

| ALUControl | Operación (P1/P2) |
|---|---|
| `00` | Add (`A + B`) |
| `01` | Subtract (`A - B`) |
| `10` | AND |
| `11` | OR |

A partir de P3 se agrega XOR, por lo que `ALUControl` pasa de 2 a 3 bits:

| ALUControl | Operación (P3/P4/P5) |
|---|---|
| `000` | Add |
| `001` | Subtract |
| `010` | AND |
| `011` | OR |
| `100` | XOR |

### Banderas (`ALUFlags = {N, Z, C, V}`)

| Flag | Significado | Se activa cuando... |
|---|---|---|
| **N** | Negative | El bit más significativo del `Result` es 1 |
| **Z** | Zero | Todos los bits del `Result` son 0 |
| **C** | Carry | Hay acarreo de salida del sumador, y solo aplica si la operación es Add/Subtract |
| **V** | Overflow | Al sumar dos números del mismo signo, el resultado da signo opuesto (overflow real) |

## Cómo correr esto en Vivado

### Simulación (Preguntas 1, 3 y 4)

1. `File > New Project` → RTL Project, part `xc7a35tcpg236-1` (Basys3).
2. Agregar los `.v` de la carpeta correspondiente (`p1_alu_32bit`, `p3_alu_xor` o
   `p4_shift_alu`) como **Design Sources**, y el archivo `*_tb.v` como
   **Simulation Sources**.
3. `Flow Navigator > Run Simulation > Run Behavioral Simulation`.
4. Agregar las señales al waveform viewer y correr `Run All`. Los resultados
   también se imprimen por consola con `$display`.

### Implementación en placa (Preguntas 2 y 5)

1. Agregar los `.v` de `p2_alu_board` o `p5_top_board` como Design Sources y el
   `.xdc` correspondiente como Constraints.
2. Marcar como top el módulo `basys3_alu_top` (P2) o `basys3_top` (P5)
   (clic derecho sobre el módulo → `Set as Top`).
3. `Flow Navigator > Generate Bitstream`.
4. Con la placa conectada por USB: `Open Hardware Manager > Open Target >
   Auto Connect > Program Device`.

## Mapeo de pines en la placa

### P2 — `basys3_alu_top` (ALU sola)

| Señal | Switches / LEDs |
|---|---|
| `A` (5 bits) | `sw[4:0]` |
| `B` (5 bits) | `sw[9:5]` |
| `ALUControl` (2 bits) | `sw[11:10]` |
| `Result` (5 bits) | `led[4:0]` |
| `ALUFlags` (N,Z,C,V) | `led[8:5]` |

### P5 — `basys3_top` (shift + ALU con XOR)

| Señal | Switches / LEDs |
|---|---|
| `A` (5 bits) | `sw[4:0]` |
| `B` (5 bits) | `sw[9:5]` |
| `ALUControl` (3 bits) | `sw[12:10]` |
| `bshift` (2 bits) | `sw[14:13]` |
| `Result` (5 bits) | `led[4:0]` |
| `ALUFlags` (N,Z,C,V) | `led[8:5]` |

## Resultados de simulación (verificados con iverilog)

| Caso | Resultado | Flags (N Z C V) |
|---|---|---|
| 3 + 5 | 8 | 0000 |
| 5 − 5 | 0 | 0110 (Z=1, C=1) |
| 8 AND 1 | 0 | 0100 (Z=1) |
| 5 OR 7 | 7 | 0000 |
| 9 XOR 6 | 15 | 0000 |
| shift: A=3, bshift=2, B=0, Add | 12 | — |

## Autores

- (agrega aquí los nombres del equipo)

## Referencias

- Harris, S. & Harris, D. *Digital Design and Computer Architecture, RISC-V Edition*.
- [Basys3_Master.xdc — Digilent](https://github.com/Digilent/Basys3/blob/master/Projects/Keyboard/src/constraints/Basys3_Master.xdc)
- [Verilog shift operator — nandland](https://nandland.com/shift-operator/)
