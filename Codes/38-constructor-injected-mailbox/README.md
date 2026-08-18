# Part 38 — Constructor-Injected Mailbox

[← Part 37](../37-generator-driver-mailbox/README.md) · [Learning index](../README.md) · [Part 39 →](../39-parameterized-transaction-mailbox/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `008` |
| Indexed EDA name | `SV 38 - Constructor-Injected Mailbox` |
| Stable playground | [gjvi](https://edaplayground.com/x/gjvi) |
| Saved code ID | `7361990` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Live result | **Pass:** 0 errors, 1 optimization warning |

This part keeps the same integer mailbox transfer as Part 37 but passes the shared channel through each component's constructor. That small change makes the dependency explicit: a generator or driver cannot be constructed without being given the communication channel it needs.

## Why constructor injection is stronger

Part 37 constructs empty components and later assigns `g.mbx` and `d.mbx2`. Forgetting either post-construction assignment leaves a null mailbox handle and causes a runtime failure when the component calls `put` or `get`.

Here the top creates the mailbox first:

~~~systemverilog
mbx3 = new();
g = new(mbx3);
d = new(mbx3);
~~~

Each constructor stores that same handle with `this.mbx = mbx` or `this.mbx2 = mbx`. `this` identifies the object property; the unqualified `mbx` on the right is the constructor argument. No mailbox is duplicated.

The source still uses an untyped mailbox, so Part 39 adds the next improvement: `mailbox #(transaction)`.

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
// mailboxes between 2 classes i.e between generator and driver and monitor and scoreboard
class generator ;
  int data= 12;
  mailbox mbx;
  function new(mailbox mbx);
    this.mbx=mbx;
  endfunction
  task run();
    mbx.put(data);
    $display("[GEN] : SENT DATA : %0d" , data);
  endtask
endclass

class driver;
  int container =0 ;
  mailbox mbx2;

  function new(mailbox mbx);
    this.mbx2=mbx;
  endfunction

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
    mbx3= new();
    g=new(mbx3);
    d=new(mbx3);


    g.run();
    d.run();

  end
endmodule
~~~

## What happened when it ran

The live Questa run compiled and simulated with 0 errors. The only warning came from optimization access settings. The generator and driver both printed value 12, confirming that both constructors received the same mailbox object.

## Points to remember

- Construct shared resources before the components that require them.
- Passing a class handle copies the handle value, not the underlying object.
- Constructor injection prevents a half-configured component from existing.
- Type the mailbox when the channel has one intended payload type.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera SystemVerilog classes and mailboxes](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [EDA Playground settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
