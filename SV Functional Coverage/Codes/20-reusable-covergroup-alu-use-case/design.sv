module aluWorking (
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic [2:0] opcode,
  output logic [4:0] y
);
  always_comb begin
    //y = '0; what does it means
    case (opcode)
      // arithmetic operations

      3'b000: y = a + b;
      3'b000: y = a - b;
      3'b000: y = a + 1;
      3'b000: y = 1 + b;
      // logical operations
      3'b000: y = a & b;
      3'b000: y = a | b;
      3'b000: y = a ^+ b;
      3'b000: y = ~a;

      default: y = 5'b00000;
    endcase
  end
endmodule
