defmodule Rex2048.Board do

  @doc """
      iex> Rex2048.Board.full?([2, 2, 4, 8])
      true

      iex> Rex2048.Board.full?([2, 0, 4, 4])
      false
  """
  def full?(board) do
    Enum.all?(board, &(&1 != 0))
  end

  @doc """
      iex> Rex2048.Board.reached_2048?([1, 2048, 0, 0])
      true

      iex> Rex2048.Board.reached_2048?([2, 0, 2, 2])
      false
  """
  def reached_2048?(board) do
    Enum.any?(board, &(&1 == 2048))
  end

  @doc """
      iex> Rex2048.Board.push([0, 0, 1, 2, 0, 2, 2, 2, 2], :left)
      [1, 0, 0, 4, 0, 0, 4, 2, 0]

      iex> Rex2048.Board.push([0, 0, 1, 2, 0, 2, 2, 2, 2], :right)
      [0, 0, 1, 0, 0, 4, 0, 2, 4]

      iex> Rex2048.Board.push([0, 0, 1, 2, 0, 2, 2, 2, 2], :up)
      [4, 2, 1, 0, 0, 4, 0, 0, 0]

      iex> Rex2048.Board.push([0, 0, 1, 2, 0, 2, 2, 2, 2], :down)
      [0, 0, 0, 0, 0, 1, 4, 2, 4]
  """
  def push(board, :left) do
    board
    |> collapse_and_pad
  end

  def push(board, :right) do
    board
    |> mirror
    |> push(:left)
    |> mirror
  end

  def push(board, :up) do
    board
    |> transpose
    |> push(:left)
    |> transpose
  end

  def push(board, :down) do
    board
    |> transpose
    |> push(:right)
    |> transpose
  end

  @doc """
      iex> Rex2048.Board.empty(2)
      [0, 0, 0, 0]

      iex> Rex2048.Board.empty(3)
      [0, 0, 0, 0, 0, 0, 0, 0, 0]
  """
  def empty(size) when size > 1 do
    for _ <- 1..(size * size), do: 0
  end

  @doc """
      iex> Rex2048.Board.calculate_points([0, 1, 1, 0], [1, 0, 1, 0])
      0

      iex> Rex2048.Board.calculate_points([1, 1, 2, 2], [2, 0, 4, 0])
      6

      iex> Rex2048.Board.calculate_points([4, 4, 2, 2], [8, 0, 4, 0])
      12
  """
  def calculate_points(before_push, after_push) do
    _calculate_points(
      Enum.reverse(Enum.sort(before_push)),
      Enum.reverse(Enum.sort(after_push))
    )
  end

  defp _calculate_points([x | b_rest], [x | a_rest]) do
    _calculate_points(b_rest, a_rest)
  end

  defp _calculate_points([x, x | b_rest], [y | a_rest]) do
    y + _calculate_points(b_rest, a_rest)
  end

  defp _calculate_points([], _), do: 0

  @doc """
      iex> Rex2048.Board.transpose([1, 2, 3, 4])
      [1, 3, 2, 4]

      iex> Rex2048.Board.transpose([1, 2, 3, 4, 5, 6, 7, 8, 9])
      [1, 4, 7, 2, 5, 8, 3, 6, 9]
  """
  def transpose(board) do
    for offset <- 0..(size(board) - 1) do
      Enum.take_every(Enum.drop(board, offset), size(board))
    end
    |> Enum.concat
  end

  @doc """
      iex> Rex2048.Board.mirror([1, 2, 3, 4])
      [2, 1, 4, 3]

      iex> Rex2048.Board.mirror([3, 2, 1, 6, 5, 4, 9, 8, 7])
      [1, 2, 3, 4, 5, 6, 7, 8, 9]
  """
  def mirror(board) do
    board
    |> rows
    |> Enum.map(&Enum.reverse/1)
    |> Enum.concat
  end

  @doc """
      iex> Rex2048.Board.collapse_and_pad([0, 2, 2, 0, 0, 0, 1, 1, 1])
      [4, 0, 0, 0, 0, 0, 2, 1, 0]
  """
  def collapse_and_pad(board) do
    board
    |> rows
    |> Enum.map(&collapse_row/1)
    |> Enum.map(&(pad_row(&1, size(board))))
    |> Enum.concat
  end

  @doc """
      iex> Rex2048.Board.rows([0, 2, 2, 0])
      [[0, 2], [2, 0]]
  """
  def rows(board) do
    Enum.chunk(board, size(board))
  end

  @doc """
      iex> Rex2048.Board.collapse_row([0, 2, 2, 1, 0, 1, 1, 4, 0])
      [4, 2, 1, 4]
  """
  def collapse_row(row) do
    row
    |> Enum.reject(&(&1 == 0))
    |> _collaps_row
  end

  defp _collaps_row([]), do: []

  defp _collaps_row([num, num | rest]) do
    [num + num] ++ _collaps_row(rest)
  end

  defp _collaps_row([num | rest]) do
    [num] ++ _collaps_row(rest)
  end

  defp pad_row(row, size) do
    row ++ List.duplicate(0, (size - length(row)))
  end

  @doc """
      iex> Rex2048.Board.insert_at_random([1, 0, 2, 4, 0])
      [1, 2, 2, 4, 0]

      iex> Rex2048.Board.insert_at_random([1, 8, 2, 4, 0])
      [1, 8, 2, 4, 2]

      iex> Rex2048.Board.insert_at_random([1, 8, 2, 4, 1])
      [1, 8, 2, 4, 1]
  """
  def insert_at_random(board) do
    indexes = board
    |> Enum.with_index
    |> Enum.filter(fn {x, _} -> x == 0 end)
    |> Enum.map(fn {_, i} -> i end)

    if length(indexes) > 0 do
      number = if(:random.uniform < 0.9, do: 2, else: 4)
      List.replace_at(board, Enum.random(indexes), number)
    else
      board
    end
  end

  defp size(board) do
    length(board)
    |> :math.sqrt
    |> round
  end

end
