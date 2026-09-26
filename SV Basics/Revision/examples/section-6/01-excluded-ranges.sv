`timescale 1ns/1ps
class exclusion_item;
  rand bit [3:0] a, b;
  bit [3:0] y;
  constraint legal {
    !(a inside {[3:7]});
    !(b inside {[5:9]});
  }
endclass

module exclusion_demo;
  timeunit 1ns; timeprecision 1ps;
  initial begin
    exclusion_item g;
    g = new();
    $timeformat(-9, 0, " ns", 8);
    for (int i=0; i<10; i++) begin
      if (!g.randomize()) $fatal(1, "Excluded-range solve failed");
      if ((g.a inside {[3:7]}) || (g.b inside {[5:9]}))
        $fatal(1, "Excluded value was generated");
      if (g.y != 0) $fatal(1, "Nonrandom y changed");
      $display("i=%0d a=%0d b=%0d t=%0t", i, g.a, g.b, $time);
      #10;
    end
    $display("PASS exclusion_demo");
    $finish;
  end
endmodule
