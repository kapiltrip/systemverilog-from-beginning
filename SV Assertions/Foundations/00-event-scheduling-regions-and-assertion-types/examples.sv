// Foundation 00: illustrative SystemVerilog assertion-region examples.
// This file is a standard-oriented study companion, not an EDA Playground capture.

module assertion_region_examples;
  timeunit 1ns;
  timeprecision 1ps;

  logic clk = 1'b0;
  logic d = 1'b0;
  logic q = 1'b0;
  logic past_valid = 1'b0;

  logic a = 1'b0;
  logic b = 1'b0;
  logic y;

  always #5 clk = ~clk;

  // The RHS of q <= d is evaluated when this process runs.
  // The LHS q is updated later in the NBA region.
  always @(posedge clk) begin
    q          <= d;
    past_valid <= 1'b1;

    // In ordinary module code this call normally executes in Active,
    // before the queued NBA update reaches q.
    $display("[DISPLAY] t=%0t d=%0b q=%0b", $time, d, q);

    // This report is produced in Postponed and observes the final slot.
    $strobe("[STROBE ] t=%0t d=%0b q=%0b", $time, d, q);

    // A simple immediate assertion is evaluated when execution reaches it.
    d_known: assert (!$isunknown(d))
      $display("[IMMEDIATE PASS] d is known");
    else
      $error("[IMMEDIATE FAIL] d contains X or Z");
  end

  // The consequent checks the sampled pipeline state. The antecedent avoids
  // using $past(d) before a prior assertion clock tick exists.
  pipeline_check: assert property (
    @(posedge clk)
    past_valid |-> q == $past(d)
  )
    $display(
      "[CONCURRENT PASS] sampled q=%0b, current q=%0b",
      $sampled(q),
      q
    );
  else
    $error(
      "[CONCURRENT FAIL] sampled q=%0b did not match prior d",
      $sampled(q)
    );

  // All three expressions are evaluated when this always_comb process runs.
  // The forms differ in when and how their pass/fail reports are processed.
  always_comb begin
    y = a & b;

    simple_immediate: assert (y == (a & b))
      $display("[SIMPLE PASS] y is correct");
    else
      $error("[SIMPLE FAIL] y is incorrect");

    observed_deferred: assert #0 (y == (a & b))
      $display("[OBSERVED-DEFERRED PASS] y settled correctly");
    else
      $error("[OBSERVED-DEFERRED FAIL] y settled incorrectly");

    final_deferred: assert final (y == (a & b))
      $display("[FINAL-DEFERRED PASS] final y is correct");
    else
      $error("[FINAL-DEFERRED FAIL] final y is incorrect");
  end

  // Change stimulus on the falling edge so that it is stable before the
  // concurrent assertion samples at the next rising edge.
  initial begin
    repeat (4) begin
      @(negedge clk);
      d = ~d;
      a = ~a;
      b = a ^ d;
    end

    @(negedge clk);
    $finish;
  end

endmodule
