`timescale 1ns / 1ps
// AUTOGENERADO por gen_casos_placa.py - verifica el mapeo switches -> LEDs de basys3_alu_top
module tb_basys3_alu_top;
    reg  [15:0] sw;
    wire [15:0] led;
    integer errores = 0, total = 0;
    basys3_alu_top DUT(.sw(sw), .led(led));
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
        probar("3+5", 16'b0000000010100011, 16'b0000000000001000);
        probar("5-5", 16'b0000010010100101, 16'b0110000000000000);
        probar("8 and 1", 16'b0000100000101000, 16'b0100000000000000);
        probar("5 or 7", 16'b0000110011100101, 16'b0000000000000111);
        $display("PLACA basys3_alu_top: %0d/%0d casos correctos", total - errores, total);
        $finish;
    end
endmodule
