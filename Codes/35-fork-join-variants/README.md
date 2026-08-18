# Part 35 — `fork...join` Variants

[← Part 34](../34-two-way-event-handshake/README.md) · [Learning index](../README.md) · [Part 36 →](../36-semaphore-controlled-resource-access/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `005` |
| EDA Playground Name | `SV 35 - Fork-Join Variants` |
| Stable playground | [B3zJ](https://edaplayground.com/x/B3zJ) |
| Saved code ID | `7361681` |
| Simulator | Aldec Riviera Pro 2025.04 |
| Compile / run options | `-timescale 1ns/1ns` / `+access+r` |
| Live result | **Pass:** parent continues at time 0 |

This playground keeps `join` and `join_any` as commented alternatives and activates `join_none`, making the three parent-process behaviors easy to compare.

## Exact timing comparison

| Terminator | When the parent continues | Result for this code |
|---|---:|---|
| `join` | After every child completes | 30 ns |
| `join_any` | After the first child completes | 20 ns; task 2 remains active until 30 ns |
| `join_none` | Immediately after spawning children | 0 ns |

The live output begins with the `third()` message and the following display at time 0, before either forked task announces its start. The child processes then start, task 1 completes at 20 ns, and task 2 completes at 30 ns.

This ordering corrects the nearby comment suggesting that `first()` blocks before `second()`. Both calls are separate concurrent child processes. Their first statements are eligible to run in the same time slot; `join_none` simply lets the parent also proceed without waiting.

## How to wait later after `join_none`

`wait fork;` suspends the current process until all outstanding child processes spawned by that process have completed. It is useful when the parent must do some immediate setup or logging after `join_none` and then synchronize later. `disable fork` terminates outstanding descendants and should be used carefully because its scope can affect more children than intended.

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  task first ();
    $display("Task 1 started at %0t " , $time);
    #20;
    $display("Task 1 completed at %0t " , $time);
  endtask
  task second ();
    $display("Task 2 started at %0t " , $time);
    #30;
    $display("Task 2 completed at %0t " , $time);
  endtask

  task third ();
    $display("Reached next to join at time  %0t " , $time);

  endtask

  initial begin
    fork                 // allow to join multiple process in parallel
      first();           // will block first, then second

      second();
    //join
    //join_any

    join_none // totally non blocking
    // to call all the tasks in parallel , join_any or join_none
    // only when all the processes in fork join complete its execution
    third(); // will even finish at 2000 ns
    $display("Reached third after the end of first at time  %0t " , $time);
  end
endmodule
~~~

## What happened when it ran

Riviera compiled with 0 errors and 0 warnings. `third()` and the parent display ran at time 0, task 1 completed at 20 ns, task 2 completed at 30 ns, and simulation ended when all remaining activity was exhausted.

## Points to remember

- Forked statements are concurrent child processes.
- `join_none` controls the parent wait policy; it does not delay child startup.
- `join_any` does not automatically kill the unfinished children.
- Use timestamps to test scheduling claims instead of relying on source order.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera scheduling semantics](https://www.accellera.org/images/eda/sv-ec/att-2537/prop-15.pdf) · [EDA Playground settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
