# Part 31 — Event Trigger and Wait Semantics

[← Part 30](../30-fifo-transaction-and-weighted-constraints/README.md) · [Learning index](../README.md) · [Part 32 →](../32-event-races-and-triggered-state/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `001` |
| Indexed EDA name | `SV 31 - Event Trigger and Wait Semantics` |
| Stable playground | [F6qC](https://edaplayground.com/x/F6qC) |
| Saved code ID | `7361162` |
| Simulator | Aldec Riviera Pro 2025.04 |
| Compile / run options | `-timescale 1ns/1ns` / `+access+r` |
| Live result | **Pass:** 0 compile errors, 0 compile warnings |

This part introduces a named SystemVerilog event as a synchronization signal between concurrent processes. The event carries no transaction payload; it communicates that something happened. Later parts pair events with mailboxes, where the mailbox carries data and the event communicates progress or completion.

## Execution trace

| Simulation point | Trigger process | Waiting process |
|---:|---|---|
| 0 ns | Suspends at `#10` | Suspends at `@(a)` |
| 10 ns | Executes `->a` | `@(a)` wakes in the same time slot |
| 10 ns, same slot | Event remains in its triggered state | `wait(a.triggered)` is already true, then the display runs |

The observed output is `Event received at a time 10000`. With the saved `` `timescale 1ns/1ps``, the logical delay is 10 ns; the simulator's default `%t` formatting presents that instant in precision-sized units, hence 10000 ps.

## Questions and corrections from the code

### Is `wait(a.triggered)` nonblocking?

No. `wait(expression)` is a blocking statement: the process suspends until the expression is true. In this particular execution it does not visibly delay because `a.triggered` is already true when the process reaches it.

### What is the real difference between `@(a)` and `wait(a.triggered)`?

`@(a)` waits for a future trigger and can miss a trigger that occurred before the process began waiting. `a.triggered` is a Boolean event property that remains true for the rest of the current simulation time slot after the event fires. Waiting on that property removes the same-time-slot ordering race: it succeeds whether the trigger or the wait process executes first within that slot.

Calling these forms “edge sensitive” and “level sensitive” is a useful analogy, but the “level” is not an electrical signal level. It is the temporary true state of the event's `triggered` property.

### What should carry completion versus transaction data?

- Use an event to say “generation finished,” “driver accepted the item,” or “this phase may continue.”
- Use a mailbox to transfer a transaction object between producer and consumer.
- Use a semaphore to arbitrate a limited shared resource.
- Use a virtual interface to let a class-based component access static DUT signals.

These mechanisms solve different problems and are often combined in a layered testbench.

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
//generation , finished generation , event trigger , @ , wait
//semaphore to access resources , (interface ) get / put
// mailboxes to send transaction data , from generator to driver also b/w monitor and  socreboard
// 1 ) to conver process is finished like sending of transactions is finished
// 2)to transfer a transaction , (b/w generator adn driver and monitor and scoreboard
//event -> to convay messages b/w classes
`timescale 1ns/1ps

module tb;
  //trigger and event ->
  // to sense and event , edge sensitive and blocking @
  // to sense an event , level sensitive and non blocking wait ()
  event a ;
  initial begin
    #10;
    ->a;

  end
  initial begin
    @(a); // wait for a blockign edge sensitive
    wait(a.triggered); // level sensitive

    $display("Event received at a time %0t" , $time);
  end
endmodule
~~~

## What happened when it ran

The saved Riviera run compiled with 0 errors and 0 warnings, triggered the event after `#10`, printed the message at the 10 ns instant, and ended when no scheduled activity remained.

## Points to remember

- A named event is synchronization state, not a value-carrying channel.
- `wait(...)` blocks whenever its expression is false.
- `event.triggered` remains true for the current time slot, not forever.
- `%t` formatting can display a different unit scale from the source delay; the simulated instant is still 10 ns here.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera event-variable proposal](https://www.accellera.org/images/eda/sv-ec/att-0976/01-event.pdf) · [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html)
