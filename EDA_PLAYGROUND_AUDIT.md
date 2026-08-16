# EDA Playground and Source Audit

This audit records the evidence for the verbatim-source and cited-Q&A pass. The naming-pass reference is baseline commit `491f409a1a09f224e0fa2d2eca4970e9f1ead00c`; work continued on the existing branch `kapil/systemverilog-playground-backlog` without creating or switching branches.

## Identity, order, and one-to-one mapping

The queue is mapped in order 01 through 16. Each short ID is the existing EDA Playground link; no copy or fork was created. The visible titles and saved Name fields were read through the dedicated Edge browser-control binding. The repository H1, root index title, and saved EDA Name agree semantically (parts 01–06 retain their established `SV 0X - ...` names).

| Part | Short ID/link | Exact saved EDA Name | Visible browser-tab title | Code ID | Folder slug | Folder README H1 | Root index title | Source files | Settings |
|---:|---|---|---|---:|---|---|---|---|---|
| 01 | [Ucnp](https://edaplayground.com/x/Ucnp) | SV 01 - Simulation Basics | SV 01 - Simulation Basics - EDA Playground | 7356115 | `01-simulation-basics` | Part 01 — SV 01 - Simulation Basics | SV 01 - Simulation Basics | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 02 | [gi86](https://edaplayground.com/x/gi86) | SV 02 - Clock Generation | SV 02 - Clock Generation - EDA Playground | 7356140 | `02-clock-generation` | Part 02 — SV 02 - Clock Generation | SV 02 - Clock Generation | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 03 | [gi8n](https://edaplayground.com/x/gi8n) | SV 03 - Phase-Shifted Clocks | SV 03 - Phase-Shifted Clocks - EDA Playground | 7356180 | `03-phase-shifted-clocks` | Part 03 — SV 03 - Phase-Shifted Clocks | SV 03 - Phase-Shifted Clocks | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 04 | [giAN](https://edaplayground.com/x/giAN) | SV 04 - Data Types and Time | SV 04 - Data Types and Time - EDA Playground | 7356270 | `04-data-types-and-time` | Part 04 — SV 04 - Data Types and Time | SV 04 - Data Types and Time | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 05 | [8k9Q](https://edaplayground.com/x/8k9Q) | SV 05 - Fixed Arrays and For Loop | SV 05 - Fixed Arrays and For Loop - EDA Playground | 7356341 | `05-fixed-arrays-and-for-loop` | Part 05 — SV 05 - Fixed Arrays and For Loop | SV 05 - Fixed Arrays and For Loop | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 06 | [GK3p](https://edaplayground.com/x/GK3p) | SV 06 - Array Iteration | SV 06 - Array Iteration - EDA Playground | 7356382 | `06-array-iteration` | Part 06 — SV 06 - Array Iteration | SV 06 - Array Iteration | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 07 | [CafY](https://edaplayground.com/x/CafY) | Whole-Array Copying | Whole-Array Copying - EDA Playground | 7356412 | `07-array-copying` | Part 07 — Whole-Array Copying | Whole-Array Copying | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 08 | [bKTC](https://edaplayground.com/x/bKTC) | Queue Operations | Queue Operations - EDA Playground | 7356536 | `08-queue-operations` | Part 08 — Queue Operations | Queue Operations | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 09 | [qLDu](https://edaplayground.com/x/qLDu) | Class Object Basics | Class Object Basics - EDA Playground | 7356678 | `09-class-object-basics` | Part 09 — Class Object Basics | Class Object Basics | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 10 | [ecCx](https://edaplayground.com/x/ecCx) | Tasks and Functions | Tasks and Functions - EDA Playground | 7356696 | `10-tasks-and-functions` | Part 10 — Tasks and Functions | Tasks and Functions | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 11 | [Ua2v](https://edaplayground.com/x/Ua2v) | Pass by Reference | Pass by Reference - EDA Playground | 7357015 | `11-pass-by-reference` | Part 11 — Pass by Reference | Pass by Reference | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 12 | [ADYn](https://edaplayground.com/x/ADYn) | Array Reference Passing | Array Reference Passing - EDA Playground | 7357071 | `12-array-reference-passing` | Part 12 — Array Reference Passing | Array Reference Passing | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 13 | [Ud7M](https://edaplayground.com/x/Ud7M) | Constructor Arguments | Constructor Arguments - EDA Playground | 7357115 | `13-constructor-arguments` | Part 13 — Constructor Arguments | Constructor Arguments | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 14 | [EasK](https://edaplayground.com/x/EasK) | Class Composition and Scope | Class Composition and Scope - EDA Playground | 7357152 | `14-class-composition-and-scope` | Part 14 — Class Composition and Scope | Class Composition and Scope | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 15 | [sVdz](https://edaplayground.com/x/sVdz) | Class Shallow Copy | Class Shallow Copy - EDA Playground | 7357619 | `15-class-shallow-copy` | Part 15 — Class Shallow Copy | Class Shallow Copy | design.sv, testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |
| 16 | [X4c6](https://edaplayground.com/x/X4c6) | Class Custom Copy Method | Class Custom Copy Method - EDA Playground | 7357655 | `16-class-custom-copy-method` | Part 16 — Class Custom Copy Method | Class Custom Copy Method | design.sv, testbench.sv, editor_testbench.sv | Riviera Pro 2025.04; `-timescale 1ns/1ns`; `+access+r` |

Every mapped page had a nonblank, unique saved Name. Parts 07–16 were rechecked in Edge during the naming audit; the final rescan also included the agent-created same-link inspection tab and left all original tabs open. No page code or simulator setting was edited during this documentation pass.

## Normalized source fingerprints

SHA-256 values below are computed from the captured live pane after normalizing CRLF to LF. The common design pane is the literal `// Code your design here` source. A repository comparison must normalize the same way; a final newline difference is not treated as a source change.

| Part | Design SHA-256 | Testbench SHA-256 | README Q&A entries | Unique authoritative URLs used in Q&A |
|---:|---|---|---:|---:|
| 01 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `6b2c4b610dea4841d4560ac795858976c7ed3208f217e8e0a394efc2cad90434` | 2 | 2 |
| 02 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `db1f520df21efa383911b818845504e155e7a4fe83618bdfba3aa4386ed4d042` | 3 | 2 |
| 03 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `90bffe4f701269b7a8530a81f04b2f5be76aae1d9bf94a265349c4cf91098ef6` | 0 | 0 |
| 04 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `06ab68f7307231c22792892f918aa6fefcf0ee91868e79afb419b829d28e0ff0` | 3 | 2 |
| 05 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `5c32b4d2c481d6b10b6fe59b2a4720a0424908800b92cb27a41d1d6ce71da1c3` | 4 | 2 |
| 06 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `e650ea0a71aff866595dc1f34f1759d9db1f7f0082c82544c1a4dab34393673a` | 1 | 2 |
| 07 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `165c3ea6c682060bd0baa531feb2bc884b5336e629c4c5f898ad4691e266f2d7` | 4 | 1 |
| 08 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `89b81f57c11680cc769a2bd8e8a8f410e483c01248b6447b445df5ec2a456a8d` | 1 | 1 |
| 09 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `4b0e5fda69292c76bcc6a5a732c2743d2cd8693f06f04a3bebc92667f00c022b` | 6 | 2 |
| 10 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `aface8e08127cff0e8452c52666a7822fee1bf7ad15152b4851522abb0c1930b` | 5 | 1 |
| 11 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `caa1ca96d3dda901cea47642919c66b2c672a86b145bb06edbb4301d697c22a1` | 2 | 1 |
| 12 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `c17d97e8e1749b9bcdcbeffd099f9b29295808acf371aac873c6ba28340104b7` | 1 | 2 |
| 13 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `4a717365c4d2e60b9acfe4d7ab122404628c7dde35dde3bbbfe21e69f84d8f14` | 2 | 1 |
| 14 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `69d664edd1fe77a581e8e4919fbe5ded085862e74800925821c5c132e0196481` | 5 | 1 |
| 15 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `ad20eaf89338c897636500b6c8832c53176877302b3029e72371903ddfc590af` | 5 | 1 |
| 16 | `d2c99ccc005b1f9d188df2479be15a08b6fd8a9ad4e05568c2b02a9fc1a30553` | `7702edb27e40b1d73df848185fd5ac82ddf311ee52afd70df88e0704b79fcc60` | 5 | 1 |

The Q&A total is 49 entries: 2+3+0+3+4+1+4+1+6+5+2+1+2+5+5. Part 03 has zero natural-language questions, but its complete source and timing comments remain documented.

## Question coverage ledger

Each exact source comment/question below has one matching entry under `## Questions and Answers from the Code` in its part README. The line numbers refer to the captured `testbench.sv`; p08's question spans two adjacent comment lines and p09's constructor explanation spans two adjacent comment lines.

| Part | Source line(s) | Exact source wording or captured comment |
|---:|---|---|
| 01 | 10 | will start from time 0 (start of the simulation ) ; 16: variable will hold the value =0 till the end of the simulation |
| 02 | 7 | in tb we dont need a sensitivity list in the always block why ? ; 8: in the design we need to evaluate for change hence in sensitivity list ; 15: x by default so i have to initialize |
| 03 | — | No natural-language question/doubt found; timing comments retained in source |
| 04 | 26 | 4 state initial value will be x ; 58: cant use wire here ; 103: here, reg cant be allowed in the output of ha1 |
| 05 | 10 | compiler will make the size ==4 ; 17: if the array is not initialize or given size i cant put any element inside ; 22: to initialize with unique values , or repetitive value or default value ; 56: need a procedural block |
| 06 | 6 | why j is going from 0 to 9 cause im not specifying anything , is it because of foreach loop ? |
| 07 | 3 | compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here, ; 28: should return true ; 48: why its not having default value printed xxxx cause i deleted and its a 4 state logic ; 62: have to use new keyword when i want to add elements |
| 08 | 6–7 | SO I HAVE TO DEFINE DATA HERE, FOR USING IT LATEER ? ALSO TELL ME WHY CANT I DEFINTE LIKE THIS IN / THE INITIAL BLOCK , int data = q.pop_front() |
| 09 | 11–12 | f is a handler wont able to access the class ; class are dynamic object ? meaning ; Do not keep that object throughout life of the simulation ; constructor to the handler allocate the memory space to all the data members of the class and also assigns the default values ; Once i call the constructor / f now points to that, object ; Try to add a value |
| 10 | 9 | so no need to make the result initialized by 0 ; 12: i can rather pass ain, bin to the function ; 24: cannot add delay in function , ; 50: 32 bit unsigned value will be generated ; 80: passby value task add (reg int x, y ) |
| 11 | 21–22 | wont be reflected to the varaibles outside the task ; WHY PASS BY VALUE IN TERMS OF SCALAR HE IS SAYING |
| 12 | 3 | Copying an array to stack is not an optimum choice |
| 13 | 8 | constructor cannot add a void to a constructor ; 26: f1 will have address of the class now |
| 14 | 3 | scope is public be default ; 6: local int data = 34; ; 14: a return type needed for getter () ; 26: this or i can use initial begin block itself ?? ; 41: $display("The value of the data , fron getter task is %0d" , s.f1.getter()) ; WILL NOT WORK CAUSE TASK DOES NOT RETURN A VALUE |
| 15 | 3 | Copy the data somethimes ; 13: constructor copy from 1 object to another object ; 15: p1 =new(f1); // Copy all the data of the object handle f1 to f2 (shallow copy) ; 18: if i change in p1 object handle , it wont reflect on f1 ; 23: task creating copy , just to copy data members attributes |
| 16 | 7 | custom methods to copy ; 10: why am i not using this here, ; 19: to store copy of f1 to f2 ; 25: copy of the data members of f1 to f2 ; 39: automatically copies  why i havent used f1.copy() |

No question is answered by an unrelated part. The normalized headings in the READMEs are only for navigation; the blockquotes preserve the source wording.

## Capture and preservation method

1. Git baseline, branch, HEAD, status, and complete diff were inspected before source work. The baseline was clean at the naming-pass reference above.
2. The dedicated Edge binding was used to inspect each existing EDA Playground page. For editor panes whose backing textarea was not populated, CodeMirror lines were paged through with line numbers and merged; this avoided truncated DOM snippets. Both Design and Testbench pane text were captured, along with the saved Name, short link, visible title, simulator, compile options, and run options.
3. Stable normalized SHA-256 fingerprints were computed before repository restoration. Repository source was compared to the captured source; parts 01–03 and 06 already matched, while parts 04–05 and 07–16 had captured testbench differences from older normalized or corrected versions. The captured live text is now the repository `testbench.sv` source.
4. README code blocks were generated from the captured source values. Part 16 retains both existing repository filenames as the same captured pane; no alternate code was invented.
5. The Luna-only `self_checking_testbench.sv` files were removed because they were not user-authored EDA panes and conflicted with the verbatim-source requirement. No source logic was corrected. `.gitattributes` disables whitespace-error classification for captured panes and their README renderings so their trailing spaces remain intact.

## Research basis

Q&A claims about language semantics link directly to the IEEE/Accellera SystemVerilog material, principally the [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and the [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). EDA Playground settings and option claims link to its [settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [compile/run option documentation](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html). Simulator-specific run outcomes are not asserted in the Q&A unless directly observed; malformed or race-prone source is described as source behavior rather than silently repaired.

## Verification result to record at handoff

- Source-to-capture parity: PASS for all 16 Design panes, all 16 Testbench panes, and the additional p16 `editor_testbench.sv` capture after LF/final-newline normalization.
- README/source parity: PASS for all 33 `~~~systemverilog` blocks against their corresponding source files.
- Question coverage: PASS — 49 discovered entries, 49 exact source quotes, and 49 matching answers; no Q&A entry is intended to represent a question absent from its source.
- Final Edge rescan: the dedicated original Edge instance reported one existing EDA inspection tab (`109821722`, `8k9Q`) plus non-EDA GitHub/ChatGPT tabs and no new EDA Playground URL. No browser tab was closed or edited by this task; all 16 pages had already been captured and identity-verified before the rescan.
- Git checks: `git diff --check` PASS, full diff reviewed, intended-file staging only, one commit on the current branch, and push to the existing upstream only.
