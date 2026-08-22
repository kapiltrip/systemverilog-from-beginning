# Print Vivado's native functional-coverage text report in the Tcl/XSim log.
#
# Run this after xcrg has generated:
#   coverage_report/functionalCoverageReport/xcrg_func_cov_report.txt
#
# This is the Vivado/XSim equivalent of Aldec Riviera-PRO's:
#   exec cat cov.txt

set coverage_report {coverage_report/functionalCoverageReport/xcrg_func_cov_report.txt}

if {![file exists $coverage_report]} {
    error "Coverage report not found at $coverage_report. Run xcrg first."
}

set report_file [open $coverage_report r]
puts [read $report_file]
close $report_file
