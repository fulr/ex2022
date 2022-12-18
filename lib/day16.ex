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
    nil

  """
  def part1 do
    topo = parse() |> build_dist()

    # |> find_best_path()
    # |> Enum.map(&elem(&1, 1))
    # |> Enum.max()

    solve(topo, "AA", 30, MapSet.new(Map.keys(topo)))
  end

  def solve(topo, valve, time_left, valvesLeft) do
    %{rate: rate, dists: dists} = topo[valve]
    new_flow = rate * time_left

    valvesLeft
    |> Enum.filter(fn v -> time_left > dists[v] + 1 end)
    |> Enum.map(fn v ->
      solve(topo, v, time_left - dists[v] - 1, MapSet.delete(valvesLeft, v)) +
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

  def build_next(topo, {current_valve, current_budget, current_released_pressure, open_valves}) do
    topo[current_valve].dists
    |> Enum.filter(fn {k, _} -> k not in open_valves and topo[k].rate > 0 end)
    |> Enum.map(fn {next_valve, dist} ->
      new_budget = current_budget - dist - 1

      {
        next_valve,
        new_budget,
        current_released_pressure + new_budget * topo[next_valve].rate,
        MapSet.put(open_valves, next_valve)
      }
    end)
  end

  def find_best_path(topo),
    do: find_best_path(topo, build_next(topo, {"AA", 30, 0, MapSet.new()}), %{})

  def find_best_path(_topo, [], result), do: result

  def find_best_path(topo, todo, result) do
    [current | rest] = todo
    {_current_valve, current_budget, current_released_pressure, open_valves} = current

    # rest = MapSet.delete(todo, current)

    # IO.inspect(current)

    if Map.get(result, open_valves, 0) < current_released_pressure and current_budget >= 0 do
      find_best_path(
        topo,
        rest ++ build_next(topo, current),
        Map.put(result, open_valves, current_released_pressure)
      )
    else
      find_best_path(
        topo,
        rest,
        result
      )
    end
  end

  @doc """
  Part2

  ## Examples

    iex> Day16.part2()
    nil

  """
  def part2 do
  end
end
