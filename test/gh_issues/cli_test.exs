defmodule GhIssues.CLITest do
  use ExUnit.Case
  doctest GhIssues

  import GhIssues.CLI, only: [parse_args: 1]

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
end

