# The testbench has a forever clock, so use a finite report window.
run 450ns;

# Print covergroup, coverpoint, and bin details after all intended phases.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
