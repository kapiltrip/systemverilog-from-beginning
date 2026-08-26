`timescale 1ns/1ps
// to do , this make a note in the readme in the outermost dir somewhere

// Video 140: use transition bins to describe a complete SPI transaction path.
module tb;
  logic clk = 0;
  logic reset, start;
  logic [1:0] state;
  logic busy;

  spi_controller dut (.*);

  covergroup spi_state_cg @(posedge clk);
    option.per_instance = 1;
    cp_state: coverpoint state {
      bins transaction = (0 => 1 => 2[*8] => 3 => 0);
      bins start_path = (0 => 1 => 2);
      bins finish_path = (2 => 3 => 0);
    }
  endgroup

  spi_state_cg cg;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    reset = 1; start = 0;
    repeat (2) @(posedge clk);
    reset = 0;
    @(negedge clk) start = 1;
    @(negedge clk) start = 0;
    wait (!busy);
    // TODO: add back-to-back transfers and protocol/data coverage.
    #20 $finish;
  end
endmodule
