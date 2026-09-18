# P0: ALU Implementation — CS3051 Arquitectura de Computadoras

Implementación de una ALU en Verilog siguiendo el **Proyecto – paso 0** del curso
(*"First job: ALU implementation + xor + shift unit"*), desde la ALU de 32 bits de
las diapositivas hasta un módulo `top` con **shift + ALU de 5 operaciones**,
implementado en la placa **Digilent Basys3**.

> **Nombre del ALU:** _(definir con el equipo)_  ·  **Equipo (máx. 3):** _(agregar nombres)_

Basado en: Harris & Harris, *Digital Design and Computer Architecture, RISC-V Edition*
y las diapositivas *9. P0: ALU Implementation*.

## Estructura del repositorio

```
.
├── p1_alu_32bit/        # Pregunta 1: ALU de 32 bits + testbench (add, sub, and, or)
│   ├── alu.v
│   └── alu_tb.v
├── p2_alu_board/        # Pregunta 2: ALU adaptada a 5 bits + top y constraints para la placa
│   ├── alu5.v
│   ├── basys3_alu_top.v
│   └── basys3_alu_top.xdc
├── p3_alu_xor/          # Pregunta 3: ALU de 5 bits + XOR (ALUControl de 3 bits)
│   ├── alu5_xor.v
│   └── alu5_xor_tb.v
├── p4_shift_alu/        # Pregunta 4: módulo shift + ALU dentro de un top (simulación)
│   ├── alu5_xor.v
│   ├── shift.v
│   ├── top.v
│   └── top_tb.v
├── p5_top_board/        # Pregunta 5: el top de P4 mapeado a switches/LEDs de la Basys3
│   ├── alu5_xor.v
│   ├── shift.v
│   ├── top.v
│   ├── basys3_top.v
│   └── basys3_top.xdc
├── verif/               # Verificación extra con Icarus (no se sube a Vivado)
│   ├── run_all.sh                  # corre TODO: sh verif/run_all.sh
│   ├── tb_alu32_aleatorio.v        # ALU 32 bits: esquinas + 80k casos aleatorios
│   ├── tb_alu5_xor_exhaustivo.v    # ALU 5 bits: 8192 casos (todas las entradas)
│   ├── tb_top_exhaustivo.v         # shift + ALU: 20480 casos
│   ├── tb_basys3_alu_top.v         # mapeo sw -> led de P2 (autogenerado)
│   ├── tb_basys3_top.v             # mapeo sw -> led de P5 (autogenerado)
│   ├── gen_casos_placa.py          # genera las tablas de placa y sus testbenches
│   └── waveforms_ref.py            # dibuja los waveforms de referencia
└── docs/waveforms/      # Waveforms de referencia + aquí van las capturas de Vivado
```

> Cada carpeta `pX` es **autocontenida**: se abre como un proyecto de Vivado independiente.

## Diseño de la ALU

| ALUControl (P1/P2) | ALUControl (P3/P4/P5) | Operación |
|:-:|:-:|---|
| `00` | `000` | Add (`A + B`) |
| `01` | `001` | Subtract (`A − B = A + ~B + 1`) |
| `10` | `010` | AND |
| `11` | `011` | OR |
| — | `100` | **XOR** (el `??` de la diapositiva) |
| — | `101`–`111` | sin uso → `Result = 0` |

Con 5 operaciones ya no alcanzan 2 bits (máx. 4 códigos), por eso `ALUControl` pasa a 3 bits.
Se eligió `100` para que los 4 códigos originales queden **iguales** con un `0` adelante.

### Banderas `ALUFlags = {N, Z, C, V}`

| Flag | Significado | Lógica |
|---|---|---|
| **N** | Negative | `N = Result[MSB]` |
| **Z** | Zero | `Z = (Result == 0)` |
| **C** | Carry | `C = esAddSub & sum[N]` (carry out del sumador) |
| **V** | oVerflow | `V = esAddSub & ~(A[MSB] ^ B[MSB] ^ ALUControl[0]) & (A[MSB] ^ sum[MSB])` |

- **C en la resta:** `A − B` se calcula como `A + ~B + 1`. Si sale carry (`C = 1`) significa
  que **no hubo borrow**, es decir `A ≥ B` sin signo. `C = 0` en una resta ⇒ `A < B`.
- **V:** hay overflow cuando el resultado con signo no entra en el rango. En 5 bits el rango en
  complemento a 2 es **−16..15** (sin signo 0..31). Solo puede pasar si en la suma A y B tienen
  el mismo signo, o en la resta tienen signo distinto, y el resultado cambia de signo respecto a A.
- **`esAddSub`:** en la ALU de 2 bits era `ALUControl[1] == 0`. En la de 3 bits hay que usar
  **`ALUControl[2:1] == 00`**, porque XOR (`100`) también tiene `ALUControl[1] = 0` y si no,
  el XOR mostraría C/V falsos (el sumador siempre está calculando `A ± B` en paralelo).

### Resultados y explicación de banderas

Resultados verificados con Icarus Verilog 12 (`sh verif/run_all.sh`). Waveforms de referencia en
[`docs/waveforms/`](docs/waveforms).

| Caso | Operación en binario (5 bits) | Result | N Z C V | Por qué |
|---|---|:-:|:-:|---|
| 3 + 5 | `00011 + 00101 = 01000` | 8 | 0 0 0 0 | 8 ≤ 15, positivo, sin carry: ninguna bandera |
| 5 − 5 | `00101 + 11010 + 1 = 1 00000` | 0 | 0 1 1 0 | Resultado 0 ⇒ **Z**. Sale carry ⇒ **C** (no hubo borrow, 5 ≥ 5) |
| 8 AND 1 | `01000 & 00001 = 00000` | 0 | 0 1 0 0 | Resultado 0 ⇒ **Z**. C y V se fuerzan a 0 (operación lógica) |
| 5 OR 7 | `00101 \| 00111 = 00111` | 7 | 0 0 0 0 | Resultado positivo y distinto de 0 |
| 9 XOR 6 | `01001 ^ 00110 = 01111` | 15 | 0 0 0 0 | 9 y 6 no comparten bits ⇒ XOR = OR = 15 |

En P1 (32 bits) las banderas son idénticas porque todos los valores son pequeños y positivos.

**Casos extra** (en `alu5_xor_tb.v`, 50–90 ns) para mostrar las banderas que los casos pedidos no prenden:

| Caso | Binario | Result (u / s) | N Z C V | Por qué |
|---|---|:-:|:-:|---|
| 7 + 10 | `00111 + 01010 = 10001` | 17 / −15 | 1 0 0 1 | Dos positivos dan "negativo": 17 no entra en −16..15 ⇒ **V** y **N** |
| 3 − 5 | `00011 + 11010 + 1 = 11110` | 30 / −2 | 1 0 0 0 | −2 ⇒ **N**. Sin carry ⇒ hubo borrow (3 < 5) |
| −16 − 1 | `10000 + 11110 + 1 = 1 01111` | 15 / 15 | 0 0 1 1 | −17 no entra ⇒ **V**. Carry ⇒ **C** (16 ≥ 1 sin signo) |
| 31 AND 1 | `11111 & 00001 = 00001` | 1 / 1 | 0 0 0 0 | El sumador da 31+1 = 32 (carry), pero **C = 0** porque es op. lógica |

**Pregunta 4** (B = 0, ALU en suma ⇒ `Result = A_desplazado`):

| A | bshift | A_desplazado | Result | N Z C V | Comentario |
|:-:|:-:|:-:|:-:|:-:|---|
| 3 (`00011`) | 0 | `00011` | 3 | 0 0 0 0 | sin desplazamiento |
| 3 | 1 | `00110` | 6 | 0 0 0 0 | ×2 |
| 3 | 2 | `01100` | 12 | 0 0 0 0 | ×4 |
| 3 | 3 | `11000` | 24 | 1 0 0 0 | ×8; el MSB queda en 1 ⇒ **N** (en C2 vale −8) |
| 5 (`00101`) | 3 | `01000` | 8 | 0 0 0 0 | `101000` no entra en 5 bits: **se pierde el bit que sale** |

## Mapeo en la placa

La diapositiva pide *"los primeros 5 leds para el result y los **4 últimos** para los flags"*, por eso
las banderas van en `led[15:12]` (los 4 LEDs de la izquierda), leyéndose **N Z C V** de izquierda a derecha.
`sw[0]` y `led[0]` son los de la **derecha** de la placa.

| Señal | P2 (`basys3_alu_top`) | P5 (`basys3_top`) |
|---|---|---|
| `A` (5 bits) | `sw[4:0]` | `sw[4:0]` |
| `B` (5 bits) | `sw[9:5]` | `sw[9:5]` |
| `ALUControl` | `sw[11:10]` (2 bits) | `sw[12:10]` (3 bits) |
| `bshift` (2 bits) | — | `sw[14:13]` |
| `Result` (5 bits) | `led[4:0]` | `led[4:0]` |
| `ALUFlags` | `led[15:12]` → led15=N, led14=Z, led13=C, led12=V | igual |
| no usados | `sw[15:12]`, `led[11:5]` (apagados) | `sw[15]`, `led[11:5]` (apagados) |

Los `.xdc` restringen **los 16 switches y los 16 LEDs**: como los tops declaran `sw[15:0]` y
`led[15:0]`, cualquier puerto sin `PACKAGE_PIN`/`IOSTANDARD` hace fallar *Generate Bitstream*
con `[DRC NSTD-1]` / `[DRC UCIO-1]`.

### Tablas de prueba en placa

Subir **solo** los switches indicados (el resto abajo). Estas tablas se generan con
`verif/gen_casos_placa.py` y están verificadas en simulación (`tb_basys3_*.v`).

#### P2

| Caso | A | B | ALUControl | Switches ARRIBA (sw) | LEDs encendidos esperados | Result | N Z C V |
|---|---|---|---|---|---|---|---|
| `3+5` | 3 (`00011`) | 5 (`00101`) | `00` | 0, 1, 5, 7 | 3 | 8 (`01000`) | 0 0 0 0 |
| `5-5` | 5 (`00101`) | 5 (`00101`) | `01` | 0, 2, 5, 7, 10 | 13, 14 | 0 (`00000`) | 0 1 1 0 |
| `8 and 1` | 8 (`01000`) | 1 (`00001`) | `10` | 3, 5, 11 | 14 | 0 (`00000`) | 0 1 0 0 |
| `5 or 7` | 5 (`00101`) | 7 (`00111`) | `11` | 0, 2, 5, 6, 7, 10, 11 | 0, 1, 2 | 7 (`00111`) | 0 0 0 0 |

#### P5 (casos de la Pregunta 4)

| Caso | A | B | ALUControl | bshift | Switches ARRIBA (sw) | LEDs encendidos esperados | Result | N Z C V |
|---|---|---|---|---|---|---|---|---|
| `3<<0` | 3 (`00011`) | 0 (`00000`) | `000` | `00` | 0, 1 | 0, 1 | 3 (`00011`) | 0 0 0 0 |
| `3<<1` | 3 (`00011`) | 0 (`00000`) | `000` | `01` | 0, 1, 13 | 1, 2 | 6 (`00110`) | 0 0 0 0 |
| `3<<2` | 3 (`00011`) | 0 (`00000`) | `000` | `10` | 0, 1, 14 | 2, 3 | 12 (`01100`) | 0 0 0 0 |
| `3<<3` | 3 (`00011`) | 0 (`00000`) | `000` | `11` | 0, 1, 13, 14 | 3, 4, 15 | 24 (`11000`) | 1 0 0 0 |
| `5<<3` | 5 (`00101`) | 0 (`00000`) | `000` | `11` | 0, 2, 13, 14 | 3 | 8 (`01000`) | 0 0 0 0 |

#### P5 (extra: ALU completa con bshift = 00)

| Caso | A | B | ALUControl | bshift | Switches ARRIBA (sw) | LEDs encendidos esperados | Result | N Z C V |
|---|---|---|---|---|---|---|---|---|
| `9 xor 6` | 9 (`01001`) | 6 (`00110`) | `100` | `00` | 0, 3, 6, 7, 12 | 0, 1, 2, 3 | 15 (`01111`) | 0 0 0 0 |
| `5-5` | 5 (`00101`) | 5 (`00101`) | `001` | `00` | 0, 2, 5, 7, 10 | 13, 14 | 0 (`00000`) | 0 1 1 0 |
## Cómo correr en Vivado

**Simulación (P1, P3, P4)**
1. `File > Project > New` → RTL Project, part **`xc7a35tcpg236-1`** (Basys3).
2. Los `.v` de diseño de la carpeta como **Design Sources**; el `*_tb.v` como **Simulation Sources**.
3. `Flow Navigator > Run Simulation > Run Behavioral Simulation`.
4. En el waveform: clic derecho en `caso` → *Radix → ASCII* (muestra el nombre del caso);
   en `Result` de P3 → *Radix → Signed Decimal* para ver los negativos. N, Z, C, V ya aparecen
   como señales separadas. La consola (Tcl Console) muestra `[ OK ]`/`[FAIL]` por caso.

**Placa (P2, P5)**
1. Agregar los `.v` de `p2_alu_board` o `p5_top_board` como Design Sources y el `.xdc` como Constraints.
2. Verificar que el top sea `basys3_alu_top` (P2) o `basys3_top` (P5) (clic derecho → *Set as Top*).
3. `Generate Bitstream` (corre síntesis e implementación automáticamente).
4. Placa por USB y encendida: `Open Hardware Manager > Open Target > Auto Connect > Program Device`.
5. Probar los casos de las tablas de arriba.

## Verificación con Icarus Verilog

```sh
sudo apt-get install -y iverilog        # macOS: brew install icarus-verilog
sh verif/run_all.sh                     # 8 simulaciones, termina en "TODO OK"
python3 verif/waveforms_ref.py          # (opcional) regenera docs/waveforms/ref_*.png
```

## Cambios respecto a la versión anterior

- **[Bug] `.xdc` incompletos:** solo restringían 21 (P2) y 24 (P5) de los 32 puertos del top ⇒
  *Generate Bitstream* fallaba por puertos sin pin. Ahora se restringen los 16 sw y 16 led.
- **Flags en `led[15:12]`** ("los 4 últimos" LEDs) en vez de `led[8:5]`.
- Testbenches **auto-verificables** (comparan contra el esperado e imprimen `[ OK ]`/`[FAIL]`),
  con N/Z/C/V como señales separadas y etiqueta `caso` para el waveform.
- Casos extra en P3 (N, V en suma y resta, C anulado en op. lógica) y en P4 (N por shift, bit perdido).
- `A_shifted` → `A_desplazado` (nombre de la diapositiva); `default` en los `case`; `timescale` en todos los módulos.
- Carpeta `verif/`: pruebas exhaustivas con modelo de referencia independiente + waveforms de referencia.

## Referencias

- Harris, S. & Harris, D. *Digital Design and Computer Architecture, RISC-V Edition*.
- [Basys3_Master.xdc — Digilent](https://github.com/Digilent/Basys3/blob/master/Projects/Keyboard/src/constraints/Basys3_Master.xdc)
- [Verilog shift operator — nandland](https://nandland.com/shift-operator/)
