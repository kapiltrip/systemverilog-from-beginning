# SystemVerilog Functional Coverage

> Ordered coverage lessons, exact playground captures, the EDA Playground
> Riviera-PRO incident, the verified Questa `run.do` repair, and local
> Vivado/XSim evidence.

[All learning tracks](../README.md) · [Code index](Codes/README.md) · [Capture audit](docs/internal/EDA_PLAYGROUND_AUDIT.md) · [Revision plan](../WORKING_REVISION_PLAN.md) · [Live tracker](../REVISION_TRACKER.md)

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

## August 23 archive — Parts 02 through 10

Seven stable public playgrounds were first archived as Parts 02–08. The later
FSM repair in named page `FU8E` was then completed, commented, saved, rerun, and
archived as Part 09. The later blank-name `Ztfn` bin-filtering lesson was saved,
rerun, and archived as Part 10. Intermediate `Kd8_` remains an unarchived working
draft. The newest browser page is now a fresh unsaved blank playground with no
stable code ID and remains outside the archive.

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

Parts 02–08 and 10 have blank saved Name fields. Part 09 is named **FSM Coverage
Report - Fixed Timing and Finish**. Placeholder-only design panes are omitted;
Parts 07 and 09 have substantive RTL and therefore store `design.sv` beside the
testbench and custom `run.do`. Source spelling and comments are preserved;
Part 10 additionally normalizes browser trailing whitespace and redundant
terminal blank lines. Deeper Q&A remains in each matching README.

All nine pages use Siemens Questa 2025.2, compile option `-timescale 1ns/1ns`,
Run Options `-voptargs=+acc=npr`, and an enabled custom `run.do`. Parts 02–08
were independently compiled, simulated, and reported with Vivado/XSim 2024.1.
Parts 09–10 were verified directly in their saved Questa qrun configurations,
which printed complete covergroup data despite having no explicit `-coverage`
switch.
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
│   └── README.md
├── docs/
│   └── internal/
│       └── EDA_PLAYGROUND_AUDIT.md
└── README.md
```

Generated ACDB/XCRG databases, compiled XSim objects, logs, and HTML reports
remain outside the tracked study material.
