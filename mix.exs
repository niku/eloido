defmodule Eloido.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eloido,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Eloido.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.16", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:hobot, "~> 0.2", github: "niku/hobot"},
      {:hobot_plugin_adapter_twitter_streaming, "~> 0.1", github: "niku/hobot_plugin_adapter_twitter_streaming"},
      {:hobot_plugin_handler_idobata_webhook, "~> 0.1", github: "niku/hobot_plugin_handler_idobata_webhook"}
    ]
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
