# Cyanometer Migrator

Migrate a collection of images to be namespaced by city and date.
Our current S3 bucket is just a single big list.
We also need to update paths in our web app DB via the API.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `cyanometer_migrator` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:cyanometer_migrator, "~> 0.1.0"}]
    end
    ```

  2. Ensure `cyanometer_migrator` is started before your application:

    ```elixir
    def application do
      [applications: [:cyanometer_migrator]]
    end
    ```

## TDD

Requires a local, fake S3 backend to be running using: https://github.com/jubos/fake-s3

```bash
# start the fake S3 server
$ fakes3 -r ~/fakes3_root -p 4567

$ export AWS_ACCESS_KEY_ID=123 AWS_SECRET_ACCESS_KEY=asdf && mix test.watch
```
