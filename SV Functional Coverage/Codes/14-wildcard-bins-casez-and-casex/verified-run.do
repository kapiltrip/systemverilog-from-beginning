# Run until the finite testbench has no scheduled activity.
run -all;

# Print covergroup, coverpoint, and bin details after all samples.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
