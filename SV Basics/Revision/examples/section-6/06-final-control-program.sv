class control_item;
  randc bit [3:0] a;
  rand bit ce, rst, wr, oe;
  rand bit [3:0] raddr, waddr;
  constraint control_rst {
    rst dist {0 := 40, 1 := 60};
  }
  constraint control_ce {
    ce dist {1 := 80, 0 := 20};
  }
  constraint control_rst_ce {
    (rst == 0) -> (ce == 1);
  }
  constraint value_wr {
    wr dist {0 := 50, 1 := 50};
  }
  constraint value_oe {
    oe dist {0 := 50, 1 := 50};
  }
  constraint equivalence_const {
    (wr == 1) <-> (oe == 0);
  }
  /* This block is inactive, as in your final source.
  constraint write_read {
    if (wr == 1) {
      waddr inside {[11:15]};
      raddr == 0;
    } else {
      raddr inside {[11:15]};
    }
  }
  */
endclass

module control_demo;
  initial begin
    control_item g;
    bit [15:0] seen;
    g = new();
    g.equivalence_const.constraint_mode(0);
    repeat (10) begin
      if (!g.randomize()) $fatal(1, "Control solve failed");
      if (g.rst == 0 && g.ce == 0)
        $fatal(1, "Implication was violated");
      if (g.equivalence_const.constraint_mode() != 0)
        $fatal(1, "Equivalence unexpectedly enabled");
      if (seen[g.a]) $fatal(1, "a repeated before cycle ended");
      seen[g.a] = 1;
      $display("rst=%0b ce=%0b wr=%0b oe=%0b a=%0d",
               g.rst, g.ce, g.wr, g.oe, g.a);
      $display("raddr=%0d waddr=%0d equivalence_mode=%0d",
               g.raddr, g.waddr,
               g.equivalence_const.constraint_mode());
    end
    $display("PASS control_demo: mode=0 on all ten calls");
    $finish;
  end
endmodule
