class range_item;
  randc bit [3:0] a, b;
  bit [4:0] y;
  int min, max;
  int attempts, successes;
  function void set_range(int low, int high);
    min = low;
    max = high;
  endfunction
  constraint legal {
    a inside {[min:max]};
    b inside {[min:max]};
  }
  function void pre_randomize();
    attempts++;
  endfunction
  function void post_randomize();
    successes++;
    y = {1'b0, a} + {1'b0, b};
  endfunction
endclass

module range_demo;
  initial begin
    range_item g;
    bit [3:0] old_a, old_b;
    bit [4:0] old_y;
    g = new();
    if (!g.randomize()) $fatal(1, "Default range failed");
    if (g.a != 0 || g.b != 0 || g.y != 0)
      $fatal(1, "Default bounds should allow only zero");

    g.set_range(12, 33);
    if (!g.randomize()) $fatal(1, "12 to 33 should be legal");
    if (!(g.a inside {[12:15]}) ||
        !(g.b inside {[12:15]}))
      $fatal(1, "Four-bit domain was not respected");
    if (g.y != ({1'b0,g.a} + {1'b0,g.b}))
      $fatal(1, "Derived sum is wrong");
    old_a = g.a; old_b = g.b; old_y = g.y;

    g.set_range(16, 33);
    if (g.randomize()) $fatal(1, "Impossible range succeeded");
    if (g.a != old_a || g.b != old_b || g.y != old_y)
      $fatal(1, "Failed solve unexpectedly changed the data");
    if (g.attempts != 3 || g.successes != 2)
      $fatal(1, "Callback success/failure counts are wrong");

    g.set_range(2, 11);
    if (!g.randomize()) $fatal(1, "Recovery failed");
    if (!(g.a inside {[2:11]}) ||
        !(g.b inside {[2:11]}))
      $fatal(1, "Recovery used the wrong interval");
    if (g.attempts != 4 || g.successes != 3)
      $fatal(1, "Recovery callback counts are wrong");
    $display("PASS range_demo: attempts=4 successes=3");
    $finish;
  end
endmodule
