# Part 08 — Queue operations

EDA Playground: [https://edaplayground.com/x/bKTC](https://edaplayground.com/x/bKTC)
EDA Playground Name: `Queue Operations`

This part introduces an unbounded queue and the operations used to build, insert, remove, and delete queue elements.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The deterministic verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv). The exact captured EDA Playground source is preserved separately in [`testbench.sv`](testbench.sv). The original page used separate time-zero processes; the corrected version keeps the dependent operations in one sequence so every expected queue state is deterministic.

~~~systemverilog
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
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including its original two time-zero processes and comments. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
// Code your testbench here
// or browse Examples
// QUEUES
module tb;
  int q[$];
  int data=0;  // SO I HAVE TO DEFINE DATA HERE, FOR USING IT LATEER ? ALSO TELL ME WHY CANT I DEFINTE LIKE THIS IN
               // THE INITIAL BLOCK , int data = q.pop_front()
  int data1=0;
  initial begin
    q = {1,2,3};
    $display("The value of the queue is holding is %0p" , q);
  end
  // to push data now in the queue
  initial begin
    q.push_front(4);
    $display("The value of the queue is holding is %0p" , q);
    q.push_back(7);
    $display("The value of the queue is holding is %0p" , q);
    //at an index 2
    q.insert(2,10); // index, number to be inserted
    $display("The value of the queue is holding is %0p" , q);
    // POP OPERATIONS

    data = q.pop_front();
    $display("The value of the queue is holding is %0p , and the data removed is %0d" , q , data );
    data1 = q.pop_front();
    $display("The value of the queue is holding is %0p , and the data removed is %0d" , q , data1 );
    q.delete(1);
    $display("The value of the queue is holding is %0p" ,q);

  end
endmodule
~~~

## Answers and notes

- `int q[$]` declares an unbounded queue of `int` elements. Its size changes as elements are inserted or removed.
- `q = {1, 2, 3}` initializes the queue with three values.
- `push_front` inserts at index 0; `push_back` appends after the last element.
- `insert(2, 10)` places 10 at index 2 and shifts the old index-2 and later values right.
- `pop_front()` returns the first value and removes it from the queue. The result must be stored in a variable such as `data` if it is needed after the call.
- `delete(1)` removes the element currently at index 1 and closes the gap.
- A declaration such as `int data = q.pop_front();` inside a procedural block is legal SystemVerilog, but a module-scope variable is useful when several processes or checks need to observe the removed value.
- The self-checking version uses a second queue, `expected`, to compare every queue element after each operation.

## Detailed discussion

### Queue indices and size

Queue indices start at 0. After initialization, `q` is `'{1, 2, 3}` and `q.size()` is 3. The queue has no fixed upper bound in its declaration, so `push_front`, `push_back`, and `insert` can grow it without a new allocation statement.

The sequence in this part is:

| Phase | Operation | Queue after the operation |
| --- | --- | --- |
| 0 ns | `q = {1, 2, 3}` | `'{1, 2, 3}` |
| 1 ns | `q.push_front(4)` | `'{4, 1, 2, 3}` |
| 2 ns | `q.push_back(7)` | `'{4, 1, 2, 3, 7}` |
| 3 ns | `q.insert(2, 10)` | `'{4, 1, 10, 2, 3, 7}` |
| 4 ns | `data = q.pop_front()` | `'{1, 10, 2, 3, 7}`, `data == 4` |
| 5 ns | `data1 = q.pop_front()` | `'{10, 2, 3, 7}`, `data1 == 1` |
| 6 ns | `q.delete(1)` | `'{10, 3, 7}` |

### Why the original two-process version was risky

The original page initialized the queue in one `initial` block and began pushing values in another. Both blocks start at time 0, so source order is not a synchronization mechanism. The simulator happened to show the intended sequence, but the language does not require one process to finish before another begins. The repository version performs the dependent operations in one process and adds delays only to make each state visible.

### Verification

The saved Riviera-Pro run compiled with zero errors and zero warnings. Its output showed the same seven queue states listed above and ended naturally after the final queue operation. The local testbench adds a PASS/FAIL endpoint and checks both the removed values and every remaining queue element.

### Points to remember

- A queue is an ordered, dynamically sized collection.
- Insertion changes later indices; removal shifts later elements left.
- Store the return value of `pop_front()` when the removed item matters.
- Use explicit synchronization when multiple processes access the same queue.
