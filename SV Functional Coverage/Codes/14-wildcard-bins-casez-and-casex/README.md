# Part 14 — Wildcard Bins, `casez`, and the `casex` Trap

[← Part 13](../13-illegal-bin-precedence-and-report-timing/README.md) · [Functional Coverage index](../README.md) · [Part 15 →](../15-counter-wildcard-bins-and-finite-reporting/README.md)

| Field | Value |
|---|---|
| Source playground | [`rzC3`](https://edaplayground.com/x/rzC3) |
| EDA code ID | `7381709` |
| Saved Name | Blank |
| Saved simulator | Siemens Questa 2025.2 |
| Saved compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Saved custom `run.do` | Enabled; repaired to `run -all`, detailed report, then `quit -f` |
| Public-page status | Saved and rerun after the timing repair; all 15 samples execute and the report prints |
| Direct Questa result | 0 compile/simulation errors; `x` 3/4, `y` 4/13, covergroup 52.88% for the recorded random seed |
| Exact-source local result | XSim runs the RTL, but rejects the nine exact X/Z output bins; it is not coverage-model parity for this source |
| Deterministic variant | All self-checks passed; `cp_x` 4/4, `cp_y` 4/4, total 100% |

## The most important correction

In a numeric literal, `?` is an alternative spelling for `Z`. It is not a
universal wildcard by itself. The surrounding construct decides whether that
digit is compared exactly or ignored:

~~~systemverilog
case (a)       // ? is a Z digit; 4'b1??? means exactly 4'b1ZZZ
casez (a)      // Z and ? positions are wildcards
casex (a)      // X, Z, and ? positions are wildcards
~~~

The first transient draft observed during this task had exactly that bug. The
page changed while it was being inspected, so it was re-read before archiving.
The **current saved design correctly uses `casez`**, the testbench constructs
the covergroup and calls `ci.sample()`, and the public `run.do` is now repaired
to wait for every sample before reporting.

There is a second subtlety. `casez` and `casex` apply their wildcard rules to
**both** the case expression and each case item. Therefore this statement is
true but incomplete:

> `casez` does not automatically ignore an actual `X` in the input.

It does not treat input `X` as a wildcard. However, an item-side `?` can still
mask the position containing that input `X`. To isolate the real difference,
compare an unknown input bit against a **concrete** item bit:

~~~systemverilog
value = 4'b1X01;

casez (value)
  4'b1001: ...  // no match: X is compared with concrete 0
endcase

casex (value)
  4'b1001: ...  // matches: expression-side X is ignored
endcase
~~~

The corrected testbench executes exactly this experiment and prints `0` for
`casez` and `1` for `casex`.

## What was faulty, and what is fixed now

The current public source has the important code repairs:

- `y` is two bits in both panes;
- the covergroup is constructed inside `initial`;
- sampling uses `ci.sample()`;
- the design uses valid `casez ... endcase` syntax;
- `default:` has its colon; and
- the ten-time-unit delay before sampling lets `always_comb` settle.

The remaining fault was the inherited `run.do`. Each loop iteration consumes
20 ns, and sample $i$ occurs at $10+20i$ ns. The fifteen samples therefore
occur at 10, 30, ..., 290 ns, and the finite testbench becomes idle at 300 ns.
The old `run 200ns` returned after only the first ten samples (through 190 ns).
Its comment also mentioned a later `$finish`, but this testbench has none.

| Simulation time | State of the saved testbench |
|---:|---|
| 10–190 ns | Samples 1–10 execute |
| 200 ns under the old Tcl | An early, partial report printed |
| 210–290 ns | Samples 11–15 execute only after the repair |
| 300 ns | The finite stimulus is complete; `run -all` returns |

The public page was repaired with `run -all;`. This testbench has no forever
process or HDL-side `$finish`, so the event queue naturally empties after all
fifteen samples. `run 320ns;` would also work, but hard-coding extra time is
less robust. The stimulus remains random, so 15 samples still do not
mathematically guarantee that every bin is hit.

> **Browser-operation note:** start an EDA run in its existing tab and leave it
> running in the background. Do not repeatedly select that tab or steal browser
> focus during the run; inspect the Log after it finishes.

## Complete saved testbench

~~~systemverilog
// wild card bins
// multiple value will give same output
// priority encoder
// 000001?? // any values for ?
// 4 t0 2 priority encoder
module tb;
  reg [3:0] x ;
  wire [1:0] y ;

  priorityEncoder dut (x,y);

  covergroup c;
    option.per_instance = 1;
    coverpoint x{
      bins zero = {4'b0001};
      wildcard bins one = {4'b001?  };
      wildcard bins two = {4'b01?? };
      wildcard bins three = {4'b1??? };
    }
    coverpoint y {
      bins undef_atOP[] = {2'bxx, 2'bx0, 2'b1x, 2'bx1 , 2'bzz, 2'bz0 , 2'b0z ,2'b1z , 2'bz1 };
      bins valid_at0p[] = {0,1,2,3}; // undefined hits also there

    }
  endgroup
  c ci ;

  initial begin
    ci  = new();

    for(int i =0 ; i<15 ; i++)begin
      x= $urandom();
      #10;
      $display("The value of x in binary is %4b " , x );
      ci.sample();
      #10 ;
    end
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Complete saved design

~~~systemverilog
// Code your design here
module priorityEncoder(
  input [3:0] x,
  output reg [1:0] y
);
  always_comb begin
    casez(x)
      4'b0001: y =  2'b00  ;
      4'b001? : y= 2'b01 ;
      4'b01?? : y= 2'b10 ;
      4'b1??? : y= 2'b11 ;
      default:  y= 2'bzz;
    endcase

  end
endmodule
~~~

Local source: [design.sv](design.sv).

## Complete saved `run.do`

~~~tcl
# Run until the finite 15-sample testbench has no scheduled activity.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details after all samples.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local source: [run.do](run.do).

## Deterministic verified priority encoder

~~~systemverilog
module priority_encoder (
  input  logic [3:0] x,
  output logic [1:0] y
);
  always_comb begin
    // Highest asserted input wins.  The question marks are intentional
    // wildcard digits because this is casez, not a plain case statement.
    casez (x)
      4'b1???: y = 2'b11;
      4'b01??: y = 2'b10;
      4'b001?: y = 2'b01;
      4'b0001: y = 2'b00;
      default: y = 2'bzz;
    endcase
  end
endmodule
~~~

Local source: [verified-design.sv](verified-design.sv).

The patterns are written from the highest request bit to the lowest to make
the priority obvious. For 0/1 inputs these four patterns are mutually
exclusive: `1???`, `01??`, `001?`, and `0001`. If a different set of wildcard
items overlaps, a normal case statement executes the first matching item, so
source order then becomes functional priority.

## Deterministic self-checking testbench

~~~systemverilog
module tb;
  logic [3:0] x;
  logic [1:0] y;

  priority_encoder dut (
    .x (x),
    .y (y)
  );

  covergroup encoder_cg;
    option.per_instance = 1;

    cp_x: coverpoint x {
      bins bit0_only = {4'b0001};
      wildcard bins bit1_highest = {4'b001?};
      wildcard bins bit2_highest = {4'b01??};
      wildcard bins bit3_highest = {4'b1???};
    }

    cp_y: coverpoint y {
      bins encoded_value[] = {[0:3]};
    }
  endgroup

  encoder_cg coverage;

  function automatic logic plain_case_question_matches(
    input logic [3:0] value
  );
    case (value)
      4'b1???: plain_case_question_matches = 1'b1;
      default: plain_case_question_matches = 1'b0;
    endcase
  endfunction

  function automatic logic casez_concrete_matches(
    input logic [3:0] value
  );
    casez (value)
      4'b1001: casez_concrete_matches = 1'b1;
      default: casez_concrete_matches = 1'b0;
    endcase
  endfunction

  function automatic logic casex_concrete_matches(
    input logic [3:0] value
  );
    casex (value)
      4'b1001: casex_concrete_matches = 1'b1;
      default: casex_concrete_matches = 1'b0;
    endcase
  endfunction

  task automatic drive_and_check(
    input logic [3:0] stimulus,
    input logic [1:0] expected
  );
    x = stimulus;
    #1;
    coverage.sample();

    if (y !== expected) begin
      $error("x=%b produced y=%b; expected %b", x, y, expected);
    end
  endtask

  initial begin
    coverage = new();

    // Deterministically hit every wildcard input bin and every output bin.
    drive_and_check(4'b0001, 2'b00);
    drive_and_check(4'b0010, 2'b01);
    drive_and_check(4'b0011, 2'b01);
    drive_and_check(4'b0100, 2'b10);
    drive_and_check(4'b0111, 2'b10);
    drive_and_check(4'b1000, 2'b11);
    drive_and_check(4'b1111, 2'b11);

    // A plain case treats ? as a Z digit, not as a wildcard.
    if (plain_case_question_matches(4'b1000) !== 1'b0) begin
      $error("plain case incorrectly treated ? as a wildcard");
    end

    // This pair isolates the real expression-side difference.  casez does
    // not ignore the X in 1X01 when the item has a concrete 0 there; casex
    // does ignore it and therefore matches 1001.
    if (casez_concrete_matches(4'b1x01) !== 1'b0) begin
      $error("casez incorrectly ignored an expression-side X");
    end
    if (casex_concrete_matches(4'b1x01) !== 1'b1) begin
      $error("casex did not wildcard an expression-side X");
    end

    x = 4'b0000;
    #1;
    if (y !== 2'bzz) begin
      $error("no-request input should select the default branch");
    end

    $display("plain case: 1000 versus 1??? -> %0b",
             plain_case_question_matches(4'b1000));
    $display("casez:      1X01 versus 1001 -> %0b",
             casez_concrete_matches(4'b1x01));
    $display("casex:      1X01 versus 1001 -> %0b",
             casex_concrete_matches(4'b1x01));
    $display("PASS: encoder checks and wildcard-semantics checks completed");
  end
endmodule
~~~

Local source: [verified-testbench.sv](verified-testbench.sv).

## Verified full-run `run.do`

~~~tcl
# Run until the finite testbench has no scheduled activity.
run -all;

# Print covergroup, coverpoint, and bin details after all samples.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [verified-run.do](verified-run.do).

## Verified result

The repaired public page was saved and rerun directly with Siemens Questa
2025.2. `run -all` executed all fifteen samples at 10 through 290 ns, the Tcl
report ran after the event queue emptied, and `qrun`, `vlog`, and `vsim` each
ended with zero errors. The only total warning was the existing `+acc`
optimization warning from `vopt`.

The recorded random seed produced this report:

| Exact public coverpoint / bin | Hits | Result |
|---|---:|---:|
| `x.zero` (`0001`) | 1 | covered |
| `x.one` (`001?`) | 3 | covered |
| `x.two` (`01??`) | 0 | uncovered |
| `x.three` (`1???`) | 10 | covered |
| `x` total | 3/4 bins | 75.00% |
| `y.undef_atOP['bzz]` | 1 | covered |
| Other eight declared `undef_atOP` bins | 0 | uncovered |
| `y.valid_at0p[0..3]` | 1, 3, 0, 10 | 3/4 covered |
| `y` total | 4/13 bins | 30.76% |
| Covergroup metric | 7/17 bins covered | 52.88% |

The 52.88% metric is the equal-weight average of the two coverpoint metrics,
$(75.00+30.76)/2$; it is not the raw $7/17=41.17\%$ bin ratio. The empty
`x.two`/`y.valid_at0p[2]` pair is a random-stimulus miss, not a reporting fault.
A different random seed can change those hits.

### Audit of the exact X/Z output bins

`undef_atOP[]` uses ordinary exact bins, not `wildcard bins`. Questa therefore
creates one four-state singleton bin for each listed literal. The current list
contains nine non-2-state output values:

~~~text
xx  x0  1x  x1  zz  z0  0z  1z  z1
~~~

A two-bit four-state signal has twelve values containing at least one X or Z.
The three omitted values are `0x`, `xz`, and `zx`. Add them only if the intended
lesson is exhaustive four-state enumeration; doing so would make 12 undefined
bins plus the four valid bins.

For this encoder, most undefined bins are structurally unreachable. The design
assigns only `00`, `01`, `10`, `11`, or the default `zz`. Consequently `zz` can
be hit by `x == 0000`, but partial-X/Z outputs such as `x0` or `1z` require an
RTL change, a forced/corrupted output, or a separate fault-injection model.
Uncovered unreachable bins should be removed, ignored, or justified rather
than treated as a stimulus-closure target.

Vivado/XSim 2024.1 independently compiled and ran the exact RTL, but warned
that each exact X/Z singleton coverage bin was invalid and removed the
`undef_atOP` array. It can validate the executable encoder and the known-value
bins, but it cannot reproduce Questa's 13-bin `y` denominator for this lesson.
That tool divergence is why the direct Questa report above is authoritative.

The deterministic `verified-*` variant avoids both random closure and
unreachable output goals. It runs every self-check and prints:

~~~text
plain case: 1000 versus 1??? -> 0
casez:      1X01 versus 1001 -> 0
casex:      1X01 versus 1001 -> 1
PASS: encoder checks and wildcard-semantics checks completed
~~~

The report is deterministic:

| Coverpoint / bin | Hits | Result |
|---|---:|---:|
| `cp_x.bit0_only` | 1 | covered |
| `cp_x.bit1_highest` | 2 | covered |
| `cp_x.bit2_highest` | 2 | covered |
| `cp_x.bit3_highest` | 2 | covered |
| `cp_x` total | 4/4 bins | 100% |
| `cp_y.encoded_value_0..3` | 1, 2, 2, 2 | 4/4, 100% |
| Covergroup total | — | 100% |

`wildcard bins` and `casez` solve different problems. The design's `casez`
chooses `y`; the testbench's `wildcard bins` groups many sampled `x` values
into one coverage goal. A wildcard-bin definition treats `X`, `Z`, and `?` in
the **bin definition** as wildcard digits over 2-state values. Sampled values
that themselves contain X or Z are excluded from such a wildcard bin. Thus
`wildcard bins bit3_highest = {4'b1???};` is one bin covering ordinary values
8 through 15; it is not permission to count an unknown sampled input. By
contrast, `bins undef_atOP[] = {2'bxx, ...};` declares exact four-state bins.

## Comparison table

| Construct | What item-side `?` means | Expression-side values ignored | Main purpose |
|---|---|---|---|
| `case` | A literal Z digit; exact four-state comparison | None | Exact decode, including exact X/Z states when written |
| `casez` | Wildcard | Z (and `?`, which is Z in a literal) | Compact masked patterns while preserving visible X mismatches |
| `casex` | Wildcard | X and Z | Symmetric legacy wildcard matching; risky for RTL |
| ordinary `bins` | Literal X/Z values remain exact | Not a case expression | Cover specific four-state sampled values |
| `wildcard bins` | Wildcard in the bin definition | Not a case expression; sampled X/Z values are excluded | Combine multiple 2-state sampled values into a coverage goal |

For the case statements, the wildcard rule is symmetric:

~~~text
casez: ignore bit i if expression[i] or item[i] is Z/?
casex: ignore bit i if expression[i] or item[i] is X/Z/?
~~~

This is why `casez` is safer than `casex` for detecting unknown input, but it
can still hide a genuine expression-side Z such as an undriven or tri-stated
signal.

## Deep Q&A

### 1. Why is a normal `case` statement not enough?

It often **is** enough. Use normal `case` when every bit is meaningful and the
value must match exactly. It performs a four-state comparison, so `0`, `1`,
`X`, and `Z` are distinct. That is desirable for FSM decode, opcodes with fully
specified bits, and logic where an unknown must fall into `default`.

Normal `case` becomes verbose when some positions intentionally do not affect
the decision. To express “any value whose top bit is 1” with exact items, one
would otherwise enumerate eight values. `casez` can express the same 2-state
set as `4'b1???`.

### 2. Are `casez` and `casex` mainly useful in encoders?

Priority encoders are the textbook example, but masked matching also appears
in instruction decode, address-region decode, protocol-field classification,
interrupt selection, packet-header matching, and verification models. The
shared requirement is not “encoder”; it is “some bit positions do not matter
for this decision.”

For modern synthesizable RTL, `casez` with intentional `?` item digits is the
usual choice of these two. Add an assertion such as `$isunknown(input)` when
X/Z must be forbidden. `casex` is generally avoided because it also masks
unknown input.

### 3. Why do both `casez` and `casex` exist?

They make different promises about four-state data:

- `casez` ignores Z/? positions but continues to compare X positions.
- `casex` ignores X positions as well as Z/? positions.

That difference matters only when a case expression or item can contain X. On
a strictly 2-state input and with `?` used in the items, the useful matches are
usually the same, which is another reason `casex` adds little value in RTL.

### 4. What is the use of `?` in Verilog/SystemVerilog?

In a based numeric literal, `?` is a readability-oriented alternative spelling
for `Z`. It is convenient in `casez`, `casex`, wildcard equality, and wildcard
coverage-bin patterns because those constructs can interpret the corresponding
position as a do-not-care. The same character also participates in other
grammar, most visibly the conditional operator `condition ? a : b`; that is a
separate use and not a logic digit.

### 5. What exactly does `?` mean?

Its meaning is contextual. Inside `4'b1???`, each `?` creates a Z-valued bit in
the literal. Then:

- plain `case` compares those Z bits exactly;
- `casez` and `casex` ignore those positions;
- `wildcard bins` uses them to match either 0 or 1 in sampled 2-state values;
- wildcard equality such as `value ==? 4'b1???` treats RHS X/Z/? positions as
  wildcards.

So “`?` means I intentionally do not care” is an excellent coding-intent rule,
but the literal's language-level value is Z and the surrounding operator gives
it wildcard behavior.

### 6. What does `X` mean?

In four-state simulation, X means the simulator cannot determine whether the
bit is 0 or 1. Common causes include uninitialized variables, conflicting net
drivers, incomplete assignments, unknown array indices, and arithmetic fed by
an unknown operand. It is diagnostic information about uncertainty, not an
ordinary hardware level and not automatically an intentional mask.

An X literal can also be used as a synthesis optimization hint in some flows.
That is a different tool interpretation and can create simulation/synthesis
differences, so it should not be confused with runtime wildcard matching.

### 7. What is the difference between `X` and `?`?

`X` directly denotes the unknown four-state value. `?` in a numeric literal is
an alternate spelling for Z, chosen because it visually communicates an
intentional do-not-care in wildcard contexts. Under `casex`, both become
wildcards during the case comparison, but they still communicate very
different intent to a reader:

~~~text
X  -> the value is unknown
?  -> this pattern position is intentionally irrelevant
~~~

Outside a wildcard-aware construct, neither slogan changes the actual literal
semantics: X is X, while ? is Z.

### 8. What is the difference between `casez` and `casex`?

`casez` wildcards Z/? in either operand; `casex` wildcards X as well. With
`value = 4'b1X01` and concrete item `4'b1001`, `casez` does not match and
`casex` does. That extra expression-side masking is the source of `casex`'s
X-optimism risk.

`casez` is not entirely risk-free: an actual Z in the input is also ignored.
If Z is illegal on an RTL control signal, assert that the signal is known.

### 9. Why write `4'b1???` rather than `4'b1zzz` in `casez`?

They have the same literal value and the same wildcard behavior under `casez`.
The difference is communication. `?` says “pattern hole” to a human reader;
`z` normally describes a real high-impedance value on a resolved signal.
Writing `?` prevents the reader from wondering whether actual tri-state
behavior was intended.

### 10. Are wildcard rules applied only to the item pattern?

No. In `casez` and `casex`, the rule applies to any qualifying bit in either
the case expression or the case item. This symmetry is easy to miss and is the
reason `casex` can hide an uninitialized input.

There is an essential nuance. With item `4'b1?01`, `casez` matches input
`4'b1X01` because the **item's** `?` removes that position from comparison.
That does not mean `casez` treats input X as a wildcard. With concrete item
`4'b1001`, the same input fails under `casez` and matches under `casex`.

### 11. In `casex`, do X, Z, and `?` all mean do-not-care during matching?

Yes, for each bit participating in that `casex` comparison, whether the
qualifying value came from the expression or an item. This rule is limited to
matching. It does not make an X assignment, an X in arithmetic, or an X in an
ordinary equality comparison universally irrelevant.

If several items match after wildcard removal, the first matching case item is
executed. That can turn an accidental unknown into unintended source-order
priority.

### 12. What is the actual use of `casex`?

Its language-level use is compact **symmetric** matching where X and Z in
either operand are deliberate mask bits. That was useful in legacy modeling,
some testbench lookup code, and older synthesis styles. It can still be used
for a tightly controlled verification-only value that deliberately carries
mask bits.

That situation is uncommon in synthesizable control logic. If the expression
is a live opcode, state, request vector, or address, an X usually means a bug
that should remain visible, so `casez`, asymmetric wildcard matching, or an
explicit mask is clearer.

### 13. Why does `casex` exist if it is usually recommended to avoid it?

Language existence and modern style guidance answer different questions.
`casex` predates many SystemVerilog alternatives, is part of Verilog's
historical four-state matching model, and must remain for compatibility with
existing designs and simulators. A construct can be standardized and useful in
a niche while still being a poor default for new RTL.

### 14. Why do `casex` examples often write `4'b1xxx`?

Mostly pedagogy: the author wants the spelling itself to advertise that
`casex` treats X specially. It distinguishes the example visually from the
usual `casez` example. It does not mean X is required. Under `casex`, these
items have the same wildcard shape:

~~~systemverilog
4'b1xxx
4'b1zzz
4'b1???
~~~

For intentional item-side do-not-care bits, `4'b1???` communicates intent more
accurately.

### 15. Why do examples use `?` with `casez` but X with `casex`?

It is a teaching convention used to expose the extra character class each
statement ignores:

~~~text
casez -> Z and ?
casex -> X, Z, and ?
~~~

The convention helps compare definitions, but it can accidentally teach the
false rule that `casex` requires X patterns. It does not.

### 16. If `?` already communicates “I don't care,” why use X as a wildcard?

For a hand-written case item, there is usually no good reason; prefer `?`.
An X can arise from an evaluated item expression or a legacy mask value rather
than from a literal template, and `casex` will treat it as a wildcard. That
symmetry is the feature. It is also the hazard, because the same rule applies
when the X was accidental.

If the design depends on an X being interpreted as a mask, document that
unusual contract explicitly and keep it away from ordinary runtime data.

### 17. Is the main difference that `casez` does not ignore an actual input X,
while `casex` does?

Yes. That is the most useful short summary, with one qualification: `casez`
can still match an input X at a position that an item-side Z/? already masks.
To test the difference, keep the corresponding item bit concrete.

For robust RTL, a practical policy is:

1. use plain `case` for exact decode;
2. use `casez` with `?` only where item bits are intentionally irrelevant;
3. assert that control inputs contain no X/Z when that is a design invariant;
4. avoid `casex` for live RTL control signals;
5. consider explicit masks, wildcard equality, or `case ... inside` when
   asymmetric item-side matching is supported by the target tools.

## Revision checks

1. What value does `?` represent inside a based numeric literal?
2. Why does `4'b1???` fail to wildcard ordinary data under plain `case`?
3. Which operand sides can contribute wildcards in `casez` and `casex`?
4. Why must the item bit be concrete when demonstrating input-side X masking?
5. Why can `casez` still hide an undriven-Z input?
6. How do wildcard coverage bins differ from wildcard case matching?
7. Why is deterministic stimulus preferable for a coverage lesson?
8. Which three self-check outputs prove the matching rules?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera/IEEE SystemVerilog working-group activity and free-standard access](https://www.accellera.org/activities/ieee)
- [Accellera SV-BC discussion of symmetric `casex`/`casez` operands and asymmetric alternatives](https://www.accellera.org/images/eda/sv-ec/1963.html)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera SV-EC wildcard-bin discussion and the 2-state sampled-value rule](https://www.accellera.org/images/eda/sv-ec/7634.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
