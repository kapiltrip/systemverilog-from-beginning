# SystemVerilog Unified Revision Guide: Data Types and Object-Oriented Programming (OOP)

> **A Comprehensive Engineering Handbook and Dual-Track Revision Synthesis**  
> **Source Mapping:** First Revision (GitHub Lessons 01--21) & Second Revision (Laboratory Practice C1--C9 & OOP Blocks)  
> **Scope:** SystemVerilog 2-State/4-State Types, Simulation Scheduler, Packed/Unpacked Arrays, Dynamic Arrays, Queues, Subroutines, Tasks vs Functions, Argument Passing Semantics (`input`, `output`, `inout`, `ref`), Automatic Storage, Classes, Handles vs Objects, Composition, Encapsulation, Copying Mechanisms (Handle Copy, Shallow Copy, Recursive Deep Copy), Inheritance, Dynamic Polymorphism with Virtual Methods, Constructor Chaining (`super.new`).  
> **Exclusion Boundary:** Section 6 Constrained Randomization is explicitly excluded per revision guidelines.  
> **Language Standard:** IEEE Std 1800-2017 (SystemVerilog LRM).  
> **Simulator Verification:** AMD Vivado Simulator 2024.1 (64-bit build 5076996) -- 32/32 Deterministic Checks Passed.

---

## Contents

- [Executive Quick-Recall Cheat Sheet](#executive-quick-recall-cheat-sheet)
- [Master Cross-Revision Question Mapping Matrix](#master-cross-revision-question-mapping-matrix)
- [Part I: Data Types, Representation & Simulation Foundations](#part-i-data-types-representation--simulation-foundations)
  - [Section 1: Scalar Data Types, Signedness, and Value Systems](#section-1-scalar-data-types-signedness-and-value-systems)
  - [Section 2: Simulation Time, Timescale, Scheduling, and Clock Generation](#section-2-simulation-time-timescale-scheduling-and-clock-generation)
  - [Section 3: Arrays: Packed, Unpacked, and Memory Layouts](#section-3-arrays-packed-unpacked-and-memory-layouts)
  - [Section 4: Array Iteration and Loop Mechanics](#section-4-array-iteration-and-loop-mechanics)
  - [Section 5: Array Operations: Assignment, Comparison, and Dynamic Resizing](#section-5-array-operations-assignment-comparison-and-dynamic-resizing)
  - [Section 6: Queues: Syntax, Operations, and Performance](#section-6-queues-syntax-operations-and-performance)
- [Part II: Subroutines & Argument Passing Semantics](#part-ii-subroutines--argument-passing-semantics)
  - [Section 7: Tasks vs Functions](#section-7-tasks-vs-functions)
  - [Section 8: Argument Passing Modes & "How to Speak It" Interview Scripts](#section-8-argument-passing-modes--how-to-speak-it-interview-scripts)
- [Part III: Object-Oriented Programming (OOP) in SystemVerilog](#part-iii-object-oriented-programming-oop-in-systemverilog)
  - [Section 9: Classes, Handles, Objects, and Lifecycle](#section-9-classes-handles-objects-and-lifecycle)
  - [Section 10: Constructors, `this`, Encapsulation, and Composition](#section-10-constructors-this-encapsulation-and-composition)
  - [Section 11: Object Copying Mechanisms: Handle Copy vs Shallow Copy vs Deep Copy](#section-11-object-copying-mechanisms-handle-copy-vs-shallow-copy-vs-deep-copy)
  - [Section 12: Inheritance, Polymorphism, Virtual Methods, and Constructor Chaining](#section-12-inheritance-polymorphism-virtual-methods-and-constructor-chaining)
- [Part IV: Practice Code Bug Audit and Code Repairs](#part-iv-practice-code-bug-audit-and-code-repairs)
- [Part V: Active Recall Self-Test & Detailed Solutions](#part-v-active-recall-self-test--detailed-solutions)
- [Part VI: Simulation Verification Report & Standards Appendix](#part-vi-simulation-verification-report--standards-appendix)

---

## Executive Quick-Recall Cheat Sheet

| Technical Query | Strict Language Rule (IEEE 1800-2017) | Practical Verification Impact |
|---|---|---|
| **2-State vs 4-State Defaults** | 2-state types (`bit`, `byte`, `int`, `longint`) default to `0`. 4-state types (`logic`, `reg`, `integer`, `time`) default to `X` (never `Z`). | Uninitialized logic causes immediate `X` propagation in simulation; 2-state variables mask uninitialized states as zeros. |
| **Signedness Rules** | `byte`, `shortint`, `int`, `longint`, and `integer` default to **signed**. `bit` and `logic` default to **unsigned**. | `byte b = 130` stores `8'h82` and evaluates to `-126`. `bit [7:0] f = 130` evaluates to `+130`. |
| **Unpacked Concatenation vs Pattern** | `{1, 0, 1, 1}` is legal unpacked concatenation when the assignment target is an unpacked array. `'{1, 0, 1, 1}` is an assignment pattern. | Queues and dynamic arrays can be initialized with `{...}` without an apostrophe. Pattern replication requires `'{N{val}}`. |
| **Array Size Querying** | `$size(arr)` returns element count. `$bits(arr)` returns total bit count. `.size()` is a built-in method for dynamic arrays/queues. | `$sizeof()` is a C operator that does NOT exist in SystemVerilog. |
| **Loop Execution Time** | Loops (`for`, `foreach`, `repeat`, `while`) take **zero simulation time**. | Simulation time advances ONLY when blocking timing controls (`#`, `@`, `wait`) execute. |
| **Tasks vs Functions** | Functions cannot consume simulation time (no `#`, `@`, `wait`). Tasks can consume time. | Functions CAN have `output`, `inout`, and `ref` arguments in procedural contexts. Functions cannot call tasks directly. |
| **Pass-by-Value vs Ref** | `input` creates a local copy (modifications do not affect caller). `ref` creates a direct memory alias (immediate caller updates). | `ref` avoids stack copy overhead for large arrays. `ref` in static scopes (modules/interfaces) requires `automatic` lifetime. |
| **Passing Class Handles** | Passing a class handle as `input` copies the handle, but both caller and callee handles point to the **same object**. | Mutating `handle.prop` mutates the caller's object. Reassigning `handle = null` affects only the callee's local copy. |
| **Handle vs Shallow vs Deep Copy** | `b = a` copies handle (1 object, 2 aliases). `b = new a` shallow-copies outer scalars, shares nested handles. `copy()` clones nested objects. | Shallow copy does NOT call `new()` constructor or property initializers. Deep copy requires custom recursive cloning. |
| **Virtual Method Dispatch** | Declaring `virtual` binds calls at runtime based on the **object's actual type**, not the handle type. | In `Base f = s; f.display();`, if `display()` is virtual, `Child.display()` executes (NOT parent method!). |
| **Constructor Chaining (`super.new`)** | In derived classes, `super.new(...)` must be the **first executable statement** in the derived constructor. | Omitting `super.new()` causes implicit call `super.new()`, which fails compilation if the parent constructor requires arguments. |


## Master Cross-Revision Question Mapping Matrix

This matrix maps every question, discussion topic, and code exercise across both revision cycles:
1. **First Revision:** GitHub repository lessons `SV Basics/Codes/01` to `21` and `QUESTION_TO_CODE_INDEX.md`.
2. **Second Revision:** User laboratory practice snippets `C1` to `C9` and OOP code blocks.

| Topic / Category | First Revision Question (GitHub 01--21) | Second Revision Question / Code Comment (Practice) | Core Language Rule & Resolution | Interview / "How to Speak It" Talking Point |
|---|---|---|---|---|
| **Scalar Types & Signedness** | Part 04: What is the initial value of a 4-state variable? (README #1) | C1: `bit is a 2 state variable type, signed` (L4)<br>C2: `byte var = -126; // why its called variable` (L27) | `bit` is **unsigned**; `byte` is **signed** (2's complement). Uninitialized 4-state defaults to `X`, not `Z`. `var` is a keyword. | "Width and signedness are orthogonal decisions in SystemVerilog. An 8-bit `byte` stores -128 to 127; `bit [7:0]` stores 0 to 255." |
| **Simulation Time & Clocks** | Part 01: Retained values across time.<br>Part 02: Always without sensitivity.<br>Part 03: Phase shift vs startup offset. | C2: `$time` vs `$realtime` sampling (L29--30)<br>C9: `@(posedge clk)` clock task (L200--235) | `timescale` defines timeunit and precision grid. `$time` returns scaled integer; `$realtime` returns real. Clocks require `f = 1000/T_ns`. | "Simulation precision is the scheduling granularity. Processes execute concurrently; variables retain values persistently without decay." |
| **Array Shapes & Queries** | Part 05: Dynamic array initialization & shape.<br>Part 07: Why `$sizeof` does not work. | C3: `bit arr[] = {1,0,1,1};`<br>C3: `$size(arr1), $sizeof(arr)` (L46) | Dimensions before name are packed; after name are unpacked. `{...}` is valid unpacked concatenation. `$sizeof` does not exist in SV. | "Use `$size()` for element count, `$bits()` for bit-stream width, and `.size()` for dynamic arrays and queues. Never use C's `$sizeof`." |
| **Array Initialization** | Part 05: What does the initialization comment distinguish? | C4: `'{1,3,4,2,2}`, `'{5{0}}`, `'{default: 4}` (L60--63) | Assignment patterns require apostrophe-brace `'{...}`. Unpacked concatenation `{...}` is legal only with array target context. | "Assignment patterns support positional values, default fallbacks (`default: v`), and replication multipliers (`'{N{v}}`)." |
| **Array Iteration & Loops** | Part 06: Why `foreach` visits 0 to 9.<br>Part 10: Loop execution time. | C5: `for`, `repeat(10)`, `foreach(arr[j])` (L72--97) | `foreach` automatically declares local read-only index conforming to array bounds. Loops execute in 0 simulation time. | "`foreach` is bounds-safe and handles non-zero low bounds. Repetition alone never advances time; explicit delays or events are required." |
| **Array Copying & Equality** | Part 07: Why copying is used in scoreboard.<br>Part 07: Array comparison `(arr3 == arr4)`. | C6: `status = (arr3 == arr4); arr2 = arr1;` (L106--116) | Whole-array assignment performs a deep value copy of elements. `==` performs logical equality; `===` performs case equality (handles X/Z). | "Assigning one fixed unpacked array to another creates independent copies of all elements. Both arrays must match type and size." |
| **Dynamic Array Resizing** | Part 07: Why `new` is needed to add elements. | C7: `arr = new[5]; arr = new[30](arr); arr.delete();` (L125--136) | `new[N]` is the dynamic array new-constructor. `new[N](old)` preserves existing elements and pads new elements with type defaults. | "Dynamic array resizing with preservation copies the prefix that fits. Assigning dynamic arrays to fixed arrays requires identical run-time size." |
| **Queue Methods & Mechanics** | Part 08: Queue operations and declaration placement. | C8: `push_front`, `push_back`, `insert(2)`, `pop_front`, `pop_back`, `delete(1)` (L145--162) | Queues (`int q[$]`) self-resize efficiently. `insert(index, item)` requires two arguments. `pop_*` returns and removes. | "Queues provide O(1) front/back insertions without memory reallocation, making them ideal for transaction FIFOs and scoreboard pipes." |
| **Tasks vs Functions** | Part 10: Why function cannot contain delay.<br>Part 10: Can function have output ports? | C9: Task timing, function return, "Function not supports output ports" (L167--169) | Functions cannot consume simulation time. Non-void functions return values. Procedural functions CAN have `output`, `inout`, and `ref` formals. | "Choose by timing: if an operation must wait on time or clock edges, use a task. If it completes in zero time and returns a value, use a function." |
| **Pass-by-Value vs Ref** | Part 11: Will value update reflect outside?<br>Part 12: Copying array to stack. | C9: "pass by value explain me as well an in how to speak it" (L255)<br>"pass by reference explain me" (L275) | `input` copies values (local callee copy). `ref` creates direct variable alias. Large arrays passed by `ref` avoid copy overhead. | *See dedicated interview scripts in Section 8.* Value protects caller data; reference creates an immediate alias and requires `automatic`. |
| **Automatic Lifetime** | Part 11: Why use `automatic` keyword. | C9: "the use of automatic and why i use it" (L277)<br>`ref bit [1:0] a` (L280) | Subroutines in modules/interfaces default to static lifetime. `ref` arguments strictly require `automatic` lifetime (IEEE 13.5.2). | "`automatic` allocates fresh local variables on each invocation stack, enabling recursion, concurrent thread safety, and legal `ref` aliasing." |
| **Classes & Handles** | Part 09: Can handle access before new?<br>Part 09: Dynamic objects & null deallocation. | C9: `first f1; f1 = new(); f1 = null;` (L175--185) | Class variable is a handle (pointer), default `null`. `new()` allocates heap memory. `null` dereference crashes. SV uses garbage collection. | "In SystemVerilog, a class variable is merely a reference. Memory is dynamically allocated on the heap, and unreachable objects are garbage-collected." |
| **Constructors & `this`** | Part 13: Why constructor has no return type.<br>Part 14: Scope, getters/setters. | C9: `function new(input int data = 0...); this.data = data;` (L325--330) | `function new()` has no return type (returns handle implicitly). `this` resolves property shadowing. Unqualified members are public. | "The constructor initializes instance properties. Use `this` to distinguish instance fields from identically named constructor arguments." |
| **Encapsulation & Scope** | Part 14: What does `local` do to member? | C9: `local int data = 344; setter, getter` (L347--365) | `local` restricts access to declaring class. `protected` allows derived-class access. Getters must be functions to return values in expressions. | "Encapsulation enforces data hiding. Private state is accessed via getters/setters, preserving data integrity in verification components." |
| **Object Copying Types** | Part 15: Built-in shallow copy.<br>Part 16: Custom copy method.<br>Part 17: Deep copy with nested objects.<br>Part 18: Shallow copy with nested handle. | C9: `f2 = f1;` (L395)<br>`f2 = new f1;` (L420)<br>`copy2.f1 = f1.copy;` (L460) | `b = a` copies handle. `b = new a` shallow-copies outer scalars, shares nested objects. Custom `copy()` recursively clones nested instances. | "Shallow copy creates a new outer object but shares nested child objects. Deep copy recursively duplicates all nested objects for total independence." |
| **Polymorphism & Virtual Methods** | Part 20: Will child display execute?<br>Part 20: Same name, different behavior. | C9: `virtual function void display();`<br>`f = s; f.display(); // parent methond will be executed` (L569) | **CRITICAL CORRECTION:** When `display` is `virtual`, `Child.display` executes through `f`! Dynamic dispatch uses runtime object type. | "Declaring a method `virtual` enables dynamic polymorphism. The simulator inspects the actual object type on the heap, not the declared handle type." |
| **Constructor Chaining (`super`)** | Part 21: Which keyword calls parent constructor?<br>Part 21: Constructor output argument. | C9: `class second extends first; super.new(data);` (L580--595) | `super.new(...)` invokes the parent constructor and MUST be the first executable statement in the derived constructor. | "Derived classes inherit base properties. `super.new` guarantees that the base-class portion is fully constructed before derived initialization." |


## Part I: Data Types, Representation & Simulation Foundations

### Section 1: Scalar Data Types, Signedness, and Value Systems

In SystemVerilog, a **data type** determines the set of legal values and the legal operations that can be performed upon an instance of that type. A **data object** is a concrete named entity that possesses a specific type: variables, nets, or constants.

A **variable** stores its last procedurally assigned value; it retains this value persistently across simulation time until another active assignment overwrites it. A **net** (such as `wire`) does not store state; rather, it models physical connectivity and computes its instantaneous value from the resolution of all continuous drivers connected to it.

```systemverilog
// Variables: retain procedurally assigned values
logic [7:0] state_reg;  // 4-state variable
bit   [7:0] count_val;  // 2-state variable

// Net: evaluates continuous driver resolution
wire  [7:0] bus_data;   // 4-state net
```

#### Integral Data Types: States, Bit Widths, and Default Values

The SystemVerilog integral type family is partitioned along two fundamental dimensions: **2-state versus 4-state** simulation models, and **signed versus unsigned** arithmetic interpretation.

| Type Keyword | Simulation States | Bit Width | Default Signedness | Default Uninitialized Value | Primary Use Case in Verification |
|---|:---:|:---:|:---:|:---:|---|
| `bit` | 2-state (0, 1) | 1 (or declared vector `[m:n]`) | **Unsigned** | `0` (or `'0`) | High-performance testbench stimulus and cycle-accurate modeling |
| `logic` / `reg` | 4-state (0, 1, X, Z) | 1 (or declared vector `[m:n]`) | **Unsigned** | `X` (or `'x`) | RTL modeling, DUT interface ports, and X-propagation checking |
| `byte` | 2-state (0, 1) | 8 bits | **Signed** | `8'd0` | Byte-oriented protocol packets (Ethernet, PCIe, UART, SPI) |
| `shortint` | 2-state (0, 1) | 16 bits | **Signed** | `16'd0` | Half-word transfers, 16-bit registers |
| `int` | 2-state (0, 1) | 32 bits | **Signed** | `32'd0` | Loop indices, transaction identifiers, integer arithmetic |
| `longint` | 2-state (0, 1) | 64 bits | **Signed** | `64'd0` | 64-bit addresses, high-capacity packet byte counters |
| `integer` | 4-state (0, 1, X, Z) | 32 bits | **Signed** | `32'shxxxx_xxxx` | Legacy Verilog loop variable modeling |
| `time` | 4-state (0, 1, X, Z) | 64 bits | **Unsigned** | `64'hxxxx_xxxx_xxxx_xxxx` | Simulation time storage (scaled integer) |
| `real` / `realtime` | Double-precision float | 64-bit IEEE 754 | N/A | `0.0` | Analog modeling, jitter measurement, floating-point timestamping |

#### Critical Language Traps and Repairs from Practice C1 & C2

1. **`bit` Signedness Trap (Practice C1):**  
   In practice C1 line 4, the note states: `// bit is a 2 state variable type , signed`.  
   **Correction:** `bit` is **unsigned by default**. A single `bit a;` can hold only `0` or `1`. To make a bit vector signed, the keyword `signed` must be explicitly supplied: `bit signed [7:0] s_bit;`.
2. **Uninitialized 4-State Defaults (Practice C4):**  
   In practice C4 line 56, the note states: `// 4 state -> initialized to unknown (Z)`.  
   **Correction:** Uninitialized 4-state variables (`logic`, `reg`, `integer`) initialize strictly to **`X` (unknown)**, NEVER `Z` (high impedance)! High impedance `Z` models an undriven physical net; it only appears if explicitly assigned (`bus = 1'bz;`) or when a tri-state driver is turned off.
3. **Signedness vs Bit Width: Decimal Interpretation (Practice C2):**  
   Practice C2 demonstrates `byte var_val = -126;` and `bit [7:0] var2 = 130;`. Both variables store the identical 8-bit binary pattern: `8'b1000_0010` (`8'h82`).  
   - For `byte`, the MSB (bit 7) is interpreted as a two's-complement sign bit with weight `-128`. Thus: $-128 + 2 = -126$.  
   - For `bit [7:0]`, the MSB has weight `+128`. Thus: $+128 + 2 = 130$.  
   - When assigning a value wider than 8 bits (e.g. `300 = 9'b1_0010_1100`), the excess most-significant bits are truncated, preserving `8'h2c` (`decimal 44`).
4. **Reserved Identifier Trap: `var` (Practice C2):**  
   In practice C2, the identifier `var` is used as a variable name: `byte var = -126;`.  
   **Correction:** `var` is a reserved SystemVerilog declaration keyword (e.g. `var logic [7:0] bus;`). It cannot be used as an identifier. Standard tools reject this with a syntax error.

---

### Section 2: Simulation Time, Timescale, Scheduling, and Clock Generation

#### The `` `timescale `` Directive: Unit vs Precision

Simulation time is governed by the compiler directive `` `timescale <time_unit> / <time_precision> ``:
- **`time_unit`:** Determines the physical time represented by an unsuffixed delay. For example, under `` `timescale 1ns/1ps ``, `#10` represents 10 nanoseconds.
- **`time_precision`:** Determines the scheduling quantum and rounding boundary within the simulation engine. All event times are rounded to the nearest multiple of the precision before scheduling. Precision is not merely a display formatting rule; it dictates physical simulation granularity.

#### Time Query Functions: `$time`, `$realtime`, and `$timeformat`

```systemverilog
module time_sampling_demo;
  timeunit 1ns;
  timeprecision 1ps;

  time     t_int;
  realtime t_real;

  initial begin
    $timeformat(-9, 3, " ns", 10);
    #12.234;
    t_int  = $time;      // returns 64-bit rounded integer: 12
    t_real = $realtime;  // returns real-valued timestamp: 12.234

    $display("Integer time:  %0d (formatted: %0t)", t_int,  t_int);
    $display("Realtime time: %0f (formatted: %0t)", t_real, t_real);
  end
endmodule
```

**Key Distinction:** Variables declared as `time` or `realtime` are static storage objects; they do **not** automatically track simulation time. They update only upon explicit assignment (`t_real = $realtime;`).

#### Testbench Clock Generation and Period Verification (Parts 02 & 03)

In testbench verification, clock generation processes must be derived from precise period equations:

$$	ext{Frequency (MHz)} = rac{1000}{	ext{Period (ns)}}$$

```systemverilog
// 100 MHz clock (10 ns period, 50% duty cycle)
always #5 clk_100 = ~clk_100;

// Correct 25 MHz clock (40 ns period, 20 ns high / 20 ns low)
always begin
  #20 clk_25 = 1'b1;
  #20 clk_25 = 1'b0;
end
```

**Bug Audit from Part 02:**  
In GitHub Part 02, the signal named `clk25Mhz` was defined with:
```systemverilog
always begin
  #20 clk25Mhz = 1'b1;
  #10 clk25Mhz = 1'b0;
end
```
**Analysis:** The total period is $20\,	ext{ns} + 10\,	ext{ns} = 30\,	ext{ns}$. The resulting frequency is $1000 / 30 = 33.33\,	ext{MHz}$, NOT 25 MHz! To obtain a true 25 MHz clock, both high and low phases must be 20 ns ($T = 40\,	ext{ns}$).

**Phase Shift vs Time-Zero Startup Offset (Part 03):**  
An initial delay `#10` prior to starting a clock loop introduces a startup offset from simulation time zero. A true phase shift describes the steady-state like-edge delay relative to a reference clock grid.

---

### Section 3: Arrays: Packed, Unpacked, and Memory Layouts

```text
Packed Array:    logic [3:0][7:0] packed_reg;  (One contiguous 32-bit register word)
                [ Byte 3 ][ Byte 2 ][ Byte 1 ][ Byte 0 ]

Unpacked Array:  logic [7:0] unpacked_mem [4]; (Four distinct 8-bit memory locations)
                [ Element 0: 8 bits ]
                [ Element 1: 8 bits ]
                [ Element 2: 8 bits ]
                [ Element 3: 8 bits ]
```

- **Packed Array:** Dimension is placed **before** the variable name (`bit [7:0] bus;`). It is guaranteed to be stored as a single contiguous vector of bits in simulator memory. It supports vector operations, arithmetic, and bit-slicing.
- **Unpacked Array:** Dimension is placed **after** the variable name (`bit bus [8];` or `int arr [0:9];`). It represents an indexed collection of independent elements.
- **Dynamic Array:** Unpacked array declared with empty brackets (`int dyn[];`). At declaration, size is 0 and no heap memory is allocated. Memory must be allocated dynamically using the `new[N]` constructor.

#### Array Initialization Constructs (Practice C3, C4 & Part 05)

SystemVerilog provides two distinct aggregate initialization constructs:
1. **Unpacked Array Concatenation (`{...}`):**  
   Legal when assigned to an unpacked array target. For example, `bit arr[] = {1, 0, 1, 1};` assigns four elements directly without requiring an apostrophe.
2. **Assignment Patterns (`'{...}`):**  
   The primary, robust SystemVerilog method for structured data initialization:
   ```systemverilog
   int a[5] = '{1, 3, 4, 2, 2};      // Positional assignment
   int b[5] = '{5{0}};               // Pattern replication (5 copies of 0)
   int c[5] = '{default: 4};         // Default value for all unassigned elements
   int d[9] = '{1, 2, default: 0};   // Positional prefix with default tail
   ```

#### Array Size Querying Functions

- **`$size(arr [, dim])`:** Returns the number of elements in the specified dimension of fixed or dynamic arrays.
- **`$bits(expression)`:** Returns the total number of bits required to represent the bit-stream of the object.
- **`arr.size()`:** Built-in method returning the current element count of dynamic arrays and queues.
- **Rejection of `$sizeof()`:** In practice C3 line 46, `$sizeof(arr)` is written. `$sizeof` is a C/C++ keyword; it does not exist in SystemVerilog. Attempting to use `$sizeof` causes a syntax error.

---

### Section 4: Array Iteration and Loop Mechanics

#### Loop Variants in Verification

| Loop Construct | Syntax | Execution Semantics | Verification Best Practice |
|---|---|---|---|
| `for` | `for(int i=0; i<N; i++)` | Traditional 3-clause loop; local index declaration | General indexed iteration |
| `foreach` | `foreach(arr[idx])` | Implicit index declaration; bounds inferred from array | Traversal of arrays with arbitrary or dynamic bounds |
| `repeat` | `repeat(N)` | Evaluates count on entry; repeats body N times | Stimulus generation loops; transaction counts |
| `while` | `while(condition)` | Evaluates condition prior to loop body | Polling loops waiting on state changes |
| `do...while` | `do ... while(cond);` | Executes body at least once before testing | Handshake acknowledgments |
| `forever` | `forever begin ... end` | Unconditional infinite execution | Clock generators, monitor background threads |

#### Mechanics of `foreach` Loops

The `foreach(arr[i])` loop is a specialized array traversal loop:
1. The loop variable `i` is **automatically declared** with local scope inside the loop.
2. The loop variable is **read-only**; attempting to modify `i` procedurally inside the loop is illegal.
3. The simulator inspects the declared bounds of the array. If an array is declared `int a[1:5];`, `foreach(a[j])` visits `1, 2, 3, 4, 5`. If declared `int a[5];` (shorthand for `[0:4]`), it visits `0, 1, 2, 3, 4`.

#### The Golden Law of Simulation Time in Loops

> **CRITICAL LAW:** Iteration alone consumes **ZERO simulation time**!  
> Executing a loop of 1,000 iterations takes 0 nanoseconds on the simulation timeline unless an explicit timing control (`#delay`, `@(posedge clk)`, `wait`) is reached inside the loop body.

In Practice C5, running three concurrent `initial` blocks writing to the same array without synchronization introduces an unscheduled race condition at simulation time zero.

---

### Section 5: Array Operations: Assignment, Comparison, and Dynamic Resizing

#### Whole-Array Assignment and Equality (Practice C6 & Part 07)

SystemVerilog supports whole-array assignments:
```systemverilog
int arr1[5];
int arr2[5];
// ... initialize arr1 ...
arr2 = arr1; // Copies all 5 element values independently
```
- **Assignment Semantics:** Array assignment is a **value copy**. Modifying `arr2[0]` after assignment does not alter `arr1[0]`.
- **Equality Comparison (`==` vs `===`):**  
  - `arr1 == arr2`: Compares element values logically. If any element contains `X` or `Z`, the result is `1'bx`.  
  - `arr1 === arr2`: Case equality. Treats `X` and `Z` as literal bit states and returns a deterministic Boolean `1'b1` or `1'b0`.

#### Dynamic Array Memory Management (Practice C7)

Dynamic arrays are allocated and resized via the dynamic-array new-constructor `new[N]`:

```systemverilog
int dyn[];
dyn = new[5];                   // Allocates 5 elements: '{0, 0, 0, 0, 0}
foreach(dyn[i]) dyn[i] = i*i;   // Initializes to: '{0, 1, 4, 9, 16}

// Resizing with data preservation:
dyn = new[8](dyn);              // Preserves original 5 elements, pads 3 zeros:
                                // '{0, 1, 4, 9, 16, 0, 0, 0}

// Deallocation:
dyn.delete();                   // Frees heap memory; size becomes 0
```

- If `new[N](old)` shrinks the array, only the first $N$ elements are preserved.
- When copying a dynamic array into a fixed-size array (`fixed_arr = dyn;`), the dynamic array's current size must **exactly match** the fixed array's dimension, otherwise a fatal runtime error occurs.

---

### Section 6: Queues: Syntax, Operations, and Performance

A **queue** is an unbounded or bounded ordered collection with index range `0` to `$`. Declared with `[$]`:
```systemverilog
int q[$];               // Unbounded queue
int bounded_q[$:127];   // Bounded queue of maximum 128 elements
```

#### Why Queues Excel in Verification Testbenches

Unlike dynamic arrays, which require full re-allocation and memory copying when resized, queues are implemented using contiguous segmented memory blocks. Queues provide $O(1)$ constant-time insertion and deletion at both front and back boundaries. This makes queues ideal for FIFO modeling, driver-to-monitor pipelines, and transaction scoreboards.

#### Queue Built-in Methods

| Method | Syntax | Functional Description | Return Value |
|---|---|---|:---:|
| `size()` | `int n = q.size();` | Returns current number of elements | Element count |
| `push_front()` | `q.push_front(val);` | Inserts `val` at index 0 (shifts all elements right) | void |
| `push_back()` | `q.push_back(val);` | Appends `val` at index `$` | void |
| `pop_front()` | `val = q.pop_front();` | Removes and returns the element at index 0 | Removed element |
| `pop_back()` | `val = q.pop_back();` | Removes and returns the element at index `$` | Removed element |
| `insert()` | `q.insert(idx, val);` | Inserts `val` immediately before index `idx` | void |
| `delete()` | `q.delete(idx);` | Removes element at index `idx` without returning | void |
| `delete()` | `q.delete();` | Clears all elements from the queue (size becomes 0) | void |

#### Execution Trace of Practice C8 Operations

```systemverilog
int q[$];
int j, k;

q = {1, 3, 4};        // Initial state:               '{1, 3, 4}
q.push_front(7);      // Insert 7 at index 0:         '{7, 1, 3, 4}
q.push_back(9);       // Append 9 at end:             '{7, 1, 3, 4, 9}
q.insert(2, 8);       // Insert 8 at index 2:         '{7, 1, 8, 3, 4, 9}
j = q.pop_front();    // Pops 7; queue becomes:       '{1, 8, 3, 4, 9}
k = q.pop_back();     // Pops 9; queue becomes:       '{1, 8, 3, 4}
q.delete(1);          // Deletes element at idx 1 (8):'{1, 3, 4}
```
*(Note: Practice C8 wrote `arr.insert(2)` missing the second argument. `insert()` requires both index and value).*


## Part II: Subroutines & Argument Passing Semantics

### Section 7: Tasks vs Functions

Subroutines package procedural behavior. The choice between a task and a function is governed strictly by **simulation time consumption**:

| Language Characteristic | Function | Task |
|---|---|---|
| **Consumes Simulation Time?** | **STRICTLY NO.** Cannot contain `#`, `@`, `wait`, or blocking `fork`. | **YES.** May contain blocking delays, clock-edge waits, and events. |
| **Return Value Mechanism** | Non-void functions return a value via expression or `return val;`. | Does not return an expression value; invoked strictly as a statement. |
| **Can Call a Task?** | **NO** (unless spawned inside a nonblocking `fork...join_none`). | **YES.** Can call other tasks and functions freely. |
| **Can Have `output` / `ref` Formals?** | **YES.** Procedural functions can declare `output`, `inout`, and `ref` arguments. | **YES.** Supports `input`, `output`, `inout`, and `ref` arguments. |

#### Refuting the Common Myth: "Functions Cannot Have Output Ports"

In Practice C9 lines 168--169, the comment asserts: `// function , not supports output ports`.  
**Correction:** According to IEEE Std 1800-2017 Clause 13.4, **procedural functions in SystemVerilog fully support `output`, `inout`, and `ref` arguments!**  
Functions with output arguments cannot be called inside non-procedural contexts (such as continuous assignments or event expressions), but inside procedural blocks (`initial`, `always`, tasks), a function with output arguments is 100% legal:

```systemverilog
function void compute_stats(input int data, output int square, output int cube);
  square = data * data;
  cube   = data * data * data;
endfunction
```

---

### Section 8: Argument Passing Modes & "How to Speak It" Interview Scripts

SystemVerilog provides five argument passing qualifiers:

| Mode Keyword | Passing Mechanism | Behavior on Entry | Modifications Inside Subroutine | Behavior on Exit |
|---|---|---|---|---|
| `input` | Pass-by-value | Local copy created | Modifies only local copy | No copy-back; caller variable unchanged |
| `output` | Pass-by-value result | Local copy initialized to type default | Subroutine writes to local formal | Final local value copied out to caller variable |
| `inout` | Pass-by-value bidirectional | Value copied in on entry | Subroutine reads and writes local formal | Final local value copied out upon return |
| `ref` | Pass-by-reference | Direct memory alias | Immediate modification of caller's variable | No copy-back needed (real-time aliasing) |
| `const ref` | Read-only reference | Direct memory alias | Modification is illegal (compiler error) | No copy-back needed; caller data protected |

#### Verbatim Interview Script: How to Explain Pass-by-Value

> **"How to Speak Pass-by-Value" (Verbatim Interview Guide):**  
> *"In SystemVerilog, pass-by-value is the default mechanism for input arguments. When an argument is passed by value, the simulator allocates a private storage location for the formal argument on the subroutine's execution stack and copies the actual argument's value into it upon entry.*  
> *Any subsequent modifications made to this formal argument inside the subroutine operate purely on this local copy. The caller's original variable remains completely isolated and unchanged throughout the call.*  
> *Pass-by-value guarantees total data protection for the caller, but it incurs a performance and memory penalty when large data structures—such as unpacked arrays—are repeatedly copied across the stack."*

#### Verbatim Interview Script: How to Explain Pass-by-Reference

> **"How to Speak Pass-by-Reference" (Verbatim Interview Guide):**  
> *"Pass-by-reference, specified using the `ref` keyword, passes a direct reference—or memory alias—to the caller's actual variable rather than copying its contents.*  
> *Because no copy is created, any assignment made to a `ref` formal argument is immediately reflected in the caller's variable in real time, without waiting for the subroutine to finish and return.*  
> *In verification environments, pass-by-reference is essential for two primary reasons: first, to achieve high-performance stimulus generation by avoiding expensive stack copying of large arrays and packets; and second, to allow concurrent tasks to inspect or modify shared state dynamically.*  
> *Crucially, SystemVerilog requires that subroutines with `ref` arguments in static scopes be declared with the `automatic` lifetime keyword to guarantee thread-safe call frames."*

#### The `automatic` Keyword and Storage Lifetimes

- **Static Lifetime:** Variables allocated once at time zero and shared across all invocations. Module- and interface-level subroutines default to static.
- **Automatic Lifetime:** Variables allocated dynamically on the call stack for each invocation. Class methods default to automatic.
- **Strict Rule (IEEE 13.5.2):** A subroutine that declares a `ref` argument **MUST be declared `automatic`** if defined inside a module or interface!

#### Passing Class Handles: Value of Handle vs Mutating the Object

A frequent interview trap involves passing a class handle as an `input` argument:
```systemverilog
function automatic void modify_pkt(input Packet p);
  p.id = 99;      // MUTATES the caller's shared object on the heap!
  p    = null;    // NULLS ONLY the local copy of the handle!
endfunction
```
**Explanation:** Passing a class handle as `input` copies the **pointer (handle)** by value. Both the caller's handle and the callee's local handle point to the exact same object in heap memory. Modifying an internal property (`p.id = 99;`) modifies the shared object. However, reassigning the handle itself (`p = null;`) merely modifies the callee's local stack copy; upon return, the caller's handle remains non-null and points to the mutated object!


## Part III: Object-Oriented Programming (OOP) in SystemVerilog

### Section 9: Classes, Handles, Objects, and Lifecycle

SystemVerilog OOP separates **type**, **handle**, and **heap object**:

```text
Class Declaration (Blueprint): class Transaction; int addr; endclass

Handle Declaration:            Transaction tr;       tr ----> [ null ]
(Stack Pointer)

Object Construction:           tr = new();           tr ----> [ Heap Object: addr = 0 ]
```

1. **Class Type:** A user-defined data type defining properties (data) and methods (tasks/functions).
2. **Handle Variable:** A typed pointer variable that holds either `null` or a reference to an active object on the heap. Default value is strictly `null`.
3. **Object:** Dynamic memory allocated on the simulation heap via `new()`.
4. **Dereferencing `null`:** Attempting to access members of an unconstructed handle (`tr.addr = 5;` when `tr == null`) causes an immediate fatal simulation runtime crash.
5. **Handle Assignment:** `tr2 = tr1;` copies the **handle**, not the object! Both handles now reference the exact same memory block.
6. **Automatic Garbage Collection:** SystemVerilog features automated heap garbage collection. Writing `tr = null;` merely removes that reference. The object remains alive as long as at least one handle references it. When zero handles reference the object, the simulator reclaims the heap memory.

---

### Section 10: Constructors, `this`, Encapsulation, and Composition

#### The Class Constructor (`new`)

The constructor is declared with `function new(...)`.
- It has **no return type** (not even `void`).
- It allocates memory, initializes properties to default values, and returns the handle implicitly.
- It supports default argument values, enabling flexible invocation with positional or named arguments:
  ```systemverilog
  class Packet;
    int length;
    int payload;
    function new(int length = 64, int payload = 0);
      this.length  = length;   // 'this' disambiguates property from argument
      this.payload = payload;
    endfunction
  endclass

  Packet p1 = new();                   // Uses defaults: length=64, payload=0
  Packet p2 = new(128, 5);             // Positional arguments
  Packet p3 = new(.payload(9), .length(256)); // Named arguments
  ```

#### Encapsulation and Access Modifiers

- **`public` (default):** Properties and methods can be accessed from any scope.
- **`local`:** Accessible strictly from within the declaring class. Subclasses and external scopes cannot access local members.
- **`protected`:** Accessible from within the declaring class AND any derived subclasses (`extends`). External scopes cannot access protected members.

#### Composition (Has-A) vs Inheritance (Is-A)

- **Composition:** An outer class contains a handle to an inner class (`Envelope` has a `Payload`). The outer constructor is responsible for constructing the nested object (`payload = new();`).
- **Language Law:** A class **cannot contain an `initial` block**! Initialization belongs inside the `new()` constructor.

---

### Section 11: Object Copying Mechanisms: Handle Copy vs Shallow Copy vs Deep Copy

```text
1. Handle Copy:    h1 --+
                        +----> [ Object Instance A ]
                   h2 --+

2. Shallow Copy:   h1 ------> [ Outer Object A ] ----+
                                                     +----> [ Nested Object N ]
                   h2 ------> [ Outer Object B ] ----+

3. Deep Copy:      h1 ------> [ Outer Object A ] ---------> [ Nested Object N1 ]
                   h2 ------> [ Outer Object B ] ---------> [ Nested Object N2 ]
```

#### Comparison of the Three Copying Mechanisms

| Feature | Handle Copy (`h2 = h1;`) | Built-in Shallow Copy (`h2 = new h1;`) | Custom Deep Copy (`h2 = h1.copy();`) |
|---|:---:|:---:|:---:|
| **New Outer Object Created?** | No (0 new objects) | **Yes** (1 new outer object) | **Yes** (1 new outer object) |
| **Scalar Properties** | Shared through single instance | Copied independently by value | Copied independently by value |
| **Nested Class Handles** | Shared | **Copied by reference (SHARED!)** | **Recursively cloned (INDEPENDENT!)** |
| **Calls Class Constructor?** | No | **STRICTLY NO!** | Yes (inside custom `copy()` method) |
| **Calls Field Initializers?**| No | **STRICTLY NO!** | No (overwritten by copy assignments) |

#### Implementation of Recursive Deep Copy

```systemverilog
class Inner;
  int data = 10;
  function Inner copy();
    copy = new();
    copy.data = this.data;
  endfunction
endclass

class Outer;
  int id = 1;
  Inner nested;

  function new();
    nested = new();
  endfunction

  function Outer copy();
    copy = new();
    copy.id = this.id;
    if (this.nested != null)
      copy.nested = this.nested.copy(); // Recursive clone of nested child
    else
      copy.nested = null;
  endfunction
endclass
```

#### State Mutation Verification Table

Starting from `s1.id = 1; s1.nested.data = 10;`:

| Operation Executed | Mutation Applied | State of `s1` (`id` / `data`) | State of `s2` (`id` / `data`) | Verification Conclusion |
|---|---|:---:|:---:|---|
| **Handle Copy** (`s2 = s1;`) | `s2.id = 2; s2.nested.data = 99;` | `2` / `99` | `2` / `99` | Identical object; both handles see all changes |
| **Shallow Copy** (`s2 = new s1;`) | `s2.id = 2; s2.nested.data = 99;` | `1` / `99` | `2` / `99` | Outer scalars independent; **nested data corrupted in s1!** |
| **Deep Copy** (`s2 = s1.copy();`) | `s2.id = 2; s2.nested.data = 99;` | `1` / `10` | `2` / `99` | **Total independence! `s1` remains pristine** |

---

### Section 12: Inheritance, Polymorphism, Virtual Methods, and Constructor Chaining

#### Inheritance Syntax and Handle Upcasting

Inheritance models an **Is-A** relationship (`class Child extends Base;`). Derived classes inherit all properties and methods of the base class.
- **Upcasting (Derived to Base):** Assigning a child handle to a base handle (`Base b = child_inst;`) is always legal and implicit. In SystemVerilog, upcasting never slices the object; the underlying heap object remains a complete `Child`.
- **Downcasting (Base to Derived):** Assigning a base handle to a child handle (`Child c = b;`) fails compilation. Safe runtime downcasting requires `$cast(c, b)`:
  ```systemverilog
  if (!$cast(c, b))
    $fatal(1, "Downcast failed: underlying object is not of type Child!");
  ```

#### Polymorphism and Virtual Method Dispatch

```systemverilog
class Base;
  virtual function void display();
    $display("Executing BASE display");
  endfunction
endclass

class Child extends Base;
  function void display();
    $display("Executing CHILD display");
  endfunction
endclass

module tb;
  Base  b;
  Child c;
  initial begin
    c = new();
    b = c;        // Upcast child handle into base handle
    b.display();  // Which display() executes?
  end
endmodule
```

#### Resolution of the Practice Code Misconception (L569 & L676)

> **CRITICAL CODE AUDIT & CORRECTION:**  
> In the user's practice code, the following comment was written:  
> ```systemverilog
> f = s;   // what this do besides copying the handler of class s to f 
> f.display(); // parent methond will be executed 
> ```
> **VERIFICATION VERDICT: THE COMMENT IS INCORRECT!**  
> Because `display()` was declared with the `virtual` keyword in the base class, SystemVerilog uses **dynamic method dispatch**.  
> The simulator looks past the static type of the handle (`f` is declared `Base`) and checks the **dynamic type of the object in heap memory** (which is `Child`).  
> Therefore, **`Child.display()` executes, NOT the parent method!**  
> If the base method lacked `virtual`, static binding would execute `Base.display()`. Marking the method `virtual` guarantees that the child override executes.

#### Constructor Chaining and the `super` Keyword (Part 21)

When a derived class inherits from a base class with a parameterized constructor, the derived class constructor must explicitly call `super.new(...)`:
```systemverilog
class Base;
  int base_id;
  function new(int id);
    this.base_id = id;
  endfunction
endclass

class Child extends Base;
  int child_val;
  function new(int id, int val);
    super.new(id);          // MUST be the first executable statement!
    this.child_val = val;
  endfunction
endclass
```

- **Strict Placement Rule:** `super.new(...)` must be the **first executable statement** inside the derived constructor.
- **Implicit Behavior:** If `super.new(...)` is omitted, the compiler automatically inserts an implicit zero-argument call `super.new()`. If the base class constructor requires arguments without defaults, compilation fails immediately.


## Part IV: Practice Code Bug Audit and Code Repairs

This section audits every bug, typo, and defect identified in the user's raw practice source (`C1` through `C9` and OOP blocks) and provides standard-compliant SystemVerilog code:

| Practice Section | Raw Practice Defect / Trap | Root Cause Analysis | Corrected, Runnable SystemVerilog Implementation |
|---|---|---|---|
| **C1 (Line 4)** | `bit a = 0; // bit is a 2 state variable type, signed` | `bit` is unsigned by default. | `bit a = 0; // 2-state, unsigned (defaults to 0)` |
| **C2 (Line 27)** | `byte var = -126;` | `var` is a reserved declaration keyword in SystemVerilog. | `byte var_val = -126;` |
| **C2 (Line 35)** | `$display(..., fix_time, fixed_time);` | Typo: variable declared `fix_time`, referenced as `fixed_time`. | Declare `time fixed_time;` and assign `fixed_time = $time;`. |
| **C3 (Line 46)** | `$sizeof(arr)` | `$sizeof` is a C keyword; does not exist in SV. | `$size(arr)` or `arr.size()` |
| **C4 (Line 56)** | `// 4 state -> initialized to unknown (Z)` | Misconception: 4-state integral types default to `X`, not `Z`. | Uninitialized `logic` initializes to `1'bx`. |
| **C5 (Line 93)** | `repeat(10) begin arr[i] = i; i++; end` | Variable `i` undeclared in the process scope; missing argument in `$display("%0p")`. | Declare `int i = 0;` locally and write `$display("arr=%0p", arr);`. |
| **C7 (Line 125)** | `// arr = new[5]; // its not a constructor` | Misconception: IEEE Std 1800-2017 calls `new[N]` the dynamic array new-constructor. | `arr = new[5]; // Dynamic array new-constructor` |
| **C8 (Line 153)** | `arr.insert(2);` | Syntax error: `insert()` requires two arguments: index and value. | `arr.insert(2, 8); // inserts value 8 at index 2` |
| **C9 (Line 168)** | `// function, not supports output ports` | Misconception: procedural functions support `output`, `inout`, and `ref` formals. | Procedural functions can declare `output` arguments. |
| **C9 (Line 277)** | Task using `ref` in module without `automatic` | IEEE 13.5.2 requires `automatic` lifetime for `ref` in static scopes. | `task automatic swap(ref bit [1:0] a, b);` |
| **C9 (Line 569)** | `f = s; f.display(); // parent methond will be executed` | Misconception: `display` is `virtual`, so dynamic dispatch executes `Child.display()`. | Override in `second` executes due to `virtual` dispatch. |

---

## Part V: Active Recall Self-Test & Detailed Solutions

Test your recall aloud before reading the solution keys:

1. **Question 1 (Data Types):** An 8-bit variable holds binary `8'b1111_1100`. What is printed by `$display("%0d", var)` if declared as `byte`, and if declared as `bit [7:0]`?  
   **Answer:** `byte` prints **`-4`** (signed two's-complement: $-128 + 124 = -4$). `bit [7:0]` prints **`252`** (unsigned magnitude: $240 + 12 = 252$).
2. **Question 2 (Initial Values):** What are the default values of an uninitialized `bit`, `logic`, `int`, `time`, and class handle?  
   **Answer:** `bit`: `0`. `logic`: `X`. `int`: `0`. `time`: `X`. Class handle: `null`.
3. **Question 3 (Time Precision):** Under `` `timescale 1ns/10ps ``, what does `#1.237` delay for? What do `$time` and `$realtime` return?  
   **Answer:** Precision is 10 ps (0.01 ns). `#1.237` is rounded to `1.24 ns`. `$time` returns scaled integer **`1`**; `$realtime` returns real **`1.240`**.
4. **Question 4 (Array Queries):** For `logic [7:0] mem [16];`, what do `$size(mem)` and `$bits(mem)` return?  
   **Answer:** `$size(mem)` returns **`16`** (number of unpacked elements). `$bits(mem)` returns **`128`** ($16 	imes 8$ total bits).
5. **Question 5 (Loops and Time):** Does a `for` loop of 10,000 iterations advance simulation time?  
   **Answer:** **No.** Repetition consumes zero simulation time. Time advances only upon encountering blocking timing controls (`#`, `@`, `wait`).
6. **Question 6 (Dynamic Arrays):** A dynamic array `dyn` holds `'{10, 20, 30}`. What does `dyn = new[5](dyn);` do? What does `dyn.delete();` leave?  
   **Answer:** `new[5](dyn)` preserves the 3 elements and pads 2 default zeros: `'{10, 20, 30, 0, 0}`. `dyn.delete()` frees memory and resets size to **`0`** (empty).
7. **Question 7 (Queue Methods):** Starting from `q = '{10, 30}`, apply `q.push_front(5)`, `q.push_back(40)`, `q.insert(2, 20)`, `q.pop_front()`. What remains in `q`?  
   **Answer:** Sequence: `'{5, 10, 30}` $ightarrow$ `'{5, 10, 30, 40}` $ightarrow$ `'{5, 10, 20, 30, 40}` $ightarrow$ pop 5 leaves **`'{10, 20, 30, 40}`**.
8. **Question 8 (Functions and Tasks):** Why can a function not call a task directly? Can a function have an `output` argument?  
   **Answer:** A function cannot consume simulation time; calling a task could suspend the process. Yes, procedural functions can have `output` arguments.
9. **Question 9 (Pass by Reference):** What error occurs if a module-level task declares `ref int a` without the `automatic` keyword?  
   **Answer:** Compiler error. IEEE 1800-2017 Clause 13.5.2 requires automatic lifetime for `ref` formals in static module scopes.
10. **Question 10 (Passing Handles):** Inside a task with `input Packet pkt`, code executes `pkt.len = 100; pkt = null;`. What happens to the caller's object and handle?  
    **Answer:** The caller's object property `len` is updated to **`100`**. The caller's handle **remains valid and non-null** (only the local formal was nulled).
11. **Question 11 (Constructor Syntax):** Why does `function new()` have no return type declared?  
    **Answer:** The constructor implicitly allocates and returns an object handle of its class type. Declaring any return type is a syntax error.
12. **Question 12 (Shallow Copy):** If class `Outer` has handle `Inner in_inst;`, what is shared after `o2 = new o1;`? Does `new o1` execute `Outer`'s constructor?  
    **Answer:** `o1` and `o2` share the exact same `in_inst` object on the heap. **No**, shallow copy does NOT run the constructor or field initializers.
13. **Question 13 (Deep Copy):** How does deep copy differ from shallow copy?  
    **Answer:** Deep copy recursively instantiates and copies every nested child object (`copy.in_inst = in_inst.copy()`), achieving complete memory independence.
14. **Question 14 (Virtual Methods):** `Base b; Child c = new(); b = c; b.display();`. If `display()` is virtual in `Base`, which method runs?  
    **Answer:** **`Child.display()`** executes via dynamic dispatch based on the runtime object type.
15. **Question 15 (Super Keyword):** Where must `super.new(...)` be placed in a derived class constructor? What happens if omitted?  
    **Answer:** It must be the **first executable statement**. If omitted, an implicit `super.new()` is called, which fails if the base constructor requires arguments.

---

## Part VI: Simulation Verification Report & Standards Appendix

### Simulator Verification Summary

The technical claims, code corrections, and runtime traces in this handbook were compiled, elaborated, and simulated using **AMD Vivado Simulator 2024.1 (64-bit, build 5076996)** with standard-compliance flags `xvlog -sv`, `xelab -s`, and `xsim -runall`.

```text
================================================================================
SIMULATION VERIFICATION RESULTS -- AMD Vivado Simulator 2024.1
Testbench: revision_checks.sv | Resolution: 1 ps | Finish Time: 1234 ps
================================================================================
TRACE types bit[7:0]=255 byte=-1 defaults(bit,logic)=0,x
TRACE time $time=1.000 ns $realtime=1.234 ns
TRACE arrays concat='{1'b1,1'b0,1'b1,1'b1} resized='{11,22,33,0,0} queue='{1,8,3,4}
TRACE arguments sum=12 input(actual,result)=10,15 swap=9,4 ctor_out=26
TRACE copies source=10/88 shallow=99/88 deep=123/456 ctor_calls=2
TRACE dispatch virtual=3 nonvirtual=20
================================================================================
STATUS: PASS -- 32 of 32 deterministic checks completed with zero errors.
================================================================================
```

### Primary Language Standards References (IEEE Std 1800-2017)

- **Clause 6 (Data Types):** §6.8 (2-state/4-state), §6.11 (Signedness & truncation), Table 6-7 & 6-8 (Defaults).
- **Clause 7 (Arrays & Queues):** §7.4 (Packed/Unpacked), §7.5 (Dynamic arrays & new[N]), §7.10 (Queues & methods).
- **Clause 8 (Classes & OOP):** §8.5 (Handles vs Objects), §8.7 (Constructors), §8.12 (Shallow copy), §8.20 (Polymorphism & virtual methods), §8.22 (Upcasting/Downcasting).
- **Clause 10 (Assignments):** §10.9 (Assignment patterns), §10.10 (Unpacked concatenation).
- **Clause 13 (Tasks & Functions):** §13.3 (Tasks), §13.4 (Functions & outputs), §13.5 (Argument passing & `ref`).
- **Clause 20 (Utility System Functions):** §20.3 (`$time`, `$realtime`), §20.4 (`$timeformat`), §20.7 (`$size`, `$bits`).

