from hypothesis import given, settings, strategies as st

from tictactoe import play_moves


@settings(max_examples=500)
@given(moves=st.lists(st.integers(min_value=0, max_value=11), max_size=12))
def test_random_move_sequences_match_lean_spec(lean_oracle, moves: list[int]):
    """Includes invalid positions (9..11), duplicates, and extra moves after game over."""
    expected = lean_oracle.play(moves)
    actual = play_moves(moves)
    assert actual == expected


@settings(max_examples=500)
@given(moves=st.permutations(list(range(9))))
def test_full_game_permutations_match_lean_spec(lean_oracle, moves: list[int]):
    """Exercises valid games all the way to wins, draws, and post-win rejections."""
    for prefix_len in range(len(moves) + 1):
        seq = moves[:prefix_len]
        assert play_moves(seq) == lean_oracle.play(seq)
