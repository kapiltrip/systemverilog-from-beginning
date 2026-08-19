# Part 37 — Generator–Driver Mailbox

[← Part 36](../36-semaphore-controlled-resource-access/README.md) · [Learning index](../README.md) · [Part 38 →](../38-constructor-injected-mailbox/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `007` |
| EDA Playground Name | `SV 37 - Generator-Driver Mailbox` |
| Stable playground | [A8er](https://edaplayground.com/x/A8er) |
| Saved code ID | `7361961` |
| Simulator | Aldec Riviera Pro 2025.04 |
| Compile / run options | `-timescale 1ns/1ns` / `+access+r` |
| Live result | **Pass:** 0 errors, 3 compile warnings |

This is the first lossless data-channel example in the new sequence. The generator puts integer 12 into a mailbox; the driver gets the same value. The top-level testbench constructs one mailbox object and assigns that same handle into both classes.

## Handle topology

~~~text
tb.mbx3 ─────┬────> generator.mbx
             └────> driver.mbx2
~~~

There are three mailbox handle variables but only one mailbox object. `mbx3 = new()` creates the object. The later handle assignments do not copy mailbox contents; they make both components refer to the same communication channel.

## Put/get behavior

- `put(data)` deposits a value. The default `new()` call creates an unbounded mailbox, so this put does not wait for capacity.
- `get(container)` is blocking. It waits until an item exists, removes the oldest item, and writes it into `container`.
- The saved calls are sequential (`g.run()` before `d.run()`), so the item is already queued when the driver calls `get`.

The three compile warnings report default parameter values for the untyped `mailbox`. The example is legal, but a typed mailbox such as `mailbox #(int)` gives compile-time payload checking and is preferable when the channel has one intended type.

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// mailboxes between 2 classes i.e between generator and driver and monitor and scoreboard
class generator ;
  int data= 12;
  mailbox mbx;

  task run();
    mbx.put(data);
    $display("[GEN] : SENT DATA : %0d" , data);
  endtask
endclass
class driver;
  int container =0 ;
  mailbox mbx2;
  task run();
    mbx2.get(container);
    $display("[DRV] : RCVD DATA : %0d" , container);
  endtask

endclass
module tb;
  generator g;
  driver d;
  mailbox mbx3;
  initial begin
    g=new();
    d=new();
    mbx3= new();
    g.mbx=mbx3;
    d.mbx2=mbx3;
    g.run();
    d.run();

  end
endmodule
~~~

## What happened when it ran

Riviera compiled with 0 errors and 3 untyped-mailbox warnings. It printed `[GEN] : SENT DATA : 12` followed by `[DRV] : RCVD DATA : 12`, then ended with no remaining activity.

## Points to remember

- Sharing a mailbox means sharing its handle, not copying the mailbox.
- A mailbox preserves items until a consumer retrieves them.
- `get` removes an item; `peek` would observe without removing it.
- Prefer a parameterized mailbox for payload type safety.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera SystemVerilog mailbox definition](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html)
