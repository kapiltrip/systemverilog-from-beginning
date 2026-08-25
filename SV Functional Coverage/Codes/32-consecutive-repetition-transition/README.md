# Part 32 — Consecutive Repetition Transition Bins

[← Part 31](../31-simple-transition-coverage-p2/README.md) · [Functional Coverage index](../README.md) · [Part 33 →](../33-nonconsecutive-and-goto-transition/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 9, V124 — Consecutive Repetition Transition |
| Source playground | [`M9vN`](https://edaplayground.com/x/M9vN) |
| EDA code ID / saved Name | `7382373` / **FC S09 V124 - Consecutive Repetition** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | One transition bin covered at 100%; `transitions` hit **41** times; zero compile/simulation errors |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 124: consecutive repetition and the deliberate endpoint value.
module tb;
  reg clk = 0 ;
  reg data[] = {1,1,1,1,1, 0};
  reg state = 0 ;
  integer i = 0 ;
  initial repeat (90) #5 clk = ~ clk ;
  initial begin
    for(i=0 ; i< 5; i++)begin
      @(posedge clk );
      state = data[i];
    end
  end
  covergroup c @(posedge clk );
    option.per_instance = 1;
    coverpoint state {
      bins transitions = (1[*4]); // 4 consecutive repetition of 1
          // some sort of overlapping consecutive operation , happening her e,
    }    // {1,1,1,1} if repetition count is 4 its, so we need a endpoint
  endgroup
  c ci ;
  initial begin
    ci = new() ;
    //#         bin transitions                                    41          1          -    Covered
 // coming out to be 41 due to overlapping nature of this in the array
    // important is to end the stimulus
    // or to remember the starting point 0 => 1[*4]

  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The EDA design pane contains only
the shared testbench-only placeholder, so it is intentionally omitted.

## Complete saved `run.do`

~~~tcl
# Shared Questa run script for every Sections 6-10 boilerplate.
# Each saved EDA Playground copy contains this same script.
run -all;
coverage report -cvg -details;
quit -f;
~~~

Local script: [run.do](run.do).

## Fresh direct Questa result

| Coverage item | Hits / bins | Metric |
|---|---:|---:|
| `state.transitions` | 41 hits; 1/1 bins | 100.00% |
| Covergroup instance `ci` | 1/1 bins | 100.00% |
| Total | One covergroup type | **100.00%** |

The direct run completed `qrun`, compilation, and simulation with zero errors.
The only total warning was the saved `+acc` optimization notice
`vopt-10587`; it does not affect the 41-hit result.

## Why the source comment's 41 is correct

`1[*4]` means four consecutive sampled values equal to one. It is equivalent
to the sampled transition sequence `1→1→1→1`. A single bin can increment more
than once, and adjacent matches are allowed to overlap.

The finite clock creates 45 positive edges. On the first edge, the covergroup
observes the initial `state == 0` before the same-edge stimulus assignment.
The loop then writes five ones and never changes `state` again, so the remaining
44 positive edges all sample one. A run of 44 ones contains:

```text
44 - 4 + 1 = 41
```

length-four windows. That exactly matches the saved comment and the live Questa
report. The result is not “41 bins”; it is 41 hits in one already-covered bin.

## The unused endpoint is the real code gap

`data` has six entries, but the loop condition is `i < 5`, so it drives only
`data[0]` through `data[4]`. All five are one. The final zero at `data[5]` is
never read, and the active bin does not require either a starting or ending
zero. The comment “we need a endpoint” therefore describes an intended repair,
not what the current code implements.

If the requirement is one bounded burst of exactly four ones between zeros, a
clear deterministic form is:

~~~systemverilog
logic data[] = '{0, 1, 1, 1, 1, 0};

initial foreach (data[i]) begin
  @(negedge clk);
  state = data[i];
end

coverpoint state {
  bins one_burst = (0 => 1[*4] => 0);
}
~~~

This uses every array entry, expresses both endpoints, and drives on the edge
opposite the covergroup's sampling event.

## Why the positive-edge assignment should be changed

Both the stimulus block and the covergroup react to `posedge clk`. The recorded
Questa behavior samples the old state before the blocking assignment, which is
why the first sample is zero. Depending on same-edge process ordering is fragile
testbench style even when one simulator gives a stable result. Negative-edge
driving gives the state half a cycle to settle before coverage samples it.

The clock itself is finite: 90 half-period toggles finish at 450 ns. After the
last clock event, no process can create another event, so `run -all` reaches the
coverage report without `$finish`.

## What 100% means here

One declared bin has been hit, so the model is 100% closed. That percentage says
nothing about whether a bounded four-one burst occurred, because the model did
not include either endpoint and the stimulus actually held one for 44 samples.
Coverage can only close the requirement represented by the bins; an incomplete
bin definition can make a weak model look perfect.

## Revision checks

1. What sampled sequence does `1[*4]` represent?
2. Why do 44 consecutive ones produce 41 hits rather than 11 or 44?
3. Which element of `data` is never used, and why?
4. What requirement is added by `(0 => 1[*4] => 0)`?
5. Why is negative-edge driving safer than the saved positive-edge write?
6. Why does 100% coverage not prove the intended bounded burst happened?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification — transition and repetition bins](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator and custom `run.do` settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
