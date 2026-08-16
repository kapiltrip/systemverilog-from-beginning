# EDA Playground backlog audit

This audit records the Edge tabs captured for the continuation of the learning sequence and the final saved EDA Playground names. The visible `Name` control on each reloaded page is the authoritative identity field; the hidden `codeName` mirror is not populated consistently by the current editor page. Every name below was saved directly on the existing short link, without copying or forking the playground.

All captured pages use the same verified settings unless noted otherwise: simulator `Riviera Pro 2025.04`, compile options `-timescale 1ns/1ns`, and run options `+access+r`.

| Part | Short ID / code link | Exact verified browser-tab title | Exact saved EDA Playground Name | Repository mapping | Source presence |
|---:|---|---|---|---|---|
| 07 | [CafY](https://edaplayground.com/x/CafY) · code ID `7356412` | `Whole-Array Copying - EDA Playground` | `Whole-Array Copying` | `07-array-copying` · H1 `Part 07 — Whole-array copying` · index **Whole-Array Copying** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 08 | [bKTC](https://edaplayground.com/x/bKTC) · code ID `7356536` | `Queue Operations - EDA Playground` | `Queue Operations` | `08-queue-operations` · H1 `Part 08 — Queue operations` · index **Queue Operations** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 09 | [qLDu](https://edaplayground.com/x/qLDu) · code ID `7356678` | `Class Object Basics - EDA Playground` | `Class Object Basics` | `09-class-object-basics` · H1 `Part 09 — Class object basics` · index **Class Object Basics** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 10 | [ecCx](https://edaplayground.com/x/ecCx) · code ID `7356696` | `Tasks and Functions - EDA Playground` | `Tasks and Functions` | `10-tasks-and-functions` · H1 `Part 10 — Tasks and functions` · index **Tasks and Functions** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 11 | [Ua2v](https://edaplayground.com/x/Ua2v) · code ID `7357015` | `Pass by Reference - EDA Playground` | `Pass by Reference` | `11-pass-by-reference` · H1 `Part 11 — Pass by reference` · index **Pass by Reference** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 12 | [ADYn](https://edaplayground.com/x/ADYn) · code ID `7357071` | `Array Reference Passing - EDA Playground` | `Array Reference Passing` | `12-array-reference-passing` · H1 `Part 12 — Array reference passing` · index **Array Reference Passing** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 13 | [Ud7M](https://edaplayground.com/x/Ud7M) · code ID `7357115` | `Constructor Arguments - EDA Playground` | `Constructor Arguments` | `13-constructor-arguments` · H1 `Part 13 — Constructor arguments` · index **Constructor Arguments** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 14 | [EasK](https://edaplayground.com/x/EasK) · code ID `7357152` | `Class Composition and Scope - EDA Playground` | `Class Composition and Scope` | `14-class-composition-and-scope` · H1 `Part 14 — Class composition and scope` · index **Class Composition and Scope** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 15 | [sVdz](https://edaplayground.com/x/sVdz) · code ID `7357619` | `Class Shallow Copy - EDA Playground` | `Class Shallow Copy` | `15-class-shallow-copy` · H1 `Part 15 — Class shallow copying` · index **Class Shallow Copy** | `design.sv`, captured `testbench.sv`, corrected `self_checking_testbench.sv` |
| 16 | [X4c6](https://edaplayground.com/x/X4c6) · code ID `7357655` | `Class Custom Copy Method - EDA Playground` | `Class Custom Copy Method` | `16-class-custom-copy-method` · H1 `Part 16 — Class custom copy method` · index **Class Custom Copy Method** | `design.sv`, saved `testbench.sv`, visible `editor_testbench.sv`, corrected `self_checking_testbench.sv` |

## Final Edge tab rescan

The final Edge rescan found these EDA tab instances. The second `CafY` tab is the original queue tab; its browser process retained the pre-rename caption `SV 07 - Array Copying - EDA Playground` after the direct save. The same existing CafY short link was reloaded in the fresh Edge tab shown first, and the live page name, code ID, code, and settings were verified there. It is a stale browser caption, not a second playground or a second saved name.

| Edge tab ID | Short ID | Final visible tab title | Identity result |
|---:|---|---|---|
| `109821700` | CafY | `Whole-Array Copying - EDA Playground` | Reloaded same-link recovery tab; Name `Whole-Array Copying`, code ID `7356412` |
| `109821634` | qLDu | `Class Object Basics - EDA Playground` | Name `Class Object Basics`, code ID `7356678` |
| `109821679` | X4c6 | `Class Custom Copy Method - EDA Playground` | Name `Class Custom Copy Method`, code ID `7357655` |
| `109821687` | sVdz | `Class Shallow Copy - EDA Playground` | Name `Class Shallow Copy`, code ID `7357619` |
| `109821608` | Ua2v | `Pass by Reference - EDA Playground` | Name `Pass by Reference`, code ID `7357015` |
| `109821655` | EasK | `Class Composition and Scope - EDA Playground` | Name `Class Composition and Scope`, code ID `7357152` |
| `109821628` | bKTC | `Queue Operations - EDA Playground` | Name `Queue Operations`, code ID `7356536` |
| `109821693` | CafY | `SV 07 - Array Copying - EDA Playground` | Original tab with stale pre-rename caption; same saved CafY page was verified via `109821700` |
| `109821503` | ecCx | `Tasks and Functions - EDA Playground` | Name `Tasks and Functions`, code ID `7356696` |
| `109821638` | ADYn | `Array Reference Passing - EDA Playground` | Name `Array Reference Passing`, code ID `7357071` |
| `109821650` | Ud7M | `Constructor Arguments - EDA Playground` | Name `Constructor Arguments`, code ID `7357115` |
| `109821662` | sVdz | `Class Shallow Copy - EDA Playground` | Second browser tab for the same short link; same Name and code ID, not a duplicate playground |

No final tab remained blank or had the generic `Edit code - EDA Playground` caption. The duplicate browser instances are two views of the same `sVdz` playground; the duplicate CafY view is the original tab plus a same-link reload used only to recover the stale Edge binding. No new EDA Playground short ID was created.

## Verification notes

- Parts 07–15 were captured in the queue order established by the preceding six repository exercises. The late-rescanned `X4c6` tab was assigned the next number, 16, so it cannot be swapped with or overwrite part 15.
- Each part README now records the exact saved EDA Playground Name beside its short link. The root README index title, folder slug, README H1, and saved EDA name agree semantically for every part.
- The first rendered SystemVerilog block in each part README matches `self_checking_testbench.sv`; the next rendered block matches the captured `testbench.sv`. Part 16 additionally renders and matches `editor_testbench.sv` because its visible unsaved editor buffer differed from the saved field.
- Parts 09, 12, and 15 preserve the original page failures (null dereference, orphan `*/`, and missing semicolon) in `testbench.sv`. The corrected files and README text identify each change rather than silently replacing the captured source.
- The direct rename verification kept each short URL, code ID, design/testbench source presence, simulator, compile options, and run options unchanged. The local Icarus verification matrix passes the supported corrected examples (08, 09, 10, 15, and 16). Icarus reports unsupported SystemVerilog features for 07, 11, 12, 13, and 14; those limitations are documented in the corresponding READMEs. The saved Edge settings remain Riviera Pro 2025.04 for every captured page.
