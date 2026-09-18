// ALU de 5 bits + XOR (Pregunta 3)
// ALUControl ahora es de 3 bits:
//   000 = Add
//   001 = Subtract
//   010 = AND
//   011 = OR
//   100 = XOR
module alu5_xor(
    input  [4:0] a, b,
    input  [2:0] ALUControl,
    output reg  [4:0] Result,
    output wire [3:0] ALUFlags
);

    wire       neg, zero, carry, overflow;
    wire       isAddSub; // 1 si la operacion es suma o resta
    wire [4:0] condinvb;
    wire [5:0] sum;

    assign isAddSub = ~ALUControl[2] & ~ALUControl[1]; // 000 o 001
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum      = a + condinvb + ALUControl[0];

    always @(*) begin
        case (ALUControl)
            3'b000: Result = sum[4:0]; // Add
            3'b001: Result = sum[4:0]; // Subtract
            3'b010: Result = a & b;    // AND
            3'b011: Result = a | b;    // OR
            3'b100: Result = a ^ b;    // XOR
            default: Result = 5'b0;
        endcase
    end

    assign neg      = Result[4];
    assign zero     = (Result == 5'b0);
    assign carry    = isAddSub & sum[5];
    assign overflow = isAddSub &
                       ~(a[4] ^ b[4] ^ ALUControl[0]) &
                       (a[4] ^ sum[4]);

    assign ALUFlags = {neg, zero, carry, overflow};

endmodule
