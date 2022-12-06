defmodule Day05 do
  def parse do
    [stacks, instructions] =
      File.read!("input/input05.txt")
      |> String.split("\n\n")
      |> Enum.map(fn p -> String.split(p, "\n") end)

    parsed_stacks =
      stacks
      |> Enum.reverse()
      |> Enum.map(&String.graphemes/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.filter(fn [x | _] -> x !== " " end)
      |> Enum.map(&Enum.filter(&1, fn c -> c !== " " end))
      |> Enum.map(fn [x | t] -> {String.to_integer(x), Enum.reverse(t)} end)
      |> Map.new()

    parsed_instructions =
      instructions
      |> Enum.map(fn l ->
        Regex.run(~r/move (\d+) from (\d+) to (\d+)/, l, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
      end)

    {parsed_stacks, parsed_instructions}
  end

  def build_result(result) do
    Map.keys(result)
    |> Enum.sort()
    |> Enum.map(fn k -> hd(Map.get(result, k)) end)
    |> Enum.join()
  end

  def run({start, inst}) do
    Enum.reduce(inst, start, &Day05.execute/2)
  end

  def execute([count, from, to], start) do
    Enum.reduce(1..count, start, fn _, acc -> Day05.move(from, to, acc) end)
  end

  def move(from, to, stacks) do
    {i, f} = Map.get(stacks, from) |> List.pop_at(0)

    t = [i | Map.get(stacks, to)]

    stacks |> Map.put(from, f) |> Map.put(to, t)
  end

  @doc """
  Part1

  ## Examples

    iex> Day05.part1()
    "RFFFWBPNS"

  """
  def part1 do
    Day05.parse()
    |> Day05.run()
    |> Day05.build_result()
  end

  def run2({start, inst}) do
    Enum.reduce(inst, start, &Day05.execute2/2)
  end

  def execute2([count, from, to], start) do
    {i, f} = Map.get(start, from) |> Enum.split(count)

    t = i ++ Map.get(start, to)

    start
    |> Map.put(from, f)
    |> Map.put(to, t)
  end

  @doc """
  Part2

  ## Examples

    iex> Day05.part2()
    "CQQBBJFCS"

  """
  def part2 do
    Day05.parse()
    |> Day05.run2()
    |> Day05.build_result()
  end
end
