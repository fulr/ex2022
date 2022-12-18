defmodule Day16 do
  def parse do
    File.read!("input/input16.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn l ->
      [valve, rate, others] =
        Regex.run(~r/Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.*)/, l,
          capture: :all_but_first
        )

      {
        valve,
        %{rate: String.to_integer(rate), next: String.split(others, ", "), dists: %{}}
      }
    end)
    |> Map.new()
  end

  @doc """
  Part1

  ## Examples

    iex> Day16.part1()
    2077

  """
  def part1 do
    topo = parse() |> build_dist()

    solve(topo, {"AA", "AA"}, {30, 0}, MapSet.new(Map.keys(topo)))
  end

  @doc """
  Part2

  ## Examples

    iex> Day16.part2()
    2741

  """
  def part2 do
    topo = parse() |> build_dist()

    solve(topo, {"AA", "AA"}, {26, 26}, MapSet.new(Map.keys(topo)))
  end

  def solve(topo, {va, vb}, {ta, tb}, valves_left) when ta < tb,
    do: solve(topo, {vb, va}, {tb, ta}, valves_left)

  def solve(_topo, _valve, {ta, _tb}, _valves_left) when ta <= 0, do: 0

  def solve(topo, {valve, other_valve}, {time_left, other_time_left}, valves_left) do
    %{rate: rate, dists: dists} = topo[valve]
    new_flow = rate * time_left

    valves_left
    |> Enum.map(fn v ->
      solve(
        topo,
        {v, other_valve},
        {time_left - dists[v] - 1, other_time_left},
        MapSet.delete(valves_left, v)
      ) +
        new_flow
    end)
    |> Enum.max(fn -> new_flow end)
  end

  def build_dist(topo) do
    keys = Map.keys(topo)

    dists =
      Enum.reduce(topo, Map.from_keys(keys, %{}), fn {src, %{next: next}}, acc ->
        Enum.reduce(next, acc, fn dest, a ->
          put_in(a, [src, dest], 1)
        end)
        |> put_in([src, src], 0)
      end)

    Enum.reduce(keys, dists, fn k, a ->
      Enum.reduce(keys, a, fn i, b ->
        Enum.reduce(keys, b, fn j, c ->
          update_in(c, [i, j], fn x ->
            min(x, (c[i][k] || 1_000_000) + (c[k][j] || 1_000_000))
          end)
        end)
      end)
    end)
    |> Enum.reduce(topo, fn {valve, dists}, acc ->
      if acc[valve].rate > 0 or valve == "AA" do
        put_in(acc[valve].dists, dists)
      else
        Map.delete(acc, valve)
      end
    end)
  end
end
