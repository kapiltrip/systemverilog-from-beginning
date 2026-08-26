module tb;
  reg [7:0] x;
  wire [2:0] y;
  integer i = 0;

  covergroup c;
    option.per_instance = 1;
    coverpoint y {
      bins zeroes = {'b00000001};
      wildcard bins one = {8'b0000001?};
      wildcard bins two = {8'b000001??};
      wildcard bins three = {8'b00001???};
      wildcard bins four = {8'b0001????};
      wildcard bins five = {8'b001?????};
      wildcard bins six = {8'b01??????};
      wildcard bins seven = {8'b1???????};
    }
    coverpoint x;
  endgroup

  c ci;
  penc dut (x, y);

  initial begin
    ci = new();
    for (i = 0; i < 10; i++) begin
      x = $urandom();
      ci.sample();
      #10;
    end
  end
endmodule
