defmodule FinTex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fintex,
      version: "0.3.0",
      name: "FinTex",
      source_url: "https://github.com/my-flow/fintex",
      homepage_url: "http://hexdocs.pm/fintex",
      elixir: "~> 1.3",
      description: description(),
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [plt_add_deps: true],
      test_coverage: [tool: ExCoveralls]
    ]
  end


  def application do
    [
      applications: [
        :exactor,
        :httpotion,
        :ibrowse,
        :logger,
        :ssl_verify_fun,
        :timex,
        :xml_builder
      ]
    ]
  end


  defp deps do
    [
      {:bankster,              "~> 0.2.2"},
      {:credo,                 "~> 0.4.7",  only: [:dev, :test]},
      {:decimal,               "~> 1.1.2"},
      {:earmark,               "~> 1.0.1",  only: :dev, override: true},
      {:ex_doc,                "~> 0.13.0", only: :dev},
      {:exactor,               "~> 2.2.1"},
      {:excoveralls,           "~> 0.5.5",  only: :test},
      {:httpotion,             "~> 3.0.0"},
      {:ibrowse,               "~> 4.2.2"},
      {:inch_ex,               "~> 0.5.3",  only: [:dev, :docs]},
      {:luhnatex,              "~> 0.5.1"},
      {:mt940,                 "~> 1.1.0"},
      {:ssl_verify_fun,        "~> 1.1.0"},
      {:timex,                 "~> 3.0.4"},
      {:vex,                   "~> 0.5.5"},
      {:xml_builder,           "~> 0.0.8"}
    ]
  end


  defp description do
    """
    HBCI/FinTS client library for Elixir.
    """
  end


  defp package do
    [
      files:       ["lib", "priv", "mix.exs", "README*", "LICENSE*",],
      maintainers: ["Florian J. Breunig"],
      licenses:    ["MIT"],
      links:       %{"GitHub" => "https://github.com/my-flow/fintex"}
    ]
  end
end
