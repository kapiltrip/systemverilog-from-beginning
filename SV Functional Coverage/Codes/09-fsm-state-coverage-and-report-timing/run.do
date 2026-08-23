# Run for a finite duration so the forever clock/sampler cannot hang.
run 200ns;

# Print SystemVerilog covergroup, coverpoint, and bin details.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
