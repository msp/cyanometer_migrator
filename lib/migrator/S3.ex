defmodule Migrator.S3 do
  require Logger

  def fetch(bucket) do
    Logger.info "Fetching bucket called: #{bucket}"
    {ok, result} = ExAws.S3.list_objects(bucket) |> ExAws.request
    Logger.info "Found: #{ok}: #{Enum.count(result.body.contents)}"

    result.body.contents
  end

  def copy(source_bucket, source_object, target_bucket, target_object) do
    Logger.info "Copying [#{source_bucket}]//#{source_object} to [#{target_bucket}]//#{target_object}"
    ExAws.S3.put_object_copy(target_bucket, target_object, source_bucket, source_object)
      |> ExAws.request!
  end


  def namespace_url(source_bucket, target_bucket, country, city, location, url) do
    uri = URI.parse(url)

    s3_object =
      uri.path
      |> String.replace("/#{source_bucket}/", "")

    "#{uri.scheme}://#{uri.host}/#{target_bucket}/#{namespace_s3_object(country, city, location, s3_object)}"
  end

  def namespace_s3_object(country, city, location, object) do
    case String.contains?(object, "-") do
      true ->
        String.split(object, "-")
          |> Enum.at(1)
          |> String.split(".")
          |> namespaced_string(country, city, location, object)
      false ->
        Logger.warn "Skipping S3 key: #{inspect object}"
        ""
    end
  end

  defp namespaced_string(d, country, city, location, obj_str) do
    {day, month, year} = {Enum.at(d, 0), Enum.at(d, 1), Enum.at(d, 2)}
    "#{Mix.env}/#{country}/#{city}/#{location}/#{year}/#{month}/#{day}/#{obj_str}"
    |> String.replace(" ", "-")
    |> URI.encode
  end
end
