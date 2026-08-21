# Part 36 — Semaphore-Controlled Resource Access

[← Part 35](../35-fork-join-variants/README.md) · [Learning index](../README.md) · [Part 37 →](../37-generator-driver-mailbox/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `006` |
| EDA Playground Name | `SV 36 - Semaphore-Controlled Resource Access` |
| Stable playground | [gjuf](https://edaplayground.com/x/gjuf) |
| Saved code ID | `7361930` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Live result | **Pass:** 0 errors, 5 total warnings |

This part runs two tasks concurrently but gives them a semaphore containing one key. Each task obtains the key before its ten-iteration loop and returns it afterward, so the whole first loop and whole second loop execute as two serialized critical sections.

## Semaphore mental model

`sem = new(1)` creates one available key. `sem.get(1)` is blocking: if the key is unavailable, the caller waits. `sem.put(1)` returns it. A semaphore controls permission to enter a protected region; unlike a mailbox, it does not carry the randomized data.

The waiting queue is FIFO **after requests arrive at the semaphore**, but that does not make the source's first forked statement a guaranteed winner. `send_first()` and `send_second()` start concurrently, and the language does not impose source-order priority on their initial `get(1)` calls. Whichever call reaches the available key first acquires it; if several callers are already blocked, the semaphore serves those queued requests in arrival order.

Because the key is held across each entire loop, the structural ordering is:

1. Whichever task acquires the key prints ten values from its class-specific range.
2. It returns the key.
3. The other task obtains the key and prints its ten values.

If the goal were to interleave individual accesses safely, `get` and `put` would move inside the loop around only the shared-resource operation.

## Questions from the code, explained

### What does `data1 = f.data1` do?

**Question in the source**

> `data1= f .data1;  // what is this line doing`

**Where it appears**

`testbench.sv:21`; the same question is repeated for `s.data1` at line 33.

**Answer**

It reads the randomized `data1` property from object `f` and copies that integer value into the `main` object's own `data1` property. The two properties have the same name but belong to different objects/scopes. Changing `main.data1` afterward would not change `f.data1` because integers are copied by value.

In the saved code, the subsequent display prints `f.data1` or `s.data1` directly, so the copied `main.data1` value is not otherwise used. The assignment demonstrates a shared destination but is not required for the displayed output.

### Does `join` make the second task wait for the first?

Not by itself. `fork` starts both tasks concurrently, and `join` makes the parent wait for both to finish. The semaphore is what makes one child block while the other holds the single key. With `sem = new(2)`, both could obtain one key and execute concurrently.

### Why did Questa warn about `randomize()`?

Both calls use the return value of `randomize()` as a discarded stand-alone function result. The simulator reports implicit-void-cast warnings. A robust test checks the Boolean result:

~~~systemverilog
assert (f.randomize()) else $fatal("first randomization failed");
~~~

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
class first ;
  rand int data1;
  constraint data1_c { data1<10 ; data1>0 ; }
endclass
class second;
  rand int data1;
  constraint data1_c {data1 > 10 ; data1 <20 ; }
endclass
class main;
  semaphore sem;
  first f ;
  second s;
  int data1;

  task send_first();
    sem.get(1); // to get the semaphore access
    for(int i =0 ; i<10 ; i++)begin
      f.randomize();
      data1= f .data1;  // what is this line doing
      $display("First access of semaphore and Data sent is : %0d " , f.data1 );
      #10;

    end
    sem.put(1);
    $display("semaphore unoccupied by first task ");
  endtask
  task send_second();
    sem.get(1); // to get the semaphore access
    for(int i =0 ; i<10 ; i++)begin
      s.randomize();
      data1= s.data1;  // what is this line doing
      $display("First access of semaphore and Data sent is : %0d " , s.data1 );
      #10;
    end
    sem.put(1);
      $display("semaphore unoccupied for second task  ");
  endtask

task run();
  sem = new(1);
  f=new();
  s=new();
  fork
    send_first();
    send_second();

  join // blocking in nature second waits till first, release the semaphore since sem(1)
endtask
endclass

module tb;
  main m ;
  initial begin
    m=new();
    m.run();

  end
  initial begin
    #250;
    $finish();

  end
endmodule
~~~

## What happened when it ran

The live Questa run completed with 0 errors and 5 total warnings. In that observed run, `send_first()` acquired the key first: ten values were within 1–9, followed by ten values within 11–19. That confirms single-key serialization but does not establish a guaranteed winner for every legal simulation. `$finish` ran at 250 ns.

## Points to remember

- A semaphore guards access; a mailbox transports data.
- The location of `get`/`put` defines the size of the critical section.
- `join` waits for children; the semaphore orders their protected work.
- FIFO waiting order preserves request-arrival order; it does not define which concurrent caller arrives first.
- Always check `randomize()` when failure would invalidate the test.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera SystemVerilog semaphore and mailbox donation](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [Accellera semaphore/mailbox language discussion](https://www.accellera.org/images/eda/sv-bc/att-0852/01-SVChairsChampionsResponse.pdf)
