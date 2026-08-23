# Run until the finite 15-sample testbench has no scheduled activity.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details after all samples.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
