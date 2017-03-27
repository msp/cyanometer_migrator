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
               "sky-01.04.2017-08_15_00-small",
               "sky-01.04.2017-08_15_00-large",
               "sky-01.08.2017-08_30_00-small",
               "sky-01.08.2017-08_30_00-large",
  ]

  @country "Solvenia"
  @city "Ljubljana"
  @location "Central Square"
  @status_code_success 200
  @cleanup true

  setup_all do
    @test_images
      |> Enum.each(&put_object/1)

    on_exit fn ->
      if @cleanup do
        IO.puts "Cleaning up..."
        items = ExAws.S3.list_objects(@test_bucket)
          |> ExAws.request!

        Enum.each(items.body.contents, fn (item) -> delete_object(item) end)
        ExAws.S3.delete_bucket(@test_bucket) |> ExAws.request
      end
    end

    # No metadata
    :ok
  end


  test "fetch returns all objects" do
    items = Migrator.S3.fetch(@test_bucket)

    @test_images
      |> Enum.sort
      |> Enum.with_index
      |> Enum.map(fn {image, index} ->
          assert(image = (Enum.at(items, index)).key)
         end)
  end

  test "namespace" do
    result = Migrator.S3.namespace(@country, @city, @location, "sky-01.01.2017-08_00_00-small")
    assert(result == "#{@country}/#{@city}/#{@location}/2017/01/01/sky-01.01.2017-08_00_00-small")

    result = Migrator.S3.namespace(@country, @city, @location, "sky-31.12.2016-08_00_00-small")
    assert(result == "#{@country}/#{@city}/#{@location}/2016/12/31/sky-31.12.2016-08_00_00-small")
  end

  test "copy" do
    @test_images
      |> Enum.map(fn (image) ->
         Migrator.S3.copy(@test_bucket, image,
                          @test_bucket, Migrator.S3.namespace(@country, @city, @location, image))
      end)

    @test_images
      |> Enum.map(fn (image) ->
        get_object_result =
          ExAws.S3.get_object(@test_bucket, Migrator.S3.namespace(@country, @city, @location, image))
            |> ExAws.request!

        assert(@status_code_success == get_object_result.status_code)
      end)

    assert_raise ExAws.Error, fn ->
      Enum.concat(@test_images, ["sky-31.12.2016-08_00_00-small-DOES_NOT_EXIST"])
        |> Enum.map(fn (image) ->
          get_object_result =
            ExAws.S3.get_object(@test_bucket, Migrator.S3.namespace(@country, @city, @location, image))
              |> ExAws.request!

          assert(@status_code_success == get_object_result.status_code)
        end)
    end
  end

  defp delete_object(obj) do
    ExAws.S3.delete_object(@test_bucket, obj.key)
      |> ExAws.request!
  end

  defp put_object(obj) do
    ExAws.S3.put_object(@test_bucket, obj, @test_binary_content)
      |> ExAws.request!
  end
end
