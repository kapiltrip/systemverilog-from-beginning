module alu_stub(
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic [2:0] op,
  output logic [4:0] y
);
  always_comb begin
    y = '0;
    case (op)
      // TODO: implement the four arithmetic and four logical operations.
      default: y = '0;
    endcase
  end
endmodule
