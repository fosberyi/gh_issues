defmodule GhIssues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to the various that end up
  generating a table of the last __n__ issues in a GitHub project.
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ], aliases: [ h: :help ])
    case parse do
      { [help: true], _, _ } -> :help
      { _, [user, project, count], _ } -> { user, project, String.to_integer(count) }
      { _, [user, project], _ } -> { user, project, @default_count }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
      usage: gh_issues <user> <project> [count | #{@default_count}]
    """
  end

  def process({user, project, _count}) do
    GhIssues.GitHub.fetch(user, project)
    |> decode_response
    |> convert_to_list_of_maps
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from GitHub: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_maps(list) do
    list
    |> Enum.map(&Enum.into(&1, Map.new))
  end

  def sort_by_acending(list_of_issues) do
    Enum.sort(
      list_of_issues,
      fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
    )
  end
end
