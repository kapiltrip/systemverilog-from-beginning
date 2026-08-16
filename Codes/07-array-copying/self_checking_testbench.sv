// Code your testbench here
// or browse Examples
// Whole-array assignment copies values into a separate fixed-size array.
`timescale 1ns/1ps

module tb;
  int arr1[5];
  int arr2[5];
  int dynamic_arr[];
  int arrfixed[30];
  int status;
  int error_count;

  task automatic check_element(
    input string label,
    input int index,
    input int actual,
    input int expected
  );
    if (actual !== expected) begin
      error_count++;
      $error("FAIL: %s[%0d] expected %0d, got %0d", label, index, expected, actual);
    end
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    error_count = 0;
    status = 0;

    // Populate arr1 and make arr2 visibly different before the copy.
    for (int i = 0; i < $size(arr1); i++) begin
      arr1[i] = 5 * i;
      arr2[i] = -1;
    end
    $display("[%0t] arr1 before copy: %0p", $time, arr1);
    $display("[%0t] arr2 before copy: %0p", $time, arr2);

    #1;
    arr2 = arr1;
    status = (arr1 == arr2);
    $display("[%0t] arr2 after whole-array copy: %0p", $time, arr2);

    if (status !== 1) begin
      error_count++;
      $error("FAIL: arrays should compare equal immediately after copying");
    end

    for (int i = 0; i < $size(arr1); i++) begin
      check_element("arr2 after copy", i, arr2[i], arr1[i]);
    end

    #1;
    arr2[2] = 11;
    status = (arr1 != arr2);
    $display("[%0t] arr2 after arr2[2] = 11: %0p", $time, arr2);

    if (status !== 1) begin
      error_count++;
      $error("FAIL: arrays should compare different after arr2[2] changes");
    end

    for (int i = 0; i < $size(arr1); i++) begin
      check_element("arr1 after arr2 mutation", i, arr1[i], 5 * i);
    end
    check_element("arr2 modified element", 2, arr2[2], 11);

    #1;
    dynamic_arr = new[5];
    for (int i = 0; i < dynamic_arr.size(); i++) begin
      dynamic_arr[i] = 5 * i;
    end
    $display("[%0t] dynamic_arr with five elements: %0p", $time, dynamic_arr);
    if (dynamic_arr.size() !== 5) begin
      error_count++;
      $error("FAIL: dynamic_arr should contain five elements");
    end

    #1;
    dynamic_arr = new[30](dynamic_arr);
    $display("[%0t] dynamic_arr after resizing: %0p", $time, dynamic_arr);
    if (dynamic_arr.size() !== 30) begin
      error_count++;
      $error("FAIL: dynamic_arr should contain thirty elements after resizing");
    end
    for (int i = 0; i < 5; i++) begin
      check_element("dynamic_arr preserved element", i, dynamic_arr[i], 5 * i);
    end

    arrfixed = dynamic_arr;
    $display("[%0t] arrfixed after dynamic-array copy: %0p", $time, arrfixed);
    for (int i = 0; i < $size(arrfixed); i++) begin
      check_element("arrfixed copied element", i, arrfixed[i], dynamic_arr[i]);
    end

    if (error_count == 0) begin
      $display("PASS: fixed-array, dynamic-array, and independent-copy checks passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 07 self-check failed");
    end

    $finish;
  end
endmodule
