defmodule Rex2048.CLI do
  alias Rex2048.Game

  # https://elixirsips.dpdcart.com/subscriber/post?id=952
  # -c => Turn canonical mode off, that is get characters instead of lines.
  # -e => Turn echo off.
  def main(_args) do
    {:ok, Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])}

    :random.seed(:erlang.timestamp)
    Game.init(4)
    |> draw_board
    |> loop
  end

  def loop(nil), do: :ok
  def loop(game) do
    game = act_on_input(game)

    if game, do: draw_board(game)

    if game && Game.won?(game) do
      IO.write("\r\n\r\nGame won!\r\n")
      game = nil
    end

    if game && Game.lost?(game) do
      IO.write("\r\n\r\nGame lost!\r\n")
      game = nil
    end

    loop(game)
  end

  defp act_on_input(game) do
    receive do
      {_port, {:data, "\e[A"}} ->
        Rex2048.Game.move(game, :up)

      {_port, {:data, "\e[B"}} ->
        Rex2048.Game.move(game, :down)

      {_port, {:data, "\e[C"}} ->
        Rex2048.Game.move(game, :right)

      {_port, {:data, "\e[D"}} ->
        Rex2048.Game.move(game, :left)

      {_port, {:data, "q"}} ->
        nil

      _ ->
        game
    end
  end

  defp draw_board(game) do
    IO.write [
      "\e[?25l",     # Hide cursor
      IO.ANSI.home,
      IO.ANSI.clear
    ]
    IO.write("Rex2048 game. Use arrows to play and q to quit.\r\n\r\n")
    IO.write(game)
    game
  end

end
