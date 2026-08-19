# Internal Repository Notes

This folder keeps maintenance and audit material out of the repository's main directory while preserving it for later reference.

| File | Purpose |
|---|---|
| [EDA Playground audit](EDA_PLAYGROUND_AUDIT.md) | Historical identity, settings, source-parity, and question-coverage evidence for captured playgrounds. |
| [Discussion backlog](issues.md) | Small repository-maintenance and explanation topics that are not lesson files. |

The user-facing learning sequence remains under [`Codes/`](../../Codes/README.md), and the repository overview remains in the [main README](../../README.md).

The root `.gitignore` and `.gitattributes` files intentionally remain in place: Git applies them repository-wide from that location, so moving them here would break artifact filtering and source-whitespace handling.
