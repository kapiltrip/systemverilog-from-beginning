# Part 39 — Parameterized Transaction Mailbox

[← Part 38](../38-constructor-injected-mailbox/README.md) · [Learning index](../README.md) · [Part 40 →](../40-interface-modport-and-virtual-interface/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `009` |
| Indexed EDA name | `SV 39 - Parameterized Transaction Mailbox` |
| Stable playground | [tEEA](https://edaplayground.com/x/tEEA) |
| Saved code ID | `7362039` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Live result | **Pass:** ten transaction transfers |

This part moves from an untyped integer mailbox to `mailbox #(transaction)`. The generator creates and randomizes a transaction object on every iteration, then puts its handle into the typed mailbox. The driver retrieves that handle and reads its fields.

## Object and mailbox flow

~~~text
generator: t = new() → randomize t → mbx.put(t)
                                      │
                                      ▼
driver:                   mbx.get(container) → read container.din1/din2
~~~

`put` transfers a class handle. It does not automatically deep-copy the object. This example is safe from producer-side mutation because the generator creates a fresh `t` on every iteration and does not modify an already queued object afterward.

## Question from the code: can `get` work without making the container's object?

**Question in the source**

> `mbx.get(container); // can i do it without making its handler`

**Where it appears**

`testbench.sv:40`

**Answer**

Yes, `container` does not need `container = new()` before this `get`. It is a handle variable, initially null. `get(container)` removes a transaction handle from the mailbox and assigns that returned handle into `container`; afterward `container` refers to the same transaction object the generator put.

A compatible destination variable is still required because `get` is an output-style operation. You could reuse another `transaction` handle variable, but you cannot retrieve the object and then access its fields without retaining the returned handle somewhere.

Constructing `container` immediately before `get` would allocate an object whose handle is then overwritten by the mailbox result, creating useless allocation.

## Why does the simulation end even though `join` waits on a `forever` loop?

After the tenth item, the driver delays 10 ns and then blocks on an empty mailbox. The generator is finished, so there are no future timed events. The parent is still waiting inside `join`, but the simulator can end because every remaining process is blocked and no future activity is scheduled. A production testbench should use an explicit end-of-test protocol instead of relying on quiescence.

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// AND parametrized mailbox

class transaction ;
  rand bit [3:0] din1;
  rand bit [3:0] din2;
  bit [4:0] dout ;


endclass
class generator;
  transaction t;
  mailbox #(transaction) mbx;
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;

  endfunction
  task main();
    for(int i =0; i<10 ; i++)begin
      t=new();  // handler for transaction class new handle for each transaction
      assert(t.randomize ) else $display("Randmoization falied ");
      $display("GEN: DATA SENT IN din1 and din 2 is %0d and %0d after randomization   " , t.din1 , t.din2);
      mbx.put(t);
      #10;
    end
  endtask
endclass
class driver;
  transaction container ;
  mailbox #(transaction) mbx;

  function new(mailbox #(transaction) mbx);  // parametrized it to work with transaction class

    this.mbx=mbx;
  endfunction

  task main();
    forever begin
      mbx.get(container); // can i do it without making its handler
      $display("[DRV] : DATA RCVD : din1 is %0d and in din2 is %0d ", container.din1, container.din2);
      #10;

    end
  endtask
endclass
module tb;
  generator g;
  driver d ;
  mailbox #(transaction) mbx;
  initial begin
    mbx=new();
    g= new(mbx);
    d=new(mbx);
    fork
      //to hold the simulation until we can complete the transaction
      g.main();
      d.main();

    join
  end
endmodule
~~~

## What happened when it ran

The live Questa run completed with 0 errors and one access-related optimization warning. It printed ten generator lines and ten matching driver lines. Each `container` received the transaction handle dequeued from the mailbox.

## Points to remember

- A typed mailbox rejects incompatible payload types at compile time.
- `get` can assign a retrieved object handle into a currently null handle variable.
- Mailbox transfer does not clone a class object.
- Create a fresh transaction or an explicit copy before queuing if the producer will reuse and mutate its object.
- `randomize()` is clearer with parentheses even though the saved simulator accepted the zero-argument spelling shown here.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera SystemVerilog class-handle and mailbox material](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [Accellera mailbox language discussion](https://www.accellera.org/images/eda/sv-bc/att-0852/01-SVChairsChampionsResponse.pdf)
