defmodule Eloido.Mixfile do
  use Mix.Project

  def project do
    [app: :eloido,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Eloido.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.14", only: [:dev, :test], runtime: false},
     {:credo, "~> 0.7", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
     {:cowboy, "~> 1.0"},
     {:plug, "~> 1.0"}]
  end

  defp description do
    "TODO: Add description"
  end

  defp package do
    [maintainers: ["niku"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/niku/eloido"}]
  end
end
