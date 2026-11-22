# Lean 4 Executable Specification + Python Differential Testing (Tic-Tac-Toe)

Minimal sample showing how to pair a **Lean 4** executable specification and formal proofs with a **Python** production implementation tested via `pytest` + `Hypothesis`.

## Layout

- `tictactoe/game.py`: Production Python Tic-Tac-Toe logic.
- `lean_spec/TicTacToe/Spec.lean`: Executable specification in Lean 4.
- `lean_spec/TicTacToe/Proofs.lean`: Formal invariants + `#guard` elaboration-time checks.
- `lean_spec/Main.lean`: Persistent JSON Lines oracle CLI compiled to a native binary.
- `tests/conftest.py`: Session-scoped pytest fixture managing the Lean 4 oracle process.
- `tests/test_unit.py`: Standard Python unit tests.
- `tests/test_differential.py`: Hypothesis differential tests comparing Python vs Lean 4.

## Quick Start

1. Install Lean 4 toolchain manager (`elan`) if not already installed:
   ```bash
   curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
   ```

2. Verify proofs and build the Lean 4 oracle binary:
   ```bash
   cd lean_spec
   lake test   # checks Proofs.lean theorems & #guard assertions
   lake build  # compiles .lake/build/bin/tictactoe_oracle
   ```

3. Run Python unit tests + Hypothesis differential tests:
   ```bash
   cd ..
   uv sync
   uv run pytest -v
   ```
