// 32-bit ALU (Pregunta 1)
// Basado en las diapositivas: Add / Subtract / AND / OR
module alu(
    input  [31:0] a, b,
    input  [1:0]  ALUControl,
    output reg  [31:0] Result,
    output wire [3:0]  ALUFlags
);

    wire        neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;

    // Si ALUControl[0]=1 -> resta (invertimos b y sumamos 1 -> complemento a 2)
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum      = a + condinvb + ALUControl[0];

    always @(*) begin
        casex (ALUControl[1:0])
            2'b0?: Result = sum[31:0]; // 00 = Add, 01 = Subtract
            2'b10: Result = a & b;     // AND
            2'b11: Result = a | b;     // OR
        endcase
    end

    assign neg      = Result[31];
    assign zero     = (Result == 32'b0);
    assign carry    = (ALUControl[1] == 1'b0) & sum[32];
    assign overflow = (ALUControl[1] == 1'b0) &
                       ~(a[31] ^ b[31] ^ ALUControl[0]) &
                       (a[31] ^ sum[31]);

    assign ALUFlags = {neg, zero, carry, overflow};

endmodule
