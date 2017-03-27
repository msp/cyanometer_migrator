defmodule Migrator.CLI do

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up migrating an S3 bucket
  """

  @default_count 4


  def main(argv) do
      argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns   `:help`.

  Otherwise it is a s3 bucket name, and (optionally)
  the number of entries work with (default all)

  Return a tuple of `{ bucket, count }`, or `nil` if help was given.
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do

    { [ help: true ], _,             _ } -> :help
    { _, [ bucket, count ], _          } -> { bucket, String.to_integer(count) }
    { _, [ bucket ],                 _ } -> { bucket, @default_count }
    _                                    -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage:  cyanometer_migrator <bucket> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({bucket, count}) do
    # Migrator.S3.fetch(bucket)
  end
end