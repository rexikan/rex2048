defmodule Rex2048.Game do
  defstruct [:board, :score]

  alias Rex2048.Board
  alias Rex2048.Game

  @doc """
      iex> Rex2048.Game.init(2)
      %Rex2048.Game{board: [2, 2, 0, 0], score: 0}

      iex> Rex2048.Game.init(3)
      %Rex2048.Game{board: [2, 0, 0, 0, 0, 0, 0, 0, 2], score: 0}
  """
  def init(size) when size > 1 do
    board = Board.empty(size)
    |> Board.insert_at_random
    |> Board.insert_at_random
    %Game{board: board, score: 0}
  end

  @doc """
      iex> board = %Rex2048.Game{board: [0, 2, 0, 4, 2, 4, 4, 4, 4], score: 0}
      ...> Rex2048.Game.move(board, :left)
      %Rex2048.Game{board: [2, 2, 0, 4, 2, 4, 8, 4, 0], score: 8}

      iex> board = %Rex2048.Game{board: [0, 2, 0, 4, 2, 4, 4, 4, 4], score: 8}
      ...> Rex2048.Game.move(board, :right)
      %Rex2048.Game{board: [2, 0, 2, 4, 2, 4, 0, 4, 8], score: 16}

      iex> board = %Rex2048.Game{board: [8, 4, 8, 2, 4, 0, 0, 0, 4], score: 10}
      ...> Rex2048.Game.move(board, :up)
      %Rex2048.Game{board: [8, 8, 8, 2, 2, 4, 0, 0, 0], score: 18}

      iex> board = %Rex2048.Game{board: [0, 2, 0, 4, 2, 4, 4, 4, 4], score: 10}
      ...> Rex2048.Game.move(board, :down)
      %Rex2048.Game{board: [2, 0, 0, 0, 4, 0, 8, 4, 8], score: 30}
  """
  def move(%Game{board: board, score: score}, direction) do
    updated_board = Board.push(board, direction)
    points = Board.calculate_points(board, updated_board)

    updated_board = Board.insert_at_random(updated_board)

    %Game{board: updated_board, score: score + points}
  end

  @doc """
      iex> Rex2048.Game.over?([2,0,0,0])
      false

      iex> Rex2048.Game.over?([2,4,8,16])
      true

      iex> Rex2048.Game.over?([2048,2,4,4])
      true
  """
  def over?(board) do
    !Board.can_move?(board) || Board.reached_2048?(board)
  end
end

defimpl String.Chars, for: Rex2048.Game do
  def to_string(%Rex2048.Game{board: board, score: score}) do
    stringified_board = board
    |> Enum.map(fn number ->
      number
      |> Integer.to_string
      |> String.rjust(4)
    end)
    |> Rex2048.Board.rows
    |> Enum.join("\n")
    "Score: #{score}\n" <> stringified_board
  end
end
