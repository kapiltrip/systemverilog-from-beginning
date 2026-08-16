// Code your testbench here
// or browse Examples
// Queue construction, insertion, removal, and deletion.
`timescale 1ns/1ps

module tb;
  int q[$];
  int expected[$];
  int data;
  int data1;
  int error_count;

  task automatic check_scalar(
    input string label,
    input int actual,
    input int expected_value
  );
    if (actual !== expected_value) begin
      error_count++;
      $error("FAIL: %s expected %0d, got %0d", label, expected_value, actual);
    end
  endtask

  task automatic check_queue(input string label);
    if (q.size() !== expected.size()) begin
      error_count++;
      $error("FAIL: %s expected queue size %0d, got %0d", label, expected.size(), q.size());
    end
    else begin
      for (int i = 0; i < q.size(); i++) begin
        check_scalar(label, q[i], expected[i]);
      end
    end
  endtask

  task automatic display_queue(input string label);
    $write("[%0t] %s:", $time, label);
    for (int i = 0; i < q.size(); i++) begin
      $write(" %0d", q[i]);
    end
    $display("");
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    error_count = 0;

    q = {1, 2, 3};
    expected = {1, 2, 3};
    display_queue("initial queue");
    check_queue("initial queue");

    #1;
    q.push_front(4);
    expected = {4, 1, 2, 3};
    display_queue("after push_front(4)");
    check_queue("push_front");

    #1;
    q.push_back(7);
    expected = {4, 1, 2, 3, 7};
    display_queue("after push_back(7)");
    check_queue("push_back");

    #1;
    q.insert(2, 10);
    expected = {4, 1, 10, 2, 3, 7};
    display_queue("after insert(2, 10)");
    check_queue("insert");

    #1;
    data = q.pop_front();
    expected = {1, 10, 2, 3, 7};
    display_queue("after first pop_front");
    $display("[%0t] first removed value: %0d", $time, data);
    check_scalar("first pop_front", data, 4);
    check_queue("first pop_front queue");

    #1;
    data1 = q.pop_front();
    expected = {10, 2, 3, 7};
    display_queue("after second pop_front");
    $display("[%0t] second removed value: %0d", $time, data1);
    check_scalar("second pop_front", data1, 1);
    check_queue("second pop_front queue");

    #1;
    q.delete(1);
    expected = {10, 3, 7};
    display_queue("after delete(1)");
    check_queue("delete");

    if (error_count == 0) begin
      $display("PASS: queue operations produced the expected states");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 08 self-check failed");
    end

    $finish;
  end
endmodule
