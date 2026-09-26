class cyclic_item;
  randc bit [3:0] a, b;
  constraint legal {
    a inside {[2:11]};
    b inside {[2:11]};
  }
endclass

module cyclic_demo;
  initial begin
    cyclic_item g;
    bit [9:0] seen_a, seen_b;
    g = new();
    for (int cycle=0; cycle<2; cycle++) begin
      seen_a = '0;
      seen_b = '0;
      repeat (10) begin
        if (!g.randomize()) $fatal(1, "Cycle solve failed");
        if (!(g.a inside {[2:11]}) ||
            !(g.b inside {[2:11]}))
          $fatal(1, "Value outside cycle range");
        if (seen_a[g.a-2] || seen_b[g.b-2])
          $fatal(1, "Repeated value within a cycle");
        seen_a[g.a-2] = 1;
        seen_b[g.b-2] = 1;
      end
      if (seen_a != 10'h3ff || seen_b != 10'h3ff)
        $fatal(1, "Incomplete cycle");
    end
    $display("PASS cyclic_demo: two complete cycles per field");
    $finish;
  end
endmodule
