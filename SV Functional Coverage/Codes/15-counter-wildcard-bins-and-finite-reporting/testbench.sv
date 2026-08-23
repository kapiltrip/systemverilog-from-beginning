// Counter coverage with wildcard bins
module tb;
  reg clk = 0;
  reg en = 0;
  wire [3:0] y;

  counter dut (clk, en, y);

  always #5 clk = ~clk;

  initial begin
    // Hold reset active across two rising edges so y becomes known.
    en = 0;
    #20;

    // Exercise every enabled counter range.
    en = 1;
    #200;

    // Exercise the disabled/zero bin, then count again.
    en = 0;
    #20;
    en = 1;
  end

  covergroup c @(posedge clk);
    option.per_instance = 1;

    coverpoint {en, y} {
      bins count_off = {5'b00000};
      wildcard bins countLow  = {5'b100??}; // enabled, count 0 to 3
      wildcard bins countMid  = {5'b101??}; // enabled, count 4 to 7
      wildcard bins countHigh = {5'b11???}; // enabled, count 8 to 15
    }
  endgroup

  c ci;

  initial begin
    ci = new();
  end
endmodule
