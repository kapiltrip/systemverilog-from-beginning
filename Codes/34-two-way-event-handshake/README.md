# Part 34 — Two-Way Event Handshake

[← Part 33](../33-generator-driver-completion-event/README.md) · [Learning index](../README.md) · [Part 35 →](../35-fork-join-variants/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `004` |
| EDA Playground Name | `SV 34 - Two-Way Event Handshake` |
| Stable playground | [9yRX](https://edaplayground.com/x/9yRX) |
| Saved code ID | `7361661` |
| Simulator | Aldec Riviera Pro 2025.04 |
| Compile / run options | `-timescale 1ns/1ns` / `+access+r` |
| Live result | **Pass:** ten transfers, finish at 100 ns |

This part repairs the loose producer/consumer timing from Part 33 with a two-event protocol. `next` acknowledges each copied stimulus, while `done` announces that the generator completed all ten iterations.

## Handshake timeline

For iteration $i$:

1. The generator assigns a new `data1` value and then delays 10 ns.
2. The receiver also wakes after its 10 ns delay, copies `data1` into `data2`, and triggers `next`.
3. The generator's `wait(next.triggered)` observes that acknowledgement and starts the next iteration.
4. After the tenth acknowledgement, the generator triggers `done`; `wait_event` calls `$finish` at 100 ns.

The live run reports matching generated and received values for all ten transfers. This is stronger than Part 33 because the producer does not advance until the receiver acknowledges the current shared value.

## Why use an event instead of predicting priority from delays?

Equal delays do not create a robust priority rule between concurrent processes. Both tasks can resume in the same time slot, and relying on which active-region process executes first is a race. The event expresses the dependency directly: the generator advances only after `next` has been triggered.

`wait(next.triggered)` is particularly useful because the receiver may trigger `next` earlier in the same time slot. The triggered property remains true for that slot, so the generator does not miss the acknowledgement.

## Why does `fork...join` not return normally here?

`receiver()` contains `forever`, so one child process never completes. An ordinary `join` waits for all children; therefore the enclosing initial block would remain inside the join forever. Simulation still ends because the concurrently running `wait_event()` child calls `$finish`. This is intentional control flow, but a larger environment would normally give the receiver a shutdown protocol rather than terminating from inside one child.

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// to keep a tract of initial begin block so i cant predict based on delay in the initial begin block there, priority so for that we
module tb;
  int i =0;
  bit [7:0] data1 , data2;
  event done ;
  event next ;
  task generator();
    for(i=0 ; i<10 ; i++)begin
      data1 = $urandom();
      $display("Data sent by generator is %0d generated at time %0t " , data1 , $time);
      #10;
      wait(next.triggered);  // at 100 ns this will be triggered i.e 90 + 10 hence the time == 100

    end
    // outside the for loop
    -> done;
  endtask
  task receiver();
    forever begin
      #10;
      data2=data1;
      $display("Data received by receiver is %0d " , data2);
      ->next; // current stimuli is copied

    end
  endtask

  task wait_event();
    wait(done.triggered);
    $display("Transmitter sent all the transaction in time %0t " , $time);
    $finish();

  endtask
  initial begin
    fork  // fork join will hold the simulation unless all the process will complete
          // to schedule multiple processes / tasks in parallel

      generator();
      receiver();
      wait_event();

    join
  end
endmodule
~~~

## What happened when it ran

The saved Riviera run compiled with 0 errors and 0 warnings. It printed ten matching generator/receiver pairs at 10 ns intervals, then `Transmitter sent all the transaction in time 100` and stopped at 100 ns.

## Points to remember

- Express inter-process dependencies with synchronization, not assumed execution priority.
- A request/acknowledgement handshake protects one shared value at a time.
- Events synchronize but do not buffer multiple outstanding values.
- `join` waits for every child, including a child with a `forever` loop.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera `event.triggered` proposal](https://www.accellera.org/images/eda/sv-ec/att-0976/01-event.pdf) · [Accellera scheduling semantics](https://www.accellera.org/images/eda/sv-ec/att-2537/prop-15.pdf)
