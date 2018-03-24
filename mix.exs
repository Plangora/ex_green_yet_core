defmodule ExGreenYetCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_green_yet_core,
      version: "0.0.1",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "ExGreenYetCore",
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/Plangora/ex_green_yet_core"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExGreenYetCore, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:mox, "~> 0.3", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Core component used in ExGreenYet for monitoring services and their depending components."
  end

  defp package() do
    [
      # These are the default files included in the package
      maintainers: ["Allen Wyma"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Plangora/ex_green_yet_core"}
    ]
  end
end
