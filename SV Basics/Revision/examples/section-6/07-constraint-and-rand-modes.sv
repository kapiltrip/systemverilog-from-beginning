class mode_item;
  rand bit wr, oe;
  constraint relation { (wr == 1) <-> (oe == 0); }
endclass

module mode_demo;
  initial begin
    mode_item g;
    bit ok;
    g = new();
    if (g.relation.constraint_mode() != 1)
      $fatal(1, "New constraint should start enabled");
    for (int w=0; w<2; w++) begin
      for (int o=0; o<2; o++) begin
        ok = g.randomize() with { wr == w; oe == o; };
        if (ok != (w != o))
          $fatal(1, "Enabled equivalence truth table is wrong");
      end
    end

    g.relation.constraint_mode(0);
    for (int w=0; w<2; w++) begin
      for (int o=0; o<2; o++) begin
        if (!g.randomize() with { wr == w; oe == o; })
          $fatal(1, "Disabled relation rejected a bit pair");
      end
    end

    g.wr = 0; g.oe = 0;
    g.wr.rand_mode(0); g.oe.rand_mode(0);
    g.relation.constraint_mode(1);
    if (g.randomize())
      $fatal(1, "Frozen illegal pair should fail");
    g.oe = 1;
    if (!g.randomize()) $fatal(1, "Frozen legal pair failed");
    if (g.wr != 0 || g.oe != 1)
      $fatal(1, "Frozen values changed");
    $display("PASS mode_demo: pair legality and frozen fields");
    $finish;
  end
endmodule
