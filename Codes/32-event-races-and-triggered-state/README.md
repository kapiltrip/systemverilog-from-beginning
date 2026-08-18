# Part 32 — Event Races and the `triggered` State

[← Part 31](../31-event-trigger-and-wait-semantics/README.md) · [Learning index](../README.md) · [Part 33 →](../33-generator-driver-completion-event/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `002` |
| Indexed EDA name | `SV 32 - Event Races and Triggered State` |
| Stable playground | [Lhvp](https://edaplayground.com/x/Lhvp) |
| Saved code ID | `7361563` |
| Simulator | Aldec Riviera Pro 2025.04 |
| Compile / run options | `-timescale 1ns/1ns` / `+access+r` |
| Live result | **Pass:** both event messages printed at time 0 |

This experiment places two event triggers and two waits in the same simulation time slot. It contrasts the commented `@(event)` version with the active `wait(event.triggered)` version and makes the same-time scheduling race visible.

## The central question: what is the “level” of an event?

**Question in the source**

> `wait(a1.triggered);  // ... level sensitive but what is the level actually ?`

**Where it appears**

`testbench.sv:32`

**Answer**

The level is the Boolean value of `a1.triggered`. It becomes true when `a1` is triggered and remains true for the rest of that simulation time slot. It returns to false when simulation advances to the next time slot. The property does not store a permanent “event happened” history and is not a hardware voltage level.

## Why the active version avoids a race

Both `initial` blocks start at time 0, and source order does not guarantee which process runs first. If the trigger process runs first, a later `@(a1)` has missed the trigger and can block forever. In contrast, a later `wait(a1.triggered)` sees the property still true in the current slot and proceeds.

The same reasoning applies to `a2`. The active source triggers `a1` and `a2` without a delay between them; the waiting process still prints both messages in the live Riviera run because both triggered properties are visible during that time slot.

This mechanism fixes a same-time-slot ordering race. It does not help if the wait begins in a later time slot, because the property will already have returned to false. For durable state, store an explicit flag/counter or use a mailbox whose queued item persists until retrieved.

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// edge sensitive @ and level sensitive wait
/*
module tb ;
  event a1,a2;
  initial begin
    ->a1; // triggering an event a1
    #10;
    ->a2;

  end
  initial begin
    @(a1);  // -> showing blocking behaviour edge sensitive
            // if i didnt sense a1 it will go to blocking state

    $display("Event a1 triggered ");
    @(a2);
    $display("event a2 triggered ");
  end
endmodule
*/
module tb ;
  event a1,a2;
  initial begin
    ->a1; // triggering an event a1
    //#10;
    ->a2;

  end
  initial begin
    wait(a1.triggered);  // -> showing blocking behaviour edge sensitive level sensitive but what is the level actually ?


    $display("Event a1 triggered ");
    wait(a2.triggered);
    $display("event a2 triggered ");
  end
endmodule

//generator multiple stimulai task _ gen to generate random value
// to send that value to the driver
// generator -> driver take out the data -> applying it to dut transaction to dut ->
// to hold simulation -> all task operating in parallel
~~~

## What happened when it ran

The saved Riviera configuration compiled with 0 errors and 0 warnings. It printed `Event a1 triggered` and `event a2 triggered` at time 0, confirming that the active waits observe triggers from the same time slot regardless of process ordering.

## Points to remember

- `@(e)` waits for the next trigger after the wait is armed.
- `wait(e.triggered)` can observe a trigger that already occurred earlier in the current time slot.
- A triggered property is a transient synchronization state, not a queued message.
- If synchronization must survive time advancement, use persistent state or a mailbox.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera `event.triggered` proposal and examples](https://www.accellera.org/images/eda/sv-ec/att-0976/01-event.pdf) · [Accellera scheduling proposal](https://www.accellera.org/images/eda/sv-ec/att-2537/prop-15.pdf)
