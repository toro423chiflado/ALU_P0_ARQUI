// Modulo shift - desplaza A a la izquierda 'bshift' posiciones
module shift(
    input  [4:0] A,
    input  [1:0] bshift,
    output [4:0] A_shifted
);

    assign A_shifted = A << bshift;

endmodule
