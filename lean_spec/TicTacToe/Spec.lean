namespace TicTacToe

inductive Player where
  | X
  | O
  deriving BEq, DecidableEq, Repr

def Player.other : Player → Player
  | .X => .O
  | .O => .X

def Player.toString : Player → String
  | .X => "X"
  | .O => "O"

abbrev Cell := Option Player
abbrev Board := List Cell

def emptyBoard : Board := List.replicate 9 none

def winningLines : List (Nat × Nat × Nat) :=
  [ (0, 1, 2), (3, 4, 5), (6, 7, 8)
  , (0, 3, 6), (1, 4, 7), (2, 5, 8)
  , (0, 4, 8), (2, 4, 6)
  ]

def cellAt (b : Board) (i : Nat) : Cell :=
  match b[i]? with
  | some c => c
  | none => none

def hasWon (b : Board) (p : Player) : Bool :=
  winningLines.any fun (i, j, k) =>
    cellAt b i == some p && cellAt b j == some p && cellAt b k == some p

def isFull (b : Board) : Bool :=
  b.all Option.isSome

inductive GameStatus where
  | ongoing
  | won (p : Player)
  | draw
  deriving BEq, DecidableEq, Repr

structure GameState where
  board : Board
  turn : Player
  status : GameStatus
  deriving BEq, Repr

def initialState : GameState :=
  { board := emptyBoard, turn := .X, status := .ongoing }

def applyMove (s : GameState) (pos : Nat) : Except String GameState :=
  if s.status != .ongoing then
    .error "game_over"
  else if pos ≥ 9 then
    .error "out_of_bounds"
  else if cellAt s.board pos != none then
    .error "cell_occupied"
  else
    let board' := s.board.set pos (some s.turn)
    if hasWon board' s.turn then
      .ok { board := board', turn := s.turn, status := .won s.turn }
    else if isFull board' then
      .ok { board := board', turn := s.turn, status := .draw }
    else
      .ok { board := board', turn := s.turn.other, status := .ongoing }

def playMoves (moves : List Nat) : Except String GameState :=
  moves.foldlM applyMove initialState

end TicTacToe
