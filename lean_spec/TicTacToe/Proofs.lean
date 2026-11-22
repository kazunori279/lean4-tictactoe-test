import TicTacToe.Spec

namespace TicTacToe

-- ---------------------------------------------------------------------------
-- 1. Formal invariants proved on the executable specification
-- ---------------------------------------------------------------------------

theorem initial_board_length : initialState.board.length = 9 := rfl

theorem other_involutive (p : Player) : p.other.other = p := by
  cases p <;> rfl

theorem other_ne_self (p : Player) : p.other ≠ p := by
  cases p <;> decide

theorem applyMove_rejects_finished_game (s : GameState) (pos : Nat)
    (hdone : s.status ≠ .ongoing) :
    applyMove s pos = .error "game_over" := by
  unfold applyMove
  simp [hdone]

theorem applyMove_rejects_out_of_bounds (s : GameState) (pos : Nat)
    (hongoing : s.status = .ongoing) (hge : pos ≥ 9) :
    applyMove s pos = .error "out_of_bounds" := by
  unfold applyMove
  simp [hongoing, hge]

theorem applyMove_preserves_board_length (s s' : GameState) (pos : Nat)
    (h : applyMove s pos = .ok s') :
    s'.board.length = s.board.length := by
  unfold applyMove at h
  split at h
  · cases h
  · split at h
    · cases h
    · split at h
      · cases h
      · split at h
        · cases h; simp
        · split at h
          · cases h; simp
          · cases h; simp

-- ---------------------------------------------------------------------------
-- 2. Elaboration-time sanity checks (#guard)
--    If any assertion fails, `lake test` / `lake build` fails at compile time.
-- ---------------------------------------------------------------------------

-- X wins on the top row: (0, 1, 2)
#guard
  match playMoves [0, 3, 1, 4, 2] with
  | .ok s => s.status == .won .X
  | .error _ => false

-- Draw game filling all 9 cells with no winner
#guard
  match playMoves [0, 1, 2, 4, 3, 5, 7, 6, 8] with
  | .ok s => s.status == .draw
  | .error _ => false

-- Playing on an occupied cell is rejected
#guard playMoves [0, 0] == .error "cell_occupied"

-- Playing after the game has been won is rejected
#guard playMoves [0, 3, 1, 4, 2, 5] == .error "game_over"

end TicTacToe
