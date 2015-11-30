defmodule Rex2048.CLI do
  alias Rex2048.Game

  # https://elixirsips.dpdcart.com/subscriber/post?id=952
  # -c => Turn canonical mode off, that is get characters instead of lines.
  # -e => Turn echo off.
  def main(_args) do
    {:ok, Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])}

    loop(Game.init(4))
  end

  def loop(:quit), do: :ok
  def loop(game) do
    IO.write [
      IO.ANSI.home,
      IO.ANSI.clear,
      "\e[?25l"
    ]
    IO.write(game)

    receive do
      {_port, {:data, data}} ->
        translate(data)
        |> handle_key(game)
        |> loop
      _ ->
        loop(game)
    end
  end

  defp translate("\e[A"), do: :up
  defp translate("\e[B"), do: :down
  defp translate("\e[C"), do: :right
  defp translate("\e[D"), do: :left
  defp translate("q"), do: :quit
  defp translate("Q"), do: :quit
  defp translate(_), do: :nil

  defp handle_key(nil, game), do: game
  defp handle_key(:quit, _game), do: :quit
  defp handle_key(direction, game) do
    Rex2048.Game.move(game, direction)
  end

end
