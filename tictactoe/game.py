from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

Player = Literal["X", "O"]
Cell = Player | None
Status = Literal["ongoing", "won", "draw"]

WINNING_LINES: tuple[tuple[int, int, int], ...] = (
    (0, 1, 2),
    (3, 4, 5),
    (6, 7, 8),
    (0, 3, 6),
    (1, 4, 7),
    (2, 5, 8),
    (0, 4, 8),
    (2, 4, 6),
)


@dataclass(frozen=True)
class GameState:
    board: tuple[Cell, ...]
    turn: Player
    status: Status
    winner: Player | None

    def to_dict(self) -> dict:
        return {
            "ok": True,
            "board": list(self.board),
            "turn": self.turn,
            "status": self.status,
            "winner": self.winner,
        }


def initial_state() -> GameState:
    return GameState(
        board=(None,) * 9,
        turn="X",
        status="ongoing",
        winner=None,
    )


def _other(player: Player) -> Player:
    return "O" if player == "X" else "X"


def _has_won(board: tuple[Cell, ...], player: Player) -> bool:
    return any(
        board[i] == player and board[j] == player and board[k] == player
        for i, j, k in WINNING_LINES
    )


def apply_move(state: GameState, pos: int) -> tuple[GameState | None, str | None]:
    """Apply a single move. Returns (new_state, None) or (None, error_code)."""
    if state.status != "ongoing":
        return None, "game_over"
    if pos < 0 or pos >= 9:
        return None, "out_of_bounds"
    if state.board[pos] is not None:
        return None, "cell_occupied"

    board_list = list(state.board)
    board_list[pos] = state.turn
    new_board = tuple(board_list)

    if _has_won(new_board, state.turn):
        return (
            GameState(
                board=new_board,
                turn=state.turn,
                status="won",
                winner=state.turn,
            ),
            None,
        )

    if all(cell is not None for cell in new_board):
        return (
            GameState(
                board=new_board,
                turn=state.turn,
                status="draw",
                winner=None,
            ),
            None,
        )

    return (
        GameState(
            board=new_board,
            turn=_other(state.turn),
            status="ongoing",
            winner=None,
        ),
        None,
    )


def play_moves(moves: list[int]) -> dict:
    """Replay a sequence of moves from the initial state and return a JSON-compatible result."""
    state = initial_state()
    for pos in moves:
        next_state, err = apply_move(state, pos)
        if err is not None:
            return {"ok": False, "error": err}
        assert next_state is not None
        state = next_state
    return state.to_dict()
