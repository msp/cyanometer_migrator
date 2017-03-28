defmodule CliTest do
  use ExUnit.Case

  import Migrator.CLI, only: [ parse_args: 1 ]

  test "nil returned by option parsing with -h and --help options" do
    assert parse_args(["-h",     "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "3 values returned if 3 given" do
    assert parse_args(["source_bucket", "target_bucket", "99"]) == { "source_bucket", "target_bucket", 99 }
  end

  test "count is defaulted if only buckets value given" do
    assert parse_args(["source_bucket", "target_bucket"]) == { "source_bucket", "target_bucket", 4 }
  end
end
