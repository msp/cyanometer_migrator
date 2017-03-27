defmodule Migrator.S3 do
  require Logger

  def fetch(bucket) do
    Logger.info "Fetching bucket called: #{bucket}"
    ExAws.S3.list_objects(bucket) |> ExAws.request
  end
end
