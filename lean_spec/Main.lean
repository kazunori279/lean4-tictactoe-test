import Lean
import TicTacToe

open Lean
open TicTacToe

structure PlayRequest where
  moves : List Nat
  deriving FromJson

private def cellToJson : Cell → Json
  | none => Json.null
  | some p => Json.str p.toString

private def resultToJson : Except String GameState → Json
  | .error err =>
      Json.mkObj [("ok", Json.bool false), ("error", Json.str err)]
  | .ok s =>
      let (statusStr, winnerJson) :=
        match s.status with
        | .ongoing => ("ongoing", Json.null)
        | .draw => ("draw", Json.null)
        | .won p => ("won", Json.str p.toString)
      Json.mkObj
        [ ("ok", Json.bool true)
        , ("board", Json.arr (s.board.map cellToJson).toArray)
        , ("turn", Json.str s.turn.toString)
        , ("status", Json.str statusStr)
        , ("winner", winnerJson)
        ]

/-- Persistent JSON Lines oracle loop:
    reads one `{"moves": [...]}` JSON object per line from stdin,
    evaluates `TicTacToe.playMoves`, and writes one JSON response line to stdout. -/
partial def loop (stdin stdout : IO.FS.Stream) : IO Unit := do
  let line ← stdin.getLine
  if line.isEmpty then
    return ()
  let trimmed := line.trim
  if !trimmed.isEmpty then
    let resp : Json :=
      match Json.parse trimmed >>= fromJson? (α := PlayRequest) with
      | .error err =>
          Json.mkObj [("ok", Json.bool false), ("error", Json.str s!"invalid_json: {err}")]
      | .ok req =>
          resultToJson (playMoves req.moves)
    stdout.putStrLn resp.compress
    stdout.flush
  loop stdin stdout

def main : IO Unit := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  loop stdin stdout
