// FSM coverage repair note:
// The coverpoint label was accidentally split across lines as `stat` and `e:`.
// Questa then reported a syntax error near `e`, followed by a cascading
// "Undefined variable: ci" error because the covergroup declaration did not parse.
// Fix: keep the label as one token: `state: coverpoint dut.state;`.
// The custom run.do also runs for 200 ns before printing coverage and quitting,
// so the forever clock/sampler cannot block the report and no early $finish can skip it.
module tb;
  reg x = 0;
  reg rst = 0;
  reg clk = 0;
  wire y;

  fsm dut (x, clk, rst, y);

  always #5 clk = ~clk;

  initial begin
    rst = 1;
    #30;
    rst = 0;
    #40;
    x = 1;
    #10;
    x = 0;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  covergroup c;
    option.per_instance = 1;
    // Keep the label as one token so the report names this coverpoint state.
    state: coverpoint dut.state;
  endgroup

  c ci;
  initial begin
    ci = new();
    forever begin
      @(posedge clk);
      ci.sample();
    end
  end
endmodule
