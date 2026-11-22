from tictactoe import play_moves


def test_x_wins_top_row():
    res = play_moves([0, 3, 1, 4, 2])
    assert res["ok"] is True
    assert res["status"] == "won"
    assert res["winner"] == "X"


def test_draw_game():
    res = play_moves([0, 1, 2, 4, 3, 5, 7, 6, 8])
    assert res["ok"] is True
    assert res["status"] == "draw"
    assert res["winner"] is None


def test_rejects_occupied_cell():
    assert play_moves([0, 0]) == {"ok": False, "error": "cell_occupied"}


def test_rejects_out_of_bounds():
    assert play_moves([9]) == {"ok": False, "error": "out_of_bounds"}


def test_rejects_move_after_win():
    assert play_moves([0, 3, 1, 4, 2, 5]) == {"ok": False, "error": "game_over"}
