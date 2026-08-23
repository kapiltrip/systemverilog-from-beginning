# Run through all 15 samples, but stop before the testbench's later $finish.
run 200ns;

# Print SystemVerilog covergroup, coverpoint, and bin details
# after the covergroup has been constructed and sampled.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
