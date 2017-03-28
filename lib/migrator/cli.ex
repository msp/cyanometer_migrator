defmodule Migrator.CLI do

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up migrating an S3 bucket
  """

  @default_count 4
  @country "Solvenia"
  @city "Ljubljana"
  @location "Central Square"

  def main(argv) do
      argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns   `:help`.

  Otherwise it is a, s3 source / target bucket name, and (optionally)
  the number of entries work with (default all)

  Return a tuple of `{ source_bucket, target_bucket, count }`, or `nil` if help was given.
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do

    { [ help: true ], _,                            _ } -> :help
    { _, [ source_bucket, target_bucket, count ], _   } -> { source_bucket, target_bucket, String.to_integer(count) }
    { _, [ source_bucket, target_bucket ],          _ } -> { source_bucket, target_bucket, @default_count }
    _                                                   -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage:  cyanometer_migrator <source_bucket> <target_bucket> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({source_bucket, target_bucket, count}) do
    Migrator.S3.fetch(source_bucket)
      |> Enum.map(fn (object) ->
         Migrator.S3.copy(source_bucket, object.key,
                          target_bucket, Migrator.S3.namespace(@country, @city, @location, object.key))
      end)
  end
end
