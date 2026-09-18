#!/bin/sh
# ============================================================================
# Corre todas las simulaciones con Icarus Verilog (iverilog 12).
#   Uso:  cd verif && sh run_all.sh
#   Instalar: sudo apt-get install -y iverilog   (o brew install icarus-verilog)
# Los .vcd quedan en verif/build/ (se pueden abrir con GTKWave).
# ============================================================================
cd "$(dirname "$0")" || exit 1
R=..
mkdir -p build
FALLOS=0

correr () {   # $1 = nombre, resto = archivos
    nombre=$1; shift
    printf '\n==================== %s ====================\n' "$nombre"
    if ! iverilog -Wall -o "build/$nombre.vvp" "$@" 2> "build/$nombre.log"; then
        cat "build/$nombre.log"; FALLOS=$((FALLOS + 1)); return
    fi
    (cd build && vvp -n "$nombre.vvp") > "build/$nombre.out" 2>&1
    grep -v -e 'VCD info' -e '\$finish' "build/$nombre.out"
    if grep -q FAIL "build/$nombre.out"; then FALLOS=$((FALLOS + 1)); fi
}

# --- Testbenches pedidos en las diapositivas ---
correr p1_alu_tb        $R/p1_alu_32bit/alu.v      $R/p1_alu_32bit/alu_tb.v
correr p3_alu5_xor_tb   $R/p3_alu_xor/alu5_xor.v   $R/p3_alu_xor/alu5_xor_tb.v
correr p4_top_tb        $R/p4_shift_alu/alu5_xor.v $R/p4_shift_alu/shift.v $R/p4_shift_alu/top.v $R/p4_shift_alu/top_tb.v

# --- Verificación extra ---
correr alu32_aleatorio  $R/p1_alu_32bit/alu.v      tb_alu32_aleatorio.v
correr alu5_xor_exh     $R/p3_alu_xor/alu5_xor.v   tb_alu5_xor_exhaustivo.v
correr top_exh          $R/p4_shift_alu/alu5_xor.v $R/p4_shift_alu/shift.v $R/p4_shift_alu/top.v tb_top_exhaustivo.v
correr placa_p2         $R/p2_alu_board/alu5.v     $R/p2_alu_board/basys3_alu_top.v tb_basys3_alu_top.v
correr placa_p5         $R/p5_top_board/alu5_xor.v $R/p5_top_board/shift.v $R/p5_top_board/top.v $R/p5_top_board/basys3_top.v tb_basys3_top.v

printf '\n============================================================\n'
if [ "$FALLOS" -eq 0 ]; then echo "TODO OK: todas las simulaciones pasaron"; else echo "HAY $FALLOS SIMULACION(ES) CON FALLAS"; fi
exit "$FALLOS"
