defmodule Rex2048.Board do

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
      iex> Rex2048.Board.to_rows([1, 2, 3, 4])
      [[1, 2], [3, 4]]

      iex> Rex2048.Board.to_rows([1, 2, 3, 4, 5, 6, 7, 8, 9])
      [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  """
  def to_rows(board) do
    Enum.chunk(board, size(board))
  end

  @doc """
      iex> Rex2048.Board.from_rows([[1, 2], [3, 4]])
      [1, 2, 3, 4]

      iex> Rex2048.Board.from_rows([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      [1, 2, 3, 4, 5, 6, 7, 8, 9]
  """
  def from_rows(rows) do
    Enum.concat(rows)
  end

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
    |> Enum.chunk(size(board))
    |> Enum.map(&Enum.reverse/1)
    |> Enum.concat
  end

  @doc """
      iex> Rex2048.Board.collapse_and_pad([0, 2, 2, 0, 0, 0, 1, 1, 1])
      [4, 0, 0, 0, 0, 0, 2, 1, 0]
  """
  def collapse_and_pad(board) do
    board
    |> Enum.chunk(size(board))
    |> Enum.map(&collapse_row/1)
    |> Enum.map(&(pad_row(&1, size(board))))
    |> Enum.concat
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

  defp _collaps_row([]) do
    []
  end

  defp _collaps_row([num, num | rest]) do
    [num + num] ++ _collaps_row(rest)
  end

  defp _collaps_row([num | rest]) do
    [num] ++ _collaps_row(rest)
  end

  @doc """
      iex> Rex2048.Board.pad_row([1, 2, 3], 5)
      [1, 2, 3, 0, 0]
  """
  def pad_row(row, size) when size > length(row) do
    row ++ List.duplicate(0, (size - length(row)))
  end

  @doc """
      iex> Rex2048.Board.insert_at_random([1, 0, 2, 4, 0])
      [1, 4, 2, 4, 0]

      iex> Rex2048.Board.insert_at_random([1, 8, 2, 4, 0])
      [1, 8, 2, 4, 2]
  """
  def insert_at_random(board) do
    index = board
    |> Enum.with_index
    |> Enum.map(fn {x, i} -> if(x == 0, do: i, else: nil) end)
    |> Enum.filter(&(&1))
    |> Enum.random

    number = if(:random.uniform < 0.9, do: 2, else: 4)
    List.replace_at(board, index, number)
  end

  defp size(board) do
    length(board)
    |> :math.sqrt
    |> round
  end

end
