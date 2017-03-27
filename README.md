# Cyanometer Migrator

Migrate a collection of images to be name spaced by city and date.
Our current S3 bucket is just a single big list.
We also need to update paths in our web app DB.

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
