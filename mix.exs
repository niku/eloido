defmodule Eloido.Mixfile do
  use Mix.Project

  def project do
    [app: :eloido,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,
                    :httpoison,
                    :timex,
                    :extwitter,
                    :cowboy,
                    :plug],
     mod: {Eloido, []}]
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
    [{:extwitter, github: "parroty/extwitter"},
     {:httpoison, ">= 0.9.0"},
     {:timex, ">= 3.0.0"},
     {:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:socket, github: "meh/elixir-socket"},
     {:credo, "~> 0.5", only: [:dev, :test]}]
  end

  defp aliases do
    ["test": ["credo", "test"]]
  end
end
