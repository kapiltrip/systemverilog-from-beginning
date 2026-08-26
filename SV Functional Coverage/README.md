# SystemVerilog Functional Coverage

> Ordered coverage lessons, exact playground captures, the EDA Playground
> Riviera-PRO incident, the verified Questa `run.do` repair, and local
> Vivado/XSim evidence.

[All learning tracks](../README.md) · [Question-to-Code Index](../QUESTION_TO_CODE_INDEX.md#sv-functional-coverage) · [Projects](Projects/README.md) · [Section 10 video plates](PLATES.md) · [Code index](Codes/README.md) · [Capture audit](docs/internal/EDA_PLAYGROUND_AUDIT.md) · [Revision plan](../WORKING_REVISION_PLAN.md) · [Live tracker](../REVISION_TRACKER.md)

## Section 10 project archive

The completed V136 FIFO playground is preserved separately as
[Project 01 — Synchronous FIFO Design and Functional Coverage](Projects/01-fifo-functional-coverage/README.md).
It includes the exact design, stimulus, coverage model, verified 64.10% report,
the corrected `reg`/`wire` explanation, and the elaboration-time meaning of
`parameter` and `localparam`. V137 and V138 remain unused starter plates and
were not copied into the project archive.

## Incident summary

On August 22, 2026, the first functional-coverage example was prepared in the
public EDA Playground [`aaMC`](https://edaplayground.com/x/aaMC). The goal was
to reproduce the instructor's workflow: run the testbench in Aldec
Riviera-PRO, save its ACDB database, generate a detailed text report, and print
that report directly in the simulator Log.

| Stage | Observed result |
|---|---|
| Original EDA source | A missing semicolon after `#500` stopped compilation near line 39 |
| Source repair | Changed `#500` to `#500;`; compilation then completed with 0 errors and 0 warnings |
| Riviera-PRO run | Stopped before simulation because no valid Aldec license was available |
| Retry | The same license failure occurred again |
| Diagnosis | EDA Playground infrastructure/license availability, not a SystemVerilog or `run.do` error |
| Questa repair | Replaced the Vivado-only XCRG file-reader with Questa's native `coverage report -cvg -details` command |
| EDA Playground result | Questa 2025.2 printed 100% functional coverage, 8/8 bins covered, and 0 errors in playground [`Y9rT`](https://edaplayground.com/x/Y9rT) |
| Local fallback | Vivado/XSim 2024.1 ran successfully at 101 ns with 0 DUT errors |
| Coverage result | 100%: one covergroup instance and 4/4 bins for both `a` and `b` |

The Riviera-PRO failure may be transient because EDA Playground uses a shared
remote simulator service. Changing `acdb` commands cannot repair a missing
server-side Aldec license; the correct action is to retry later or use another
simulator that supports the required functional-coverage features.

The browser task stopped at the pre-save review. Therefore, `aaMC` identifies
the playground used during troubleshooting, but the task transcript does not
prove that the added `run.do` and `#500;` edit were saved back to its public
version.

## August 23–25 archive — Parts 02 through 29

Seven stable public playgrounds were first archived as Parts 02–08. The later
FSM repair in named page `FU8E` was then completed, commented, saved, rerun, and
archived as Part 09. The later blank-name `Ztfn` bin-filtering lesson was saved,
rerun, and archived as Part 10. The next completed opcode, ignore-bin, and
illegal-bin/report-timing lessons are Parts 11–13. Intermediate `Kd8_` remains
an unarchived working draft. `CBg2` is only a separate copy of the already
archived FSM repair. Part 14 preserves the public
[`rzC3`](https://edaplayground.com/x/rzC3) wildcard-bin/encoder source and adds
a deterministic self-checking variant. Its inherited 200 ns Tcl window stopped
after 10 of 15 samples; the public page is now saved with `run -all` and was
rerun through all fifteen samples in Questa 2025.2. Part 15 repairs the
`fTK4` counter lesson's competing net driver, unknown startup, disabled custom
Tcl, and never-ending `run -all` flow; its finite report now reaches 100%.
Parts 16–21 archive completed Section 6 in course order. All six saved pages
were freshly rerun in Chrome. Part 20 deliberately keeps the user's exact ALU
source, documents why its 100% input/opcode coverage hides broken duplicate
case labels, and adds a separate self-checking correction that passes locally.
Parts 22–26 archive the five substantive Section 7 sampling-method lessons.
V092 and V102 are intentionally omitted because they add no substantive
completed code; V092's useful sampling-event comment was moved into Part 22.
Parts 27–29 archive the three authored Section 8 cross-coverage lessons.
V108, V110, and V114 remained unchanged generated starters, while V116 added
only a range question; the latter is preserved and fully answered in Part 29
instead of creating four redundant parts.
Parts 30–33 archive the retained Section 9 transition-bin lessons: simple FSM
transitions, consecutive repetition, and nonconsecutive/goto repetition. V128
is intentionally omitted because its live testbench is still identical to the
generated summary starter and contains no authored comment to migrate.

| Part | Link / code ID | Captured topic | Verified result |
|---:|---|---|---|
| 02 | [`pvaX`](https://edaplayground.com/x/pvaX) / `7379868` | Instance/type goals and coverpoint weights | 84.375%: `a` 4/4, `b` 3/4 |
| 03 | [`jq_V`](https://edaplayground.com/x/jq_V) / `7380397` | Conditional sampling with `iff` | 100%: 4/4 bins from seven accepted samples |
| 04 | [`XzxS`](https://edaplayground.com/x/XzxS) / `7380475` | Automatic bins and `auto_bin_max` | Displayed 3.51562%: `a` 9/128, uninitialized `b` 0/64 |
| 05 | [`T8wy`](https://edaplayground.com/x/T8wy) / `7380484` | Explicit bins and fixed-size bin arrays | 7.03125%: `a` 9/64, uninitialized `b` 0/64 |
| 06 | [`HU_T`](https://edaplayground.com/x/HU_T) / `7380503` | Default bins for unused values | 0%: instance constructed, but no sampling event/call |
| 07 | [`J_mr`](https://edaplayground.com/x/J_mr) / `7380513` | Multiplexer signal coverpoints | 100%: all 14 bins; only 19 known `y` samples expose stale-output sampling |
| 08 | [`ggV4`](https://edaplayground.com/x/ggV4) / `7380537` | Enumerated-state coverpoint | 25%: `auto_s0` covered, three enum bins missing |
| 09 | [`FU8E`](https://edaplayground.com/x/FU8E) / `7380862` | FSM state coverage and report timing | Questa: 100%, named `state` coverpoint, `auto[s0]` 8 hits, `auto[s1]` 12 hits |
| 10 | [`Ztfn`](https://edaplayground.com/x/Ztfn) / `7380906` | `with`-filtered and overlapping bins | Questa: `a` 10/22, `b` 4/21; weighted total 32.25% |
| 11 | [`KN3M`](https://edaplayground.com/x/KN3M) / `7381043` | Legal, illegal, and out-of-domain opcode bins | Exact saved source/settings; random outcome intentionally not treated as deterministic closure |
| 12 | [`cNZW`](https://edaplayground.com/x/cNZW) / `7381556` | Ignore bins and domain closure | Questa: 77/77 scored bins, 100%, 0 compile/simulation errors |
| 13 | [`grxa`](https://edaplayground.com/x/grxa) / `7381590` | Illegal-bin precedence and report timing | Questa: 5/5 scored bins, 100%; three intentional illegal-bin hits |
| 14 | [`rzC3`](https://edaplayground.com/x/rzC3) / `7381709` | Wildcard bins, `casez`, and expression-side X masking under `casex` | Questa: 15 samples, 0 errors, `x` 3/4, `y` 4/13, covergroup 52.88%; deterministic variant 100% |
| 15 | [`fTK4`](https://edaplayground.com/x/fTK4) / `7382217` | Counter wildcard bins, known startup, and finite reporting | Questa: 4/4 bins, 100%; hits 2/16/9/16; 0 compile/simulation errors |
| 16 | [`VnNY`](https://edaplayground.com/x/VnNY) / `7382335` | Reusable-covergroup fundamentals and the input-copy trap | Questa: both instances 0/16, total 0%; 0 errors |
| 17 | [`bCAQ`](https://edaplayground.com/x/bCAQ) / `7382336` | Live covergroup formals passed by reference | Questa: `A` 14/16, `B` 16/16; total 93.75%; 0 errors |
| 18 | [`mzj8`](https://edaplayground.com/x/mzj8) / `7382338` | Range configuration passed by value | Questa: 6/6 range bins, 100%; 0 errors |
| 19 | [`E8nM`](https://edaplayground.com/x/E8nM) / `7382342` | Generic-covergroup `ref`/`input` rules | Questa: 3/6 bins, 50%; 0 errors; one source lifetime warning |
| 20 | [`KXaD`](https://edaplayground.com/x/KXaD) / `7382343` | Reusable operand/opcode coverage for an ALU | Exact source 14/14 bins, 100%, but RTL case audit fails; corrected XSim variant passes at 100% |
| 21 | [`biwn`](https://edaplayground.com/x/biwn) / `7382346` | Three reusable memory address windows | Questa: low 100%, mid 37.50%, high 75%; type metric 70.83%; 0 errors |
| 22 | [`twJN`](https://edaplayground.com/x/twJN) / `7382349` | Automatic covergroup sampling event | Questa: 12 samples, 4/4 bins, 100%; 0 source errors or warnings |
| 23 | [`EfZj`](https://edaplayground.com/x/EfZj) / `7382352` | Manual prebuilt `sample()` | Questa: 8 calls, 3/4 bins, 75%; 0 source errors or warnings |
| 24 | [`L5Mb`](https://edaplayground.com/x/L5Mb) / `7382353` | User-defined sampling inside a task | Questa: 50 calls, 14/16 bins, 87.50%; finite-clock repair |
| 25 | [`cGiB`](https://edaplayground.com/x/cGiB) / `7382356` | Enum-state sampling inside a function | Questa: `write/read/NOP/error` hits 0/1/7/2, 75%; repaired `void` helper |
| 26 | [`hfW3`](https://edaplayground.com/x/hfW3) / `7382357` | Property-local sampling and readback assertion | Questa: three region bins, 100%; assertion successes at 25/45/65 ns |
| 27 | [`uU5k`](https://edaplayground.com/x/uU5k) / `7382359` | Cross-coverage fundamentals | Questa: 60/68 raw bins; 95.23%; three-way crosses 20/24 each |
| 28 | [`gsC6`](https://edaplayground.com/x/gsC6) / `7382360` | Operation-specific write/read cross models | Questa: write 100%, read 97.91%; combined 98.95% |
| 29 | [`S_vr`](https://edaplayground.com/x/S_vr) / `7382364` | `binsof`/`intersect` cross filtering | Questa: 25/28 raw bins; 95.83%; filtered crosses 4/4 and 9/12 |
| 30 | [`v_s9`](https://edaplayground.com/x/v_s9) / `7382369` | Legal FSM toggles and low-input holds | Questa: `c1` 100%, `c2` 80%, total 90% |
| 31 | [`gsCG`](https://edaplayground.com/x/gsCG) / `7382370` | Reset-gated legal hold transitions | Questa: `cp_d` 100%, `cp_state` 50%, total 75% |
| 32 | [`M9vN`](https://edaplayground.com/x/M9vN) / `7382373` | Consecutive `[*4]` repetition and overlapping windows | Questa: one bin at 100% with 41 hits |
| 33 | [`SYhE`](https://edaplayground.com/x/SYhE) / `7382374` | Nonconsecutive and goto repetition | Questa: active goto bin at 100% with 1 hit |

Parts 02–08 and 10–15 have blank saved Name fields. Part 09 is named **FSM
Coverage Report - Fixed Timing and Finish**. Placeholder-only design panes are
omitted; Parts 07 and 09 have substantive saved RTL and therefore store
`design.sv` beside the testbench and custom `run.do`. Part 14 stores all three
exact public panes under their normal names plus `verified-*` deterministic
sources. Part 15 stores its substantive counter RTL, repaired testbench, and
finite `run.do`. Source spelling and comments are preserved in each exact capture;
browser trailing whitespace is normalized. Deeper Q&A remains in each matching
README.

Parts 16–21 have explicit saved names matching their Section 6 videos. Parts
16–19 and 21 omit the placeholder-only design pane; Part 20 retains its
substantive ALU RTL and a separate `verified-*` layer. Each README answers every
natural-language source comment and records the exact direct-run evidence.

Parts 22–26 have explicit saved names matching retained Section 7 videos.
Their design panes are placeholders and are omitted. Each lesson stores the
saved testbench and `run.do`, renders both in its README, and answers the
source comments about sampling events, user-defined method formals, enum
coverage, and property semantics.

Parts 27–29 have explicit saved names matching V106, V107, and V112. Their
design panes are the common placeholder and are omitted. Each README preserves
the exact substantive testbench and common `run.do`, reconstructs the cross
denominators and reported metrics, and answers the source comments. The V116
`intersect {[5:7]}` question is consolidated into Part 29.

Parts 30–33 have explicit saved names matching V121, V122, V124, and V126.
Parts 30 and 31 retain their substantive FSM RTL; Parts 32 and 33 omit the
placeholder design pane. Each README preserves the exact source, reconstructs
the live trace and report, and corrects the source comments where needed. In
particular, Part 33 records one live hit rather than its copied 41-hit comment
and identifies the two out-of-bounds dynamic-array reads.

All thirty-two source pages from Parts 02–33 use Siemens Questa 2025.2, compile option `-timescale 1ns/1ns`,
Run Options `-voptargs=+acc=npr`, and an enabled custom `run.do`. Parts 02–08
were independently compiled, simulated, and reported with Vivado/XSim 2024.1.
Parts 09, 10, 12–33 were verified directly in saved Questa qrun
configurations, which printed complete covergroup data despite having no
explicit `-coverage` switch. Part 11 is retained as exact saved-source evidence
because its ten random draws and illegal hits are seed-dependent. Part 14's
direct Questa run covered 7/17 declared bins and exposed that only `zz` is
reachable among its nine exact X/Z output bins. Vivado/XSim 2024.1 runs the RTL
but rejects those exact four-state bins; the deterministic `verified-*` variant
uses portable known-value goals and makes closure independent of random seed.
Part 15's finite 450 ns direct run covered all four wildcard range bins and
proved the report fault was repaired without adding an explicit `-coverage`
switch.
Parts 16–21 were freshly rerun on August 24. Part 20's corrected deterministic
layer additionally passed all eight ALU checks and reached 100% in XSim/XCRG.
Parts 22–26 were freshly rerun in Chrome on August 25 (IST); all five retained
pages completed with zero compile/simulation errors and printed detailed
coverage reports.
Parts 27–29 were then freshly rerun from the saved Section 8 pages; all three
completed with zero compile/simulation errors. The only warning on each was
the saved `+acc` optimization notice.
Parts 30–33 were freshly rerun from the saved Section 9 pages; all four
completed with zero compile/simulation errors and the same `+acc` notice.
V128 was loaded only to verify exact starter parity and was omitted as requested.
The [ordered code index](Codes/README.md) links every lesson and records the
per-flow evidence. The
[capture audit](docs/internal/EDA_PLAYGROUND_AUDIT.md) records the browser
boundary, source fingerprints, and verification evidence.

## Intended Riviera-PRO setup

The EDA Playground settings were:

- language: SystemVerilog;
- simulator: **Aldec Riviera-PRO**;
- **Use run.do Tcl file** enabled;
- an added testbench-side file named exactly `run.do`;
- read visibility enabled through `+access+r`.

EDA Playground's official settings documentation confirms that the custom-DO
option requires a file named `run.do`: [Settings & Buttons — Simulators](https://eda-playground.readthedocs.io/en/latest/settings.html#simulators).

### Commented `run.do`

```tcl
# Load the compiled design into Aldec Riviera-PRO.
# +access+r enables read-only signal visibility for debugging and waveforms.
vsim +access+r;

# Run until the testbench calls $finish or no scheduled events remain.
run -all;

# Save the collected functional-coverage data.
# On EDA Playground, the default database filename is fcover.acdb.
acdb save;

# Generate a detailed plain-text report from the ACDB coverage database.
# -db selects the database, -txt selects text format,
# -o names the output file, and -verbose includes detailed coverage data.
acdb report -db fcover.acdb -txt -o cov.txt -verbose;

# Run the server's cat command so cov.txt appears in the Results/Log pane.
exec cat cov.txt;

# Close the simulator cleanly after the report is printed.
exit;
```

If Riviera reports that `fcover.acdb` does not exist, the database name can be
made explicit:

```tcl
acdb save -file fcover.acdb;
```

`acdb` is Aldec-specific. These commands are not interchangeable with
Questa/ModelSim commands or Vivado/XSim commands. Tcl/DO-file comments begin
with `#`, not `//`.

## Verified Questa setup and exact `run.do`

The verified EDA Playground [`Y9rT`](https://edaplayground.com/x/Y9rT) uses
**Siemens Questa 2025.2** with **Use run.do Tcl file** enabled. Its Run Options
are:

```text
-coverage -voptargs=+acc=npr
```

The exact working `run.do` is tracked at
[`Codes/01-basic-coverpoints/run.do`](Codes/01-basic-coverpoints/run.do):

```tcl
# Run the simulation until all scheduled activity is complete.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details
# directly in the Questa transcript/EDA Playground Log.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
```

The previous `.do` file tried to read
`coverage_report/functionalCoverageReport/xcrg_func_cov_report.txt`. That path
belongs to the Vivado/XCRG flow and does not exist during a Questa run. Questa
collects functional coverage when `-coverage` is enabled and prints its native
report with `coverage report -cvg -details`; no XCRG text file is needed.

The verified Log reported:

```text
TOTAL COVERGROUP COVERAGE: 100.00%
Covergroup Bins: 8 covered, 0 missing
Coverpoint a: 4/4 bins covered
Coverpoint b: 4/4 bins covered
vsim: Errors: 0, Warnings: 0
```

Questa also emitted one optimization warning because `+acc` is deprecated in
favor of newer visibility options. This warning does not affect the report.

## Failure sequence and diagnosis

The first browser run did reach the Riviera-PRO compile flow, proving that the
simulator selection and `run.do` connection were active. It initially stopped
on the source typo:

```systemverilog
// Incorrect
#500

// Corrected
#500;
```

After this repair, EDA Playground reported 0 compilation errors and 0 warnings.
Only then did the separate license failure appear. The run was retried once
after a short delay and failed for the same reason. This separation matters:

1. the original syntax error was in the testbench;
2. the syntax repair succeeded;
3. the later failure occurred while acquiring permission to run Riviera-PRO;
4. therefore the later failure was external to the coverage model and
   `run.do` contents.

## Verified Vivado/XSim fallback

The example was copied into
[`Codes/01-basic-coverpoints`](Codes/01-basic-coverpoints/README.md) and run with
Vivado/XSim 2024.1 using the `xvlog → xelab → xsim → xcrg` flow.

### First local failure: absolute Windows coverage path

Vivado accepted the SystemVerilog files and covergroup, but the first
elaboration attempt failed while compiling XSim's generated C. The coverage
directory had been supplied as an absolute Windows path. XSim embedded raw
backslashes from that path into generated C, which made its generated source
invalid.

The coverage model itself was not rejected. Using a relative database path
avoided the generated-path problem:

```powershell
xelab tb -s tb_sim -debug typical -cov_db_dir ./coverage -cov_db_name fcover
```

### Working command flow

Run these commands from a dedicated generated-output directory while the two
source paths point to the lesson files:

```powershell
xvlog -sv ../design.sv ../testbench.sv
xelab tb -s tb_sim -debug typical -cov_db_dir ./coverage -cov_db_name fcover
xsim tb_sim -R
xcrg -dir ./coverage -db_name fcover -report_dir ./coverage_report -report_format all
```

AMD documents the standalone simulation stages and options in
[Vivado UG900](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation/xsim-Executable-Options).

### Verified result

The completed local run produced:

```text
PASS at 101 ns
Functional coverage: 100%
Covergroup instances: 1
Coverpoint a: 4/4 bins covered
Coverpoint b: 4/4 bins covered
DUT errors: 0
```

The testbench waits `#1` after driving `a` and before calling `ci.sample()`.
That lets the continuous assignment `b = a` settle before both values are
sampled and compared.

## Printing the Vivado report in the Log

Riviera's `exec cat cov.txt` prints the ACDB report in its Log. Vivado's XCRG
report is a different format, but its text file can be copied into the XSim Log
with Tcl:

```tcl
set report_file [open {coverage_report/functionalCoverageReport/xcrg_func_cov_report.txt} r]
puts [read $report_file]
close $report_file
```

The reusable commented version is
[`print-coverage-report.tcl`](Codes/01-basic-coverpoints/print-coverage-report.tcl).

The first attempt to reopen XSim showed two report sections because `xcrg` had
appended to an existing report. Regenerating into a fresh report directory
produced one `PASS` line, one XCRG heading, one set of coverpoint tables, and no
`ERROR` or `FAIL` lines.

The final visible Log contained the equivalent of:

```text
PASS: all 10 samples propagated correctly; functional coverage was sampled.

================ VIVADO XCRG FUNCTIONAL COVERAGE REPORT ================

Coverage Score            : 100
Total no of Cover Groups  : 1

a: Expected=4, Covered=4, Uncovered=0, Percent=100
b: Expected=4, Covered=4, Uncovered=0, Percent=100

auto[0] hit 1 time
auto[1] hit 2 times
auto[2] hit 5 times
auto[3] hit 2 times
```

## Why the instructor showed 75% but this run showed 100%

Both results can be correct. Each two-bit coverpoint has four automatic bins.
The instructor's random run apparently reached three values, so it displayed
75%. This local run reached all four values, so it displayed 100%. Functional
coverage records what was sampled in that run; random stimulus does not promise
the same bin hits every time.

## Practical decision guide

| Symptom | Meaning | Next action |
|---|---|---|
| Syntax error before simulation | Source problem | Repair the exact reported source line and recompile |
| No valid Aldec/Riviera license | Remote service capacity/license problem | Retry later or run locally in a supported simulator |
| `fcover.acdb` missing | Database was not saved under the expected name | Use `acdb save -file fcover.acdb` and verify the run reached simulation |
| Questa cannot open an XCRG report path | A Vivado-only report-reader was used with Questa | Use `coverage report -cvg -details` in `run.do`; retain the exact verified Run Options for that lesson |
| XSim generated-C failure with an absolute path | Local Vivado path-generation problem | Use relative `-cov_db_dir ./coverage` |
| Report appears twice | Existing XCRG report was appended/reused | Generate into a fresh report directory |
| PASS but coverage below 100% | DUT check passed, but some bins were not sampled | Inspect the missing bins before changing stimulus or the model |

## Tracked lesson files

```text
SV Functional Coverage/
├── Codes/
│   ├── 01-basic-coverpoints/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   ├── print-coverage-report.tcl
│   │   └── README.md
│   ├── 02-instance-type-goals-and-weights/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 03-conditional-sampling-with-iff/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 04-automatic-bins-and-auto-bin-max/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 05-explicit-bins-and-fixed-bin-arrays/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 06-default-bins-for-unused-values/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 07-multiplexer-signal-coverpoints/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 08-enumerated-state-coverpoint/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 09-fsm-state-coverage-and-report-timing/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 10-with-filtered-and-overlapping-bins/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 11-legal-illegal-and-out-of-domain-opcode-bins/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 12-ignore-bins-and-domain-closure/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 13-illegal-bin-precedence-and-report-timing/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 14-wildcard-bins-casez-and-casex/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   ├── verified-design.sv
│   │   ├── verified-testbench.sv
│   │   ├── verified-run.do
│   │   └── README.md
│   ├── 15-counter-wildcard-bins-and-finite-reporting/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 16-reusable-covergroup-fundamentals/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 17-reusable-covergroup-pass-by-reference/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 18-reusable-covergroup-pass-by-value/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 19-generic-covergroup-rules/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 20-reusable-covergroup-alu-use-case/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   ├── verified-design.sv
│   │   ├── verified-testbench.sv
│   │   ├── verified-run.do
│   │   └── README.md
│   ├── 21-reusable-covergroup-memory-range-use-case/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 22-covergroup-event-sampling/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 23-manual-prebuilt-sample-method/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 24-user-defined-sample-in-task/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 25-user-defined-sample-in-function/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   ├── 26-user-defined-sample-in-property/
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   └── README.md
├── Projects/
│   ├── 01-fifo-functional-coverage/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── run.do
│   │   └── README.md
│   └── README.md
├── docs/
│   └── internal/
│       └── EDA_PLAYGROUND_AUDIT.md
└── README.md
```

Generated ACDB/XCRG databases, compiled XSim objects, logs, and HTML reports
remain outside the tracked study material.
