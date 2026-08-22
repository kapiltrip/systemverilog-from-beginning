# SystemVerilog Functional Coverage

> Lab record: the EDA Playground Riviera-PRO license failure, the exact Aldec
> `run.do` flow, and the verified Vivado/XSim workaround.

[All learning tracks](../README.md) · [Code index](Codes/README.md) · [Revision plan](../WORKING_REVISION_PLAN.md) · [Live tracker](../REVISION_TRACKER.md)

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
│   │   ├── print-coverage-report.tcl
│   │   └── README.md
│   └── README.md
└── README.md
```

Generated ACDB/XCRG databases, compiled XSim objects, logs, and HTML reports
remain outside the tracked study material.
