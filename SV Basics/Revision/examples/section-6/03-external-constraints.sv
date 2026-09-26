class external_item;
  rand bit [3:0] a, b;
  extern constraint legal;
  extern function void display();
endclass

constraint external_item::legal {
  a inside {[0:3]};
  b inside {[12:15]};
}

function void external_item::display();
  $display("external: a=%0d b=%0d", a, b);
endfunction

module external_demo;
  initial begin
    external_item g;
    g = new();
    repeat (10) begin
      if (!g.randomize()) $fatal(1, "External solve failed");
      if (!(g.a inside {[0:3]}) ||
          !(g.b inside {[12:15]}))
        $fatal(1, "External constraint was not satisfied");
      g.display();
    end
    $display("PASS external_demo");
    $finish;
  end
endmodule
