class address_item;
  rand bit wr, rst, ce;
  rand bit [3:0] raddr, waddr;
  constraint implication { (rst == 0) -> (ce == 1); }
  constraint write_read {
    if (wr == 1) {
      waddr inside {[11:15]};
      raddr == 0;
    } else {
      raddr inside {[11:15]};
    }
  }
  constraint zero_unused { (wr == 0) -> (waddr == 0); }
endclass

module address_demo;
  initial begin
    address_item g;
    bit ok;
    g = new();
    g.zero_unused.constraint_mode(0);
    if (!g.randomize() with { wr == 1; waddr == 11; })
      $fatal(1, "Legal write failed");
    if (g.raddr != 0) $fatal(1, "Write read-address is not zero");
    if (!g.randomize() with { wr == 0; waddr == 7; })
      $fatal(1, "Original read branch should allow waddr 7");
    if (!(g.raddr inside {[11:15]}))
      $fatal(1, "Read address outside required range");
    g.zero_unused.constraint_mode(1);
    if (g.randomize() with { wr == 0; waddr == 7; })
      $fatal(1, "Strengthened read branch should reject 7");

    for (int r=0; r<2; r++) begin
      for (int c=0; c<2; c++) begin
        ok = g.randomize() with { rst == r; ce == c; };
        if (ok != ((r != 0) || (c == 1)))
          $fatal(1, "Implication truth table is wrong");
      end
    end
    $display("PASS address_demo: branches and implication");
    $finish;
  end
endmodule
