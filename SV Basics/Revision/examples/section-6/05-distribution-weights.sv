class weighted_item;
  rand bit wr, rd;
  rand bit [1:0] var1, var2;
  constraint data {
    var1 dist {0 := 30, [1:3] := 70};
    var2 dist {0 :/ 30, [1:3] :/ 90};
  }
  constraint control {
    wr dist {0 := 30, 1 := 70};
    rd dist {0 :/ 30, 1 :/ 70};
  }
endclass

module distribution_demo;
  initial begin
    weighted_item f;
    int counts1[4], counts2[4];
    int writes, reads, total1, total2;
    f = new();
    repeat (12000) begin
      if (!f.randomize()) $fatal(1, "Distribution solve failed");
      counts1[f.var1]++;
      counts2[f.var2]++;
      writes += int'(f.wr);
      reads += int'(f.rd);
    end
    foreach (counts1[i]) begin
      total1 += counts1[i];
      total2 += counts2[i];
      $display("value=%0d var1_count=%0d var2_count=%0d",
               i, counts1[i], counts2[i]);
    end
    if (total1 != 12000 || total2 != 12000)
      $fatal(1, "Histogram accounting failed");
    $display("writes=%0d reads=%0d samples=12000", writes, reads);
    $display("PASS distribution_demo: sample accounting");
    $finish;
  end
endmodule
