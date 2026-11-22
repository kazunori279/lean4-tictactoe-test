# lean4-tictactoe-test

A minimal, self-contained sample demonstrating how to pair a **Lean 4 executable specification and formal proofs** with a **Python** production implementation tested via **`pytest` + `Hypothesis`** (Verification-Guided Development / Differential Testing).

Includes a 20-slide interactive HTML deck (English & Japanese) walking through Lean 4 basics, Hypothesis, the VGD architecture, and every file step by step.

---

## Architecture

Instead of trying to formally verify dynamic Python code directly, we prove core invariants on a concise **Lean 4** model, compile it to a fast native binary, and use it as a ground-truth **Test Oracle** for **Hypothesis** differential testing:

```text
                       ┌──────────────────────────────────────┐
                       │  Lean 4 Executable Spec & Proofs     │
                       │  • Spec.lean   (pure reference model)│
                       │  • Proofs.lean (theorems + #guard)   │
                       │  • Main.lean   (native JSON oracle)  │
                       └──────────────────┬───────────────────┘
                                          │ expected (JSON Lines)
┌────────────────────────┐                ▼
│  Hypothesis Generator  │ ──▶ [ assert actual == expected ]
│  1,000s of random &    │                ▲
│  permutation move seqs │                │ actual (dict)
└────────────────────────┘  ┌─────────────┴───────────────────┐
                            │  Python Production Code         │
                            │  • tictactoe/game.py            │
                            └─────────────────────────────────┘
```

---

## Interactive Slides

Two self-contained HTML slide decks (20 slides each, with inline SVG diagrams and keyboard navigation `←` / `→` / `Space`) published via GitHub Pages:

- **English**: <https://kazunori279.github.io/lean4-tictactoe-test/> ([`slides.html`](slides.html))
- **Japanese**: <https://kazunori279.github.io/lean4-tictactoe-test/slides_ja.html> ([`slides_ja.html`](slides_ja.html))

---

## Repository Structure

| Path | Role |
| :--- | :--- |
| `tictactoe/game.py` | Pure Python Tic-Tac-Toe implementation (`apply_move`, `play_moves`) |
| `lean_spec/lean-toolchain` | Pins Lean 4 toolchain (`v4.22.0`) |
| `lean_spec/lakefile.toml` | Lake build configuration (`tictactoe_oracle` binary + `testDriver`) |
| `lean_spec/TicTacToe/Spec.lean` | Executable specification in Lean 4 (zero external dependencies) |
| `lean_spec/TicTacToe/Proofs.lean` | Formal invariants (`theorem`) and compile-time `#guard` assertions |
| `lean_spec/Main.lean` | Persistent stdin/stdout JSON Lines oracle CLI |
| `tests/conftest.py` | Session-scoped `pytest` fixture managing the persistent Lean 4 oracle process |
| `tests/test_unit.py` | Standard example-based Python unit tests |
| `tests/test_differential.py` | Hypothesis differential tests comparing Python against the Lean 4 oracle |
| `slides.html` / `slides_ja.html` | Interactive walkthrough slides (EN / JA) |

---

## Quick Start

### Prerequisites

- [uv](https://docs.astral.sh/uv/) (Python package & environment manager)
- [elan](https://github.com/leanprover/elan) (Lean 4 toolchain manager)

If `elan` is not installed yet:

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
```

### 1. Verify Proofs & Build the Lean 4 Oracle

```bash
cd lean_spec
lake test   # verifies all theorems and #guard assertions in Proofs.lean
lake build  # compiles native binary at .lake/build/bin/tictactoe_oracle
```

### 2. Run Python Unit Tests + Hypothesis Differential Tests

```bash
cd ..
uv sync
uv run pytest -v
```

> **Note:** If the Lean 4 oracle binary has not been built yet, `tests/test_differential.py` is skipped automatically while `tests/test_unit.py` still runs.

---

## Hands-On Experiment: Catch a Subtle Bug

Once all tests pass, try introducing a realistic bug in `tictactoe/game.py` by removing the anti-diagonal line `(2, 4, 6)` from `WINNING_LINES`:

```python
WINNING_LINES = (
    ...
    (0, 4, 8),
    # (2, 4, 6),  <-- comment this out
)
```

Then re-run:

```bash
uv run pytest -v
```

- `tests/test_unit.py` will **still pass** (false confidence!).
- `tests/test_differential.py` will **immediately fail** against the Lean 4 oracle and **Hypothesis will automatically shrink** the failure down to a minimal 5-move counterexample (such as `[2, 0, 4, 1, 6]`).

---

## Further Reading

- [Lean 4 Official Documentation](https://lean-lang.org/documentation/)
- [Hypothesis — Property-Based Testing for Python](https://hypothesis.readthedocs.io/)
- [AWS Cedar Formal Specification in Lean 4 (`cedar-spec`)](https://github.com/cedar-policy/cedar-spec)
- [Plausible — Property-Based Testing inside Lean 4](https://github.com/leanprover-community/plausible)

---

Author: [@kazunori_279](https://x.com/kazunori_279)
