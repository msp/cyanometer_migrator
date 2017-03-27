defmodule Migrator.S3 do
  require Logger

  def fetch(bucket) do
    Logger.info "Fetching bucket called: #{bucket}"
    {ok, result} = ExAws.S3.list_objects(bucket) |> ExAws.request

    result.body.contents
  end

  def copy(source_bucket, source_object, target_bucket, target_object) do
    Logger.info "Copying [#{source_bucket}]//#{source_object} to [#{target_bucket}]//#{target_object}"
    ExAws.S3.put_object_copy(target_bucket, target_object, source_bucket, source_object)
      |> ExAws.request!
  end

  def namespace(country, city, location, object) do
    String.split(object, "-")
      |> Enum.at(1)
      |> String.split(".")
      |> datespace(country, city, location, object)
  end

  defp datespace(d, country, city, location, obj) do
    {day, month, year} = {Enum.at(d, 0), Enum.at(d, 1), Enum.at(d, 2)}
    "#{country}/#{city}/#{location}/#{year}/#{month}/#{day}/#{obj}"
  end
end
