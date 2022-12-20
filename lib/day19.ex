defmodule Day19 do
  def parse do
    File.read!("input/input19t.txt")
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
    3466

  """
  def part1 do
    blueprints = parse()

    5..10
    |> Enum.take_while(
      &max_geode(
        hd(blueprints),
        24,
        %{ore: 1, clay: 0, obsidian: 0},
        %{
          ore: 0,
          clay: 0,
          obsidian: 0
        },
        &1
      )
    )
  end

  def max_geode(blueprint, time_left, robots, resources, geodes_to_crack) do
    gathered = gather_resources(robots, resources)
    # IO.inspect(resources)

    geodes_to_crack <= 0 ||
      (time_left > 0 &&
         geodes_to_crack < div(time_left * (time_left + 1), 2) &&
         (maybe_build_geode_robot(blueprint, time_left, robots, gathered, geodes_to_crack) ||
            maybe_build_obsidian_robot(
              blueprint,
              time_left,
              robots,
              gathered,
              geodes_to_crack
            ) ||
            maybe_build_clay_robot(
              blueprint,
              time_left,
              robots,
              gathered,
              geodes_to_crack
            ) ||
            maybe_build_ore_robot(blueprint, time_left, robots, gathered, geodes_to_crack) ||
            max_geode(blueprint, time_left - 1, robots, gathered, geodes_to_crack)))
  end

  def gather_resources(robots, resources) do
    for {k, v} <- robots, reduce: resources do
      r -> update_in(r, [k], &(&1 + v))
    end
  end

  def maybe_build_ore_robot(blueprint, time_left, robots, resources, geodes_to_crack) do
    if resources.ore >= blueprint.ore.ore and robots.ore < blueprint.max_ore and time_left > 5 do
      max_geode(
        blueprint,
        time_left - 1,
        update_in(robots.ore, &(&1 + 1)),
        update_in(resources.ore, &(&1 - blueprint.ore.ore)),
        geodes_to_crack
      )
    end
  end

  def maybe_build_clay_robot(blueprint, time_left, robots, resources, geodes_to_crack) do
    if resources.ore >= blueprint.clay.ore and robots.clay < blueprint.obsidian.clay and
         time_left > 3 do
      max_geode(
        blueprint,
        time_left - 1,
        update_in(robots.clay, &(&1 + 1)),
        update_in(resources.ore, &(&1 - blueprint.clay.ore)),
        geodes_to_crack
      )
    end
  end

  def maybe_build_obsidian_robot(blueprint, time_left, robots, resources, geodes_to_crack) do
    if resources.ore >= blueprint.obsidian.ore and resources.clay >= blueprint.obsidian.clay and
         robots.obsidian < blueprint.geode.obsidian and time_left > 3 do
      max_geode(
        blueprint,
        time_left - 1,
        update_in(robots.obsidian, &(&1 + 1)),
        update_in(resources.ore, &(&1 - blueprint.obsidian.ore))
        |> update_in([:clay], &(&1 - blueprint.obsidian.clay)),
        geodes_to_crack
      )
    end
  end

  def maybe_build_geode_robot(blueprint, time_left, robots, resources, geodes_to_crack) do
    if resources.ore >= blueprint.geode.ore and resources.obsidian >= blueprint.geode.obsidian do
      max_geode(
        blueprint,
        time_left - 1,
        robots,
        update_in(resources.ore, &(&1 - blueprint.geode.ore))
        |> update_in([:obsidian], &(&1 - blueprint.geode.obsidian)),
        geodes_to_crack - time_left + 1
      )
    end
  end

  @doc """
  Part2

  ## Examples

    iex> Day19.part2()
    nil

  """
  def part2 do
  end
end
