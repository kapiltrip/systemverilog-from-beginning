# Revision Example Verification

[Study sheet](../Data-Types-and-OOP-Study-Sheet.md)

**Result: 32 of 32 deterministic checks passed.**

The [self-checking testbench](revision_checks.sv) tests the selected language rules used in the revision sheet. AMD Vivado Simulator 2024.1, 64-bit software build 5076996, compiled and elaborated the testbench and completed the simulation at 1234 ps, with 1 ps resolution.

The checks cover type defaults and signedness; `$time` and `$realtime`; unpacked array concatenations and assignment patterns; dynamic resizing; fixed-array value copying; queue operations; function and constructor output arguments; `input` versus `ref`; input-handle sharing; shallow-copy constructor bypass; independent nested deep copies; optional parentheses on a no-argument class-method call; and virtual versus nonvirtual dispatch.

The final trace was:

```text
TRACE types bit[7:0]=255 byte=-1 defaults(bit,logic)=0,x
TRACE time $time=1.000 ns $realtime=1.234 ns
TRACE arrays concat='{1'b1,1'b0,1'b1,1'b1} resized='{11,22,33,0,0} queue='{1,8,3,4}
TRACE arguments sum=12 input(actual,result)=10,15 swap=9,4 ctor_out=26
TRACE copies source=10/88 shallow=99/88 deep=123/456 ctor_calls=2
TRACE dispatch virtual=3 nonvirtual=20
PASS: 32 deterministic checks completed
```

To repeat the check, open a Vivado command prompt in a scratch build directory and run:

```text
xvlog -sv <path-to-revision_checks.sv>
xelab revision_checks -s revision_checks_sim
xsim revision_checks_sim -runall
```

The check is separate from the original saved lessons. It does not claim every captured lesson compiles unchanged or that all displayed examples were tested on multiple simulators. `%p` punctuation is simulator presentation; assertions test the values and sizes directly. The language cross-check used IEEE Std 1800-2017, especially Clauses 6-8, 10, 13, and 20.

## Expanded guide examples

All six complete module examples in the expanded foundations guide were extracted from the Markdown, compiled with `xvlog`, elaborated with `xelab`, and run separately with `xsim -runall`. Each run completed successfully and its output matched the expected trace. These are six example runs, separate from the 32 assertions above.

- `width_and_sign`: `-126 130 44 ff82 0082`.
- `sampled_time`: `fixed=12.000 ns real=12.230 ns`.
- `loop_forms`: `repeat result='{0,1,2,3,4,5,6,7,8,9}`.
- `resize_trace`: `expanded='{0,1,4,9,16,0,0,0}` and `shrunk='{0,1,4}`.
- `queue_trace`: `front=7 back=9 q='{1,3,4}`.
- `task_timing_example`: `t=5 ns a=3 b=4 y=7`, then `t=15 ns a=9 b=2 y=11`.

These checks used AMD Vivado Simulator 2024.1. Partial code excerpts elsewhere in the guide were not all independently compiled; their scope and reasoned results are identified in the text.
