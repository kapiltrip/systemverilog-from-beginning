# Part 41 — Layered Adder Testbench and Object Copies

[← Part 40](../40-interface-modport-and-virtual-interface/README.md) · [Learning index](../README.md) · [Part 42 →](../42-error-injection-with-inheritance/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `011` |
| Indexed EDA name | `SV 41 - Layered Adder Testbench and Object Copies` |
| Stable playground | [Xcxx](https://edaplayground.com/x/Xcxx) |
| Saved code ID | `7362765` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Live result | **Pass:** 16 generated and driven transactions; finish at 320 ns |

This part combines a transaction, generator, typed mailbox, driver, virtual interface, DUT, and completion event. It is the first complete layered mini-environment in the repository, although it still lacks a monitor and scoreboard.

## Component flow

~~~text
transaction t
    │ randomize + copy
    ▼
generator ── mailbox #(transaction) ──> driver ── virtual interface ──> add DUT
    │                                      │
    └──────── genDone event ───────────────┴─ top ends the run
~~~

## Questions from the code, explained

### How does sending `t.copy()` prevent repeated/overwritten values?

**Question in the source**

> `mbx.put(t.copy); // ... HOW WILL THIS REMOVE THE REPEATED VALUES`

The generator deliberately reuses one `transaction` object so its `randc` state persists across all 16 calls. If it put the same handle each time, queued entries could all refer to one mutable object; later randomization would change what earlier entries appear to contain. `copy()` allocates a new object and copies `a` and `b`, so each mailbox entry owns an independent snapshot.

This is an independent copy, but “deep copy” is more significant when a transaction contains nested class handles, queues of objects, or other reference-like members. Here all copied fields are simple bits, so there is no nested object graph to recurse through. Also, `sum` is not copied, so the method is intentionally incomplete for response state.

The copy does not eliminate legitimate random repeats in general. Here `a` and `b` are `randc`, so each field individually cycles through 0–15 before repeating; the pair `(a,b)` is not guaranteed to visit 256 unique combinations.

### What does it mean to send a copy of an object?

`t.copy()` returns a new transaction handle whose selected properties contain the current source values. `mbx.put(...)` queues that new handle. Producer and consumer can then mutate their respective objects without aliasing the same transaction instance.

### Is the manual `#20` delay needed?

It is needed for this exact source's pacing, but it is not a robust synchronization protocol. It spaces generation to roughly one clock period and lets the driver keep up. A better environment uses a bounded mailbox, request/acknowledgement event, or clock-aware sequencing so correctness does not depend on matching a literal delay to the clock period.

### What is the use of `d.aif = aif`?

**Question in the source**

> `d.aif=aif ; // what is the use of this`

It binds the driver's virtual-interface variable to the concrete `add_interface` instance in `tb`. Without this assignment, `d.aif` is null and the first `@(posedge aif.clk)` dereference cannot access the DUT signals.

### What does `done = g.genDone` do?

SystemVerilog event assignment aliases the synchronization object: `done` and `g.genDone` refer to the same underlying event. When the generator triggers `genDone`, `wait(done.triggered)` observes it. This is not a delayed forwarding process; both names identify shared event state after the assignment.

### Why does every displayed `sum` remain zero?

The transaction's `sum` field is never assigned from `aif.sum`. The generator displays a stimulus object before driving, and the driver displays the same stimulus snapshot; neither component acts as a monitor. The DUT does update its interface output, but no testbench code samples that output back into `container.sum`. A monitor and scoreboard are the next architectural layers needed to check the result.

## Design code

~~~systemverilog
// Code your design here
// Code your design here
module add(
  input [3:0]a,b,
  input clk,
  output reg [4:0] sum
);
  always @(posedge clk)begin
       sum <= a+b;

  end
endmodule
~~~

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
//INTERFACE : class will communicate with dut how?
class transaction ;
  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [4:0] sum;
  function void display();
    $display("value of a is %0d \t and value of b is %0d \t and their sum is %0d " , a,b, sum );
    endfunction
  // CREATE A DEEP COPY
  function transaction copy(); // copies current ojbects attributes
    copy=new();
    copy.a=this.a;
    copy.b=this.b;
  endfunction
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  event genDone ;
  function new (mailbox #(transaction) mbx) ;
    this.mbx=mbx; //
    t=new(); //WE HAVE A SINGLE OBJECT NOW RULE 1 ) ADD TRANSACTION CONSTRUCTOR IN GEN CUSTOM CONSTRUCTOR
  endfunction


  task run();
    for(int i =0 ; i<16;i++ )begin
      //t=new(); // we need  a deep copy INDEPENDENT SPACE OBJECT

      assert(t.randomize()) else $display("Randomization failed ");
      $display("[GEN] : DATA SENT TO DRIVER ");
      t.display();
      mbx.put(t.copy); // 1) send a copy and 2) sending deep copy HOW WILL THIS REMOVE THE REPEATED VALUES
      #20; //MANUAL DELAY IS NOT NEEDED HERE, OK
      $display("[GEN] : DATA ");
    end                //what it means to send a copy of the object
     ->genDone; //triggering the event now ,                   // RULE2 SEND A COPY OF TRANSACTION B/W DRIVER AND GENERATOR
    endtask
endclass


class driver;
  virtual add_interface.DRV aif;
  mailbox #(transaction) mbx;
  transaction container;
  event next ;
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;

  endfunction

   task run();
   forever begin
     mbx.get(container); // transaction type container

     @(posedge aif.clk);
     aif.a=container.a;
     aif.b=container.b;
     $display("[DRV] : INTERFACE TRIGGERED ");
     container.display();  // display the value received form the mailbox
     ->next; // event triggered next ;

    end
   endtask
endclass


module tb;
  add_interface aif();
  driver d;
  generator g;
  event done ;

  mailbox #(transaction) mbx;
  initial begin
    aif.clk<=0;
  end
  always #10 aif.clk = ~ aif.clk ;

  add dut(
    .a(aif.a),
    .b(aif.b),
    .clk(aif.clk),
    .sum(aif.sum)
  );

  initial begin
    mbx=new();
    g=new(mbx); // TRANSACTION OJBECT will be created here,
    d=new(mbx);
    d.aif=aif ; // what is the use of this
    done = g.genDone ;
  end
  initial begin
    fork
      g.run();
      d.run();

    join_none //non blocking
    wait(done.triggered);
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

  end
  /*
  initial begin
    #400;
    $finish();

  end
  */
endmodule

interface add_interface;
  logic [3:0] a ; //equivalent logic type defined in interface
  logic [3:0] b;
  logic [4:0] sum;
  logic clk ;
  modport DRV (output a,b,input sum, clk );// A AND B will have o/p direction rest all r inputs

endinterface
~~~

## What happened when it ran

The saved Questa run compiled with 0 errors and completed at 320 ns. It produced 16 generator/driver pairs; each individual `randc` field visited all values 0–15 once in the observed cycle. Every displayed transaction `sum` stayed zero because no monitor sampled the DUT response. One access-setting optimization warning was reported.

## Points to remember

- Reusing one randomized object preserves its `randc` history.
- Queue a copy when the producer will mutate the source object again.
- A copy method copies only the fields its body assigns.
- Bind the virtual interface before starting the driver.
- A driver applies stimulus; a monitor must sample DUT response; a scoreboard compares expected and actual values.
- Literal delays are pacing, not a substitute for protocol synchronization.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera class handles/copy and mailbox material](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [Accellera SystemVerilog interfaces paper](https://www.accellera.org/images/eda/sv-bc/att-10226/Interfaces_Future.pdf) · [Accellera event proposal](https://www.accellera.org/images/eda/sv-ec/att-0976/01-event.pdf)
