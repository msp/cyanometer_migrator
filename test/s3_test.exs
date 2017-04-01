defmodule S3Test do

  @moduledoc """
  Test using the fake3 Ruby gem to do local, stubbed interaction: https://github.com/jubos/fake-s3
  """

  use ExUnit.Case

  require Logger

  @test_s3_domain "s3.eu-central-1.amazonaws.com"
  @test_source_bucket "fakes3-test-source-bucket"
  @test_target_bucket "fakes3-test-target-bucket"

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
      |> Enum.each(&put_source_object/1)

    on_exit fn ->
      if @cleanup do
        IO.puts "Cleaning up..."
        items = ExAws.S3.list_objects(@test_source_bucket)
          |> ExAws.request!

        Enum.each(items.body.contents, fn (item) -> delete_source_object(item) end)

        items = ExAws.S3.list_objects(@test_target_bucket)
          |> ExAws.request!

        Enum.each(items.body.contents, fn (item) -> delete_target_object(item) end)

        ExAws.S3.delete_bucket(@test_source_bucket) |> ExAws.request
        ExAws.S3.delete_bucket(@test_target_bucket) |> ExAws.request
      end
    end

    # No metadata
    :ok
  end


  test "fetch returns all objects" do
    items = Migrator.S3.fetch(@test_source_bucket)

    @test_images
      |> Enum.sort
      |> Enum.with_index
      |> Enum.map(fn {image, index} ->
          assert(image == (Enum.at(items, index)).key)
         end)
  end


  test "namespace_url" do
    scheme = "https"
    s3_object = "sky-01.01.2017-08_00_00-small.jpg"
    fullpath = "#{scheme}://#{@test_s3_domain}/#{@test_source_bucket}/#{s3_object}"

    result = Migrator.S3.namespace_url(@test_source_bucket, @test_target_bucket, @country, @city, @location, fullpath)
    assert(result == "#{scheme}://#{@test_s3_domain}/#{@test_target_bucket}/test/#{@country}/#{@city}/Central-Square/2017/01/01/#{s3_object}")

    scheme = "http"
    fullpath = "#{scheme}://#{@test_s3_domain}/#{@test_source_bucket}/#{s3_object}"

    result = Migrator.S3.namespace_url(@test_source_bucket, @test_target_bucket, @country, @city, @location, fullpath)
    assert(result == "#{scheme}://#{@test_s3_domain}/#{@test_target_bucket}/test/#{@country}/#{@city}/Central-Square/2017/01/01/#{s3_object}")
  end

  test "namespace_s3_object: expected format" do
    result = Migrator.S3.namespace_s3_object(@country, @city, @location, "sky-01.01.2017-08_00_00-small")
    assert(result == "test/#{@country}/#{@city}/Central-Square/2017/01/01/sky-01.01.2017-08_00_00-small")

    result = Migrator.S3.namespace_s3_object(@country, @city, @location, "sky-31.12.2016-08_00_00-small")
    assert(result == "test/#{@country}/#{@city}/Central-Square/2016/12/31/sky-31.12.2016-08_00_00-small")
  end

  test "namespace_s3_object: unexpected format" do
    result = Migrator.S3.namespace_s3_object(@country, @city, @location, "ignore_warning_testing_unexpected_key_format")
    assert(result == "")
  end

  test "copy" do
    @test_images
      |> Enum.map(fn (image) ->
         Migrator.S3.copy(@test_source_bucket, image,
                          @test_target_bucket, Migrator.S3.namespace_s3_object(@country, @city, @location, image))
      end)

    @test_images
      |> Enum.map(fn (image) ->
        get_object_result =
          ExAws.S3.get_object(@test_target_bucket, Migrator.S3.namespace_s3_object(@country, @city, @location, image))
            |> ExAws.request!

        assert(@status_code_success == get_object_result.status_code)
      end)

    assert_raise ExAws.Error, fn ->
      Enum.concat(@test_images, ["sky-31.12.2016-08_00_00-small-DOES_NOT_EXIST"])
        |> Enum.map(fn (image) ->
          get_object_result =
            ExAws.S3.get_object(@test_target_bucket, Migrator.S3.namespace_s3_object(@country, @city, @location, image))
              |> ExAws.request!

          assert(@status_code_success == get_object_result.status_code)
        end)
    end
  end

  defp delete_source_object(obj) do
    ExAws.S3.delete_object(@test_source_bucket, obj.key)
      |> ExAws.request!
  end

  defp delete_target_object(obj) do
    ExAws.S3.delete_object(@test_target_bucket, obj.key)
      |> ExAws.request!
  end

  defp put_source_object(obj) do
    ExAws.S3.put_object(@test_source_bucket, obj, @test_binary_content)
      |> ExAws.request!
  end
end
