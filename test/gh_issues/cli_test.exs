defmodule GhIssues.CLITest do
  use ExUnit.Case
  doctest GhIssues

  import GhIssues.CLI, only: [
    parse_args: 1,
    sort_by_acending: 1,
    convert_to_list_of_maps: 1
  ]

  test ":help is returned for -h or --help options" do
    assert parse_args(["-h", "something other arg"]) == :help
    assert parse_args(["--help", "something other arg"]) == :help
  end

  test "3 vals returned when 3 given" do
    assert parse_args(["user", "proj", "99"]) == {"user", "proj", 99}
  end

  test "3 vals returned when 2 given - default num of issues" do
    assert parse_args(["user", "proj"]) == {"user", "proj", 4}
  end

  test "sort_by_acending sorts in the correct order" do
    result = fake_created_list(["a", "c", "b"])
    |> sort_by_acending
    issues = for issue <- result, do: issue["created_at"]
    assert issues == ~w{a b c}
  end

  defp fake_created_list(values) do
    data = for value <- values, do: [{"created_at", value}, {"other", "xxx"}]
    convert_to_list_of_maps data
  end
end
