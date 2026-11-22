from __future__ import annotations

import json
import subprocess
from pathlib import Path
from typing import Iterator

import pytest

ORACLE_BIN = (
    Path(__file__).resolve().parent.parent
    / "lean_spec"
    / ".lake"
    / "build"
    / "bin"
    / "tictactoe_oracle"
)


class LeanOracle:
    """Thin client wrapping a persistent Lean 4 JSON Lines oracle process."""

    def __init__(self, binary_path: Path) -> None:
        self._proc = subprocess.Popen(
            [str(binary_path)],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
        )

    def play(self, moves: list[int]) -> dict:
        assert self._proc.stdin is not None
        assert self._proc.stdout is not None
        self._proc.stdin.write(json.dumps({"moves": moves}) + "\n")
        self._proc.stdin.flush()
        line = self._proc.stdout.readline()
        if not line:
            stderr = self._proc.stderr.read() if self._proc.stderr else ""
            raise RuntimeError(f"Lean oracle exited unexpectedly: {stderr}")
        return json.loads(line)

    def close(self) -> None:
        if self._proc.stdin and not self._proc.stdin.closed:
            self._proc.stdin.close()
        self._proc.wait(timeout=5)


@pytest.fixture(scope="session")
def lean_oracle() -> Iterator[LeanOracle]:
    if not ORACLE_BIN.exists():
        pytest.skip(
            f"Lean oracle binary not found at {ORACLE_BIN}. "
            "Build it first with: cd lean_spec && lake build"
        )
    oracle = LeanOracle(ORACLE_BIN)
    try:
        yield oracle
    finally:
        oracle.close()
