defmodule Day19 do
  def parse do
    File.read!("input/input19.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn x ->
      [id, ore4ore, ore4clay, ore4obsidian, clay4obsidian, ore4geode, obsidian4geode] =
        Regex.run(
          ~r/Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./,
          x,
          capture: :all_but_first
        )
        |> Enum.map(&String.to_integer/1)

      %{
        id: id,
        ore: %{ore: ore4ore},
        clay: %{ore: ore4clay},
        obsidian: %{ore: ore4obsidian, clay: clay4obsidian},
        geode: %{ore: ore4geode, obsidian: obsidian4geode},
        max_ore: max(max(ore4ore, ore4clay), max(ore4obsidian, ore4geode))
      }
    end)
  end

  @doc """
  Part1

  ## Examples

    iex> Day19.part1()
    1349

  """
  def part1 do
    blueprints = parse()

    Enum.sum(for %{id: i} = c <- blueprints, do: start(c, 24) * i)
  end

  @doc """
  Part2

  ## Examples

    iex> Day19.part2()
    21840

  """
  def part2 do
    blueprints = parse()

    for %{id: i} = c <- blueprints, i < 4 do
      Task.async(fn -> start(c, 32) end)
    end
    |> Task.await_many(400_000)
    |> Enum.reduce(&*/2)
  end

  # copy of https://github.com/rewritten/aoc.ex/blob/main/2022/Day%2019:%20Not%20Enough%20Minerals.livemd

  @initial_bots {1, 0, 0, 0}
  @initial_reserve {0, 0, 0, 0}

  def start(costs, t) do
    bots = @initial_bots
    reserve = @initial_reserve
    work(0, bots, reserve, costs, t)
  end

  def work(mx, bots, reserve, costs, 0) do
    do_work(mx, nil, bots, reserve, costs, 0)
  end

  def work(mx, bots, reserve, costs, t) do
    mx
    |> do_work(:geode, bots, reserve, costs, t)
    |> do_work(:obsidian, bots, reserve, costs, t)
    |> do_work(:clay, bots, reserve, costs, t)
    |> do_work(:ore, bots, reserve, costs, t)
    |> do_work(nil, bots, reserve, costs, t)
  end

  # do nothing
  def do_work(mx, nil, {_, _, _, bots}, {_, _, _, reserve}, _, t), do: max(mx, reserve + bots * t)

  # not enough obsidian production to get a geode bot in time
  def do_work(mx, :geode, {_, _, b, _}, {_, _, r, _}, %{geode: %{obsidian: c}}, t)
      when b * (t - 2) + r < c,
      do: mx

  # not enough ore production to get a geode bot in time
  def do_work(mx, :geode, {b, _, _, _}, {r, _, _, _}, %{geode: %{ore: c}}, t)
      when b * (t - 2) + r < c,
      do: mx

  # not enough clay production to get an obsidian bot in time
  def do_work(mx, :obsidian, {_, b, _, _}, {_, r, _, _}, %{obsidian: %{clay: c}}, t)
      when b * (t - 2) + r < c,
      do: mx

  # not enough ore production to get an obsidian bot in time
  def do_work(mx, :obsidian, {b, _, _, _}, {r, _, _, _}, %{obsidian: %{ore: c}}, t)
      when b * (t - 2) + r < c,
      do: mx

  # not enough ore production to get a clay bot in time
  def do_work(mx, :clay, {b, _, _, _}, {r, _, _, _}, %{clay: %{ore: c}}, t)
      when b * (t - 2) + r < c,
      do: mx

  # not enough ore production to get an ore bot in time
  def do_work(mx, :ore, {b, _, _, _}, {r, _, _, _}, %{ore: %{ore: c}}, t)
      when b * (t - 2) + r < c,
      do: mx

  # no more obsidian bots needed
  def do_work(mx, :obsidian, {_, _, b, _}, _, %{geode: %{obsidian: c}}, _)
      when b >= c,
      do: mx

  # no more clay bots needed
  def do_work(mx, :clay, {_, b, _, _}, _, %{obsidian: %{clay: c}}, _)
      when b >= c,
      do: mx

  # no more ore bots needed
  def do_work(mx, :ore, {b, _, _, _}, _, c, _)
      when b >= c.clay.ore and b >= c.obsidian.ore and b >= c.geode.ore,
      do: mx

  def do_work(mx, :geode, bots, reserve, costs, t) do
    {ore_bots, clay_bots, obsidian_bots, geode_bots} = bots
    {ore_reserve, clay_reserve, obsidian_reserve, geode_reserve} = reserve
    %{geode: %{ore: ore_cost, obsidian: obsidian_cost}} = costs

    t_needed =
      0
      |> max(div(ore_cost - ore_reserve + ore_bots - 1, ore_bots))
      |> max(div(obsidian_cost - obsidian_reserve + obsidian_bots - 1, obsidian_bots))
      |> Kernel.+(1)

    reserve = {
      ore_reserve + t_needed * ore_bots - ore_cost,
      clay_reserve + t_needed * clay_bots,
      obsidian_reserve + t_needed * obsidian_bots - obsidian_cost,
      geode_reserve + t_needed * geode_bots
    }

    bots = {ore_bots, clay_bots, obsidian_bots, geode_bots + 1}

    work(mx, bots, reserve, costs, t - t_needed)
  end

  def do_work(mx, :obsidian, bots, reserve, costs, t) do
    {ore_bots, clay_bots, obsidian_bots, geode_bots} = bots
    {ore_reserve, clay_reserve, obsidian_reserve, geode_reserve} = reserve
    %{obsidian: %{ore: ore_cost, clay: clay_cost}} = costs

    t_needed =
      0
      |> max(div(ore_cost - ore_reserve + ore_bots - 1, ore_bots))
      |> max(div(clay_cost - clay_reserve + clay_bots - 1, clay_bots))
      |> Kernel.+(1)

    reserve = {
      ore_reserve + t_needed * ore_bots - ore_cost,
      clay_reserve + t_needed * clay_bots - clay_cost,
      obsidian_reserve + t_needed * obsidian_bots,
      geode_reserve + t_needed * geode_bots
    }

    bots = {ore_bots, clay_bots, obsidian_bots + 1, geode_bots}

    work(mx, bots, reserve, costs, t - t_needed)
  end

  def do_work(mx, :clay, bots, reserve, costs, t) do
    {ore_bots, clay_bots, obsidian_bots, geode_bots} = bots
    {ore_reserve, clay_reserve, obsidian_reserve, geode_reserve} = reserve
    %{clay: %{ore: ore_cost}} = costs

    t_needed =
      0
      |> max(div(ore_cost - ore_reserve + ore_bots - 1, ore_bots))
      |> Kernel.+(1)

    reserve = {
      ore_reserve + t_needed * ore_bots - ore_cost,
      clay_reserve + t_needed * clay_bots,
      obsidian_reserve + t_needed * obsidian_bots,
      geode_reserve + t_needed * geode_bots
    }

    bots = {ore_bots, clay_bots + 1, obsidian_bots, geode_bots}

    work(mx, bots, reserve, costs, t - t_needed)
  end

  def do_work(mx, :ore, bots, reserve, costs, t) do
    {ore_bots, clay_bots, obsidian_bots, geode_bots} = bots
    {ore_reserve, clay_reserve, obsidian_reserve, geode_reserve} = reserve
    %{ore: %{ore: ore_cost}} = costs

    t_needed =
      0
      |> max(div(ore_cost - ore_reserve + ore_bots - 1, ore_bots))
      |> Kernel.+(1)

    reserve = {
      ore_reserve + t_needed * ore_bots - ore_cost,
      clay_reserve + t_needed * clay_bots,
      obsidian_reserve + t_needed * obsidian_bots,
      geode_reserve + t_needed * geode_bots
    }

    bots = {ore_bots + 1, clay_bots, obsidian_bots, geode_bots}

    work(mx, bots, reserve, costs, t - t_needed)
  end
end
