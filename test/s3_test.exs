defmodule S3Test do

  @moduledoc """
  Test using the fake3 Ruby gem to do local, stubbed interaction: https://github.com/jubos/fake-s3
  """

  use ExUnit.Case

  require Logger

  @test_bucket "fakes3-test-bucket"
  @test_region "fakes3"
  @test_binary_content "some content that is not really binary :/"

  @test_images ["sky-01.01.2017-08_00_00-small",
               "sky-01.01.2017-08_00_00-large",
               "sky-01.01.2017-08_15_00-small",
               "sky-01.01.2017-08_15_00-large",
               "sky-01.01.2017-08_30_00-small",
               "sky-01.01.2017-08_30_00-large",
  ]

  @status_code_success 200

  setup_all do
    @test_images
      |> Enum.each(&put_object/1)

    # Logger.info "SETUP --------------------------------------------------------"
    # IO.inspect ExAws.S3.list_objects(@test_bucket) |> ExAws.request

    on_exit fn ->
      IO.puts "Clearing up..."
      @test_images
        |> Enum.each(&delete_object/1)

      ExAws.S3.delete_bucket(@test_bucket) |> ExAws.request
    end

    # No metadata
    :ok
  end


  test "fetch returns all objects" do
    {ok, result} = Migrator.S3.fetch(@test_bucket)

    @test_images
      |> Enum.sort
      |> Enum.with_index
      # |> Enum.map(fn {image, index} -> IO.puts "#{index}: #{image} : #{(Enum.at(result.body.contents, index)).key}" end)
      |> Enum.map(fn {image, index} -> assert(image = (Enum.at(result.body.contents, index)).key) end)

    assert @status_code_success = result.status_code
  end

  defp delete_object(obj) do
    ExAws.S3.delete_object(@test_bucket, obj)
      |> ExAws.request!
  end

  defp put_object(obj) do
    ExAws.S3.put_object(@test_bucket, obj, @test_binary_content)
      |> ExAws.request!
  end
end
