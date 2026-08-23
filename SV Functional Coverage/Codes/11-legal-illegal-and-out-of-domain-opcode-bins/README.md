# Part 11 — Legal, Illegal, and Out-of-Domain Opcode Bins

[← Part 10](../10-with-filtered-and-overlapping-bins/README.md) · [Functional Coverage index](../README.md) · [Part 12 →](../12-ignore-bins-and-domain-closure/README.md)

| Playground field | Value |
|---|---|
| Saved playground | [KN3M](https://edaplayground.com/x/KN3M) |
| EDA code ID | `7381043` |
| Saved Name | Blank |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; finite event queue, detailed report, then `quit -f` |
| Archive evidence | Exact public source/settings captured; random coverage and illegal hits are seed-dependent |

The placeholder-only design pane is omitted. Browser trailing spaces are
normalized, while the declarations, spelling, and teaching comments are kept.

## Complete saved testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg [2:0] opcode;
  reg [2:0] a, b;
  reg [3:0] res;
  always_comb begin
    case (opcode)
      0: res= a + b ;
      1: res = a-b;
      2: res = a ;
      3: res= b;
      4: res = a ^b ;
      5: res = a &b ;
      default : res =0 ;

    endcase
  end
  covergroup c ;
    option.per_instance = 1;
    coverpoint opcode {
      bins valid_opcode[] = {[0:5]} ;
      illegal_bins invalid_opcode[] = {6,7} ;  // illegal states that should never occur during simulation
      ignore_bins invalid_ignor[] = {8,9};
    }
    //$display("The elements of the aray ignored is %0p " , invalid_ignor); how to print the values that, are in the ignore bin

  endgroup
  c ci ;
  initial begin
    ci = new();
    for(int i =0 ; i<10 ; i++)begin
      a = $urandom() ; // 32 bit unsigned
      b = $urandom() ;
      opcode = $urandom();
      ci.sample();
      #10 ;
    end
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Exact saved `run.do`

~~~tcl
# Run the simulation until all scheduled activity is complete.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details
# directly in the Questa transcript/EDA Playground Log.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [run.do](run.do).

## What the six valid bins mean

`opcode` is three bits wide, so its complete representable domain is 0–7.
Because `valid_opcode[]` has unsized array brackets, `{[0:5]}` becomes six
separate scored bins rather than one grouped category. Coverage therefore asks
whether opcode 0, 1, 2, 3, 4, and 5 were each sampled.

The combinational `case` implements those six operations and sends every other
opcode to `default`. The covergroup samples only `opcode`; it does not prove
that `res` is correct. Result checking needs assertions or a scoreboard, and
result-value coverage would need another coverpoint or cross.

## What an illegal-bin hit means

`invalid_opcode[] = {6,7}` creates one illegal bin for each forbidden opcode.
Sampling 6 or 7 is a verification failure reported by the simulator. It does
not increase ordinary coverage. A run can consequently show 100% legal-bin
coverage and still fail because an illegal bin was hit.

Randomly assigning a three-bit opcode can generate all eight values. The
stimulus therefore does not honor its own “6 and 7 should never occur” rule.
For a positive test, constrain generation to 0–5. For a negative test, drive 6
and 7 deliberately and treat the resulting diagnostics as expected evidence.

## Why the ignore bins cannot work as written

Values 8 and 9 cannot be stored in a three-bit variable. They are outside
`opcode`'s 0–7 domain, so they can never be sampled. A simulator may warn about
the out-of-range bin values, truncate them, or reject them according to the
declaration context; they are not meaningful ignored states for this signal.

If opcodes 8 and 9 are real protocol values, widen `opcode` to at least four
bits. If the interface is truly three bits, remove these ignore bins because
there is nothing in the type domain to exclude.

## Can an ignore bin be printed with `$display`?

No. `invalid_ignor` is a coverage-bin name, not a SystemVerilog queue or array
that procedural code can read. That is why the commented `$display` idea is
not valid source code. Detailed coverage is obtained from tool reporting such
as `coverage report -cvg -details`.

When the same value set must also be used procedurally, define it separately as
a queue, array, enum set, or helper function and use that object for printing
and stimulus constraints. Keep that procedural definition synchronized with
the coverage model.

## Why ten random samples do not guarantee closure

The loop makes only ten draws from an eight-value domain. Repetition is legal,
so some valid opcodes may remain uncovered, while 6 or 7 may produce illegal
hits. Functional coverage measures what happened; it does not make random
stimulus visit missing values. Deterministic iteration through 0–5 is the
cleanest closure test for this small domain.

`run -all` terminates here because the loop is finite and no forever clock or
other recurring process remains after 100 ns. The Tcl report therefore executes
after sampling completes.

## Revision checks

1. Why do `valid_opcode[]` brackets create six coverage goals?
2. Why are 8 and 9 impossible for `reg [2:0] opcode`?
3. Can 100% legal coverage coexist with an illegal-bin failure?
4. Why is a bin name not printable like a queue?
5. What would you constrain for a positive-only opcode test?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground custom run options](https://eda-playground.readthedocs.io/en/latest/settings.html)
