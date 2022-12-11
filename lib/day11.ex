defmodule Day11 do
  def parse do
    File.read!("input/input11.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n\n")
    |> Enum.map(&build_money/1)
  end

  def build_money(text) do
    String.split(text, "\n")
    |> Enum.reduce(%{}, &parse_line/2)
  end

  def parse_line("Monkey " <> nr, monkey) do
    Map.put(monkey, :nr, String.to_integer(String.slice(nr, 0, 1)))
  end

  def parse_line("  Starting items: " <> items, monkey) do
    it = String.split(items, ", ") |> Enum.map(&String.to_integer/1)
    Map.put(monkey, :start_items, it)
  end

  def parse_line("  Operation: new = old * old", monkey) do
    monkey
    |> Map.put(:operation, :square)
  end

  def parse_line("  Operation: new = old * " <> nr, monkey) do
    monkey
    |> Map.put(:operation, :mult)
    |> Map.put(:operand, String.to_integer(nr))
  end

  def parse_line("  Operation: new = old + " <> nr, monkey) do
    monkey
    |> Map.put(:operation, :add)
    |> Map.put(:operand, String.to_integer(nr))
  end

  def parse_line("  Test: divisible by " <> nr, monkey) do
    monkey
    |> Map.put(:test_div, String.to_integer(nr))
  end

  def parse_line("    If true: throw to monkey " <> nr, monkey) do
    monkey
    |> Map.put(:true_monkey, String.to_integer(nr))
  end

  def parse_line("    If false: throw to monkey " <> nr, monkey) do
    monkey
    |> Map.put(:false_monkey, String.to_integer(nr))
  end

  def build_initial_state(monkeys) do
    items = Enum.map(monkeys, fn %{nr: nr, start_items: items} -> {nr, items} end) |> Map.new()
    inspect_count = Enum.map(monkeys, fn %{nr: nr} -> {nr, 0} end) |> Map.new()
    divisor = Enum.map(monkeys, &Map.get(&1, :test_div)) |> Enum.product()
    %{items: items, inspect_count: inspect_count, divisor: divisor}
  end

  def play_turn(monkey, %{items: items, inspect_count: inspect_count}) do
    item_count = Enum.count(items[monkey.nr])
    new_inspect_count = Map.update(inspect_count, monkey.nr, item_count, &(&1 + item_count))

    new_items =
      Enum.reduce(items[monkey.nr], items, fn item, items ->
        worry_level =
          case monkey.operation do
            :add -> item + monkey.operand
            :mult -> item * monkey.operand
            :square -> item * item
          end

        bored_level = div(worry_level, 3)

        if rem(bored_level, monkey.test_div) == 0 do
          Map.update!(items, monkey.true_monkey, &[bored_level | &1])
        else
          Map.update!(items, monkey.false_monkey, &[bored_level | &1])
        end
      end)
      |> Map.put(monkey.nr, [])

    %{items: new_items, inspect_count: new_inspect_count}
  end

  def play_round(state, monkeys) do
    Enum.reduce(monkeys, state, &play_turn/2)
  end

  @doc """
  Part1

  ## Examples

    iex> Day11.part1()
    57348

  """
  def part1 do
    monkeys = parse()

    initial_state = build_initial_state(monkeys)

    Enum.reduce(1..20, initial_state, fn _, acc -> play_round(acc, monkeys) end)
    |> Map.get(:inspect_count)
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  @doc """
  Part2

  ## Examples

    iex> Day11.part2()
    14106266886

  """
  def part2 do
    monkeys = parse()

    initial_state = build_initial_state(monkeys)

    Enum.reduce(1..10000, initial_state, fn _, acc -> play_round2(acc, monkeys) end)
    |> Map.get(:inspect_count)
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def play_turn2(monkey, %{items: items, inspect_count: inspect_count, divisor: divisor}) do
    item_count = Enum.count(items[monkey.nr])
    new_inspect_count = Map.update(inspect_count, monkey.nr, item_count, &(&1 + item_count))

    new_items =
      Enum.reduce(items[monkey.nr], items, fn item, items ->
        worry_level =
          case monkey.operation do
            :add -> item + monkey.operand
            :mult -> item * monkey.operand
            :square -> item * item
          end

        bored_level = rem(worry_level, divisor)

        if rem(bored_level, monkey.test_div) == 0 do
          Map.update!(items, monkey.true_monkey, &[bored_level | &1])
        else
          Map.update!(items, monkey.false_monkey, &[bored_level | &1])
        end
      end)
      |> Map.put(monkey.nr, [])

    %{items: new_items, inspect_count: new_inspect_count, divisor: divisor}
  end

  def play_round2(state, monkeys) do
    Enum.reduce(monkeys, state, &play_turn2/2)
  end
end
