defmodule CliTest do
  use ExUnit.Case

  import Migrator.CLI, only: [ parse_args: 1 ]

  test "nil returned by option parsing with -h and --help options" do
    assert parse_args(["-h",     "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "two values returned if two given" do
    assert parse_args(["our_bucket", "99"]) == { "our_bucket", 99 }
  end

  test "count is defaulted if single value given" do
    assert parse_args(["our_bucket"]) == { "our_bucket", 4 }
  end
end
