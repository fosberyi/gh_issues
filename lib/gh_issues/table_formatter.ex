defmodule GhIssues.TableFormatter do
  require Logger

  import Enum, only: [each: 2, map: 2, map_join: 3, max: 1]

  @doc """
  Takes a list of row data, where each row is a Map, and a list of headers.
  Prints a table to STDOUT of the data from each row - identified
  by its header. I.e., each header identifies a column; those columns are
  extracted and printed for the rows.

  The width of each column is calculated so that it fits the longest
  element found in that column.
  """
  def print_table_for_columns(rows, headers) do
    with data_by_columns = split_into_columns(rows, headers),
      column_widths      = widths_of(data_by_columns),
      format             = format_for(column_widths)
    do
      puts_one_line_in_columns(headers, format)
      IO.puts(separator(column_widths))
      puts_in_columns(data_by_columns, format)
    end
  end

  @doc"""
  Takes a list of rows, where each row is a Map of columns.
  Returns a list of lists of the data in each column. The
  `headers` param contains the list of columns to extract.

  ## Example

      iex> list = [Enum.into([{"a", 1},{"b", 2},{"c", 3}], %{}),
      ...> Enum.into([{"a", 4},{"b", 5},{"c", 6}], %{})]
      iex> GhIssues.TableFormatter.split_into_columns(list, ["a", "b", "c"])
      [["1","4"],["2","5"],["3","6"]]

  """
  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  @doc"""
  Return a binary (string) version of our param.

  ## Examples

      iex> GhIssues.TableFormatter.printable("a")
      "a"
      iex> GhIssues.TableFormatter.printable(99)
      "99"

  """
  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  @doc"""
  Takes a list of column data lists and returns a list with the
  max width of each column

  ## Example

      iex> data = [["is3", "thisis7", "1"], ["this5", "four", "1"]]
      iex> GhIssues.TableFormatter.widths_of(data)
      [7,5]

  """
  def widths_of(columns) do
    for column <- columns, do: column |> map(&String.length/1) |> max
  end

  @doc"""
  Return a format string that hard codes the widths of a set of
  columns.

  ## Example

      iex> widths = [5,6,99]
      iex> GhIssues.TableFormatter.format_for(widths)
      "~-5s / ~-6s / ~-99s~n"

  """
  def format_for(column_widths) do
    map_join(column_widths, " / ", fn width -> "~-#{width}s" end) <> "~n"
  end

  @doc"""
  Generate a line with "-+-"s as column dividers to separate the header
  and table content

  ## Example

      iex> widths = [2,3,4]
      iex> GhIssues.TableFormatter.separator(widths)
      "---+-----+-----"

  """
  def separator(column_widths) do map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  @doc"""
  Takes a list of column values, zips them to create Tuples of rows and ouputs
  them according to the regex `format`
  """
  def puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, format))
  end

  def puts_one_line_in_columns(fields, format) do
    :io.format(format, fields)
  end
end
