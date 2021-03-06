defmodule CyanometerMigrator.Mixfile do
  use Mix.Project

  def project do
    [app: :cyanometer_migrator,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ex_aws, :sweet_xml, :hackney]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_aws, "~> 1.1"},
      {:poison, "~> 2.0"},
      {:sweet_xml, "~> 0.6.5"},
      {:hackney, "~> 1.7"},
      {:mix_test_watch, "~> 0.3", only: :dev},
      {:ex_unit_notifier, "~> 0.1", only: :test}
    ]
  end
end
