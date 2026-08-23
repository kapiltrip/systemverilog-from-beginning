module priority_encoder (
  input  logic [3:0] x,
  output logic [1:0] y
);
  always_comb begin
    // Highest asserted input wins.  The question marks are intentional
    // wildcard digits because this is casez, not a plain case statement.
    casez (x)
      4'b1???: y = 2'b11;
      4'b01??: y = 2'b10;
      4'b001?: y = 2'b01;
      4'b0001: y = 2'b00;
      default: y = 2'bzz;
    endcase
  end
endmodule
