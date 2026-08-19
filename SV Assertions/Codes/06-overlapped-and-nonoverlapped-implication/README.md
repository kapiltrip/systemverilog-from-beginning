# Part 06 — Overlapped and Nonoverlapped Implication

[← Part 05](../05-assertion-building-blocks/README.md) · [SV Assertions index](../README.md) · [Part 07 →](../07-current-and-sampled-values/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 06 - Overlapped and Nonoverlapped Implication` |
| Stable playground | [eX_T](https://edaplayground.com/x/eX_T) |
| Simulator | Siemens Questa 2025.2 |
| Language/options | SystemVerilog/Verilog, `-timescale 1ns/1ns`, `-voptargs=+acc=npr` |
| Live result | 0 compile errors; three intentional `a2` assertion errors |
| EPWave | Enabled |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
// overlapping implication -> evaluate of consequent in the same clock tick as antecedant becomes true  a  |-> b 
// non overlapping implication -> evaluation of consequent in the next clock tick as antecedant becomes true  a |=>

// t t non vacuos success will be our target 
// t f failure 
// f (x) vacuous success 
// non overlapping implication in the next clock tick we are checking for the concequent 
module tb; 
  reg clk=0 ; 
  reg req = 0; 
  reg ack =0 ; 
  task req_stimuli();
    #10; 
    req=1; 
    #10;
    req=0; 
    #10; 
    req=1; 
    #10;
    req=0;     
    #10; 
    req=1; 
    #10;
    req=0;     
  endtask 
  task ack_stimuli(); 
    #10 ;
    ack=1; 
    #10 ; 
    ack=0;
        #10 ;
    ack=1; 
    #10 ; 
    ack=0;
        #10 ;
    ack=1; 
    #10 ; 
    ack=0;
  endtask 
  initial begin
    fork
      req_stimuli();
      ack_stimuli();
    join
  end
  always #5 clk = ~clk ; 
  a1 : assert property (@(posedge clk) req |-> ack ) $info("Overlapping success at %0t" , $time) ; else $error("Overlapping failure at %0t" , $time);
    a2 : assert property (@(posedge clk) req |=> ack ) $info("NON Overlapping success at %0t" , $time) ; else $error("non Overlapping failure at %0t" , $time);
  
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
    end
    initial begin
      repeat (15) @(posedge clk); 
      $finish();
    end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The browser design pane contains only its placeholder, so no `design.sv` is stored.

## The exact difference between `|->` and `|=>`

An implication separates a property into an **antecedent** on the left and a **consequent** on the right. When the antecedent matches, it creates a consequent obligation.

| Form | If `req` is sampled true at tick N | Equivalent intuition for this one-cycle antecedent |
|---|---|---|
| `req |-> ack` | `ack` is checked at tick N | same sampled tick |
| `req |=> ack` | `ack` is checked at tick N+1 | next sampled tick |

“Overlapped” does not mean that procedural statements execute simultaneously. It means the consequent begins on the clock tick on which the antecedent sequence finishes. “Nonoverlapped” inserts one assertion-clock step before the consequent begins.

For a multi-cycle antecedent such as `req ##1 busy`, the reference point is the antecedent's **completion tick**, not its starting tick:

~~~systemverilog
(req ##1 busy) |-> ack   // check ack when busy completes the antecedent
(req ##1 busy) |=> ack   // check ack one sampled clock after that completion
~~~

## Why `a1` passes and `a2` fails

The two stimulus tasks run concurrently and drive `req` and `ack` to the same values every 10 ns. The assertion clock has positive edges at 5, 15, 25, 35, 45, 55, and 65 ns.

At 15, 35, and 55 ns, both signals are sampled as `1`:

- `a1` sees `req=1` and checks `ack` on that same tick, so it passes;
- `a2` sees `req=1`, but schedules its `ack` check for the next positive edge;
- at 25, 45, and 65 ns, `ack` is sampled as `0`, so those three `a2` attempts fail.

This is not a simulator problem. It is the expected proof that nonoverlapped implication moves the consequent by one assertion clock.

## Truth outcomes and vacuity

The source comments describe three important cases:

| Antecedent | Consequent obligation | Result |
|---|---|---|
| matches | passes | nonvacuous success |
| matches | fails | failure |
| does not match | no obligation is created | vacuous success |

The comment `f (x) vacuous success` is best read as “if the antecedent is false, the consequent is irrelevant.” It does **not** mean that an `X` automatically proves success. Four-state expressions and sequence matching require care: an unknown antecedent normally does not form a true match, which can leave an implication vacuous. If an unknown control signal must be illegal, check it explicitly with `$isunknown`.

`$assertvacuousoff(0)` suppresses vacuous-success action-block reporting. It does not change failures into passes, does not disable assertion evaluation, and does not create stimulus coverage. A separate `cover property` is the clearest way to prove that an antecedent really occurred.

## Scheduler detail

At each `posedge clk`, the concurrent assertions sample ordinary design values in the Preponed region, evaluate the property in the Observed region, and schedule pass/fail action blocks into the Reactive region. Therefore, same-time Active-region assignments do not retroactively change the sample already taken for that assertion tick.

Driving stimulus exactly on an assertion edge can still make the intended test hard to read. A cleaner lesson drives `req` and `ack` at `negedge clk`, leaving half a cycle before positive-edge sampling.

## A deterministic comparison example

~~~systemverilog
initial begin
  @(negedge clk); req = 1; ack = 1;
  @(negedge clk); req = 0; ack = 0;
end

overlapped:    assert property (@(posedge clk) req |-> ack);
nonoverlapped: assert property (@(posedge clk) req |=> ack);
~~~

The first assertion passes when both are sampled high. The second fails one clock later because `ack` has been driven low.

## Revision checks

1. For a three-cycle antecedent, from which tick is the overlap measured?
2. Why are the `a2` failures at 25, 45, and 65 ns rather than at the request ticks?
3. Why is a vacuous pass not evidence that the request path was exercised?
4. What changes if `$rose(req)` replaces the level expression `req`?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.12 and 16.14
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
- [Foundation 00 — event regions and assertion timing](../../Foundations/00-event-scheduling-regions-and-assertion-types/README.md)
