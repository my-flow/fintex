defmodule FinTex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fintex,
      version: "0.2.0",
      name: "FinTex",
      source_url: "https://github.com/my-flow/fintex",
      homepage_url: "http://hexdocs.pm/fintex",
      elixir: "~> 1.2.0-rc.0",
      description: description,
      package: package,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
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
        :ssl_verify_hostname,
        :timex
      ]
    ]
  end


  defp deps do
    [
      {:decimal,               "~> 1.1.0"},
      {:earmark,               "~> 0.1.19"},
      {:ex_doc,                "~> 0.11.2", only: :dev},
      {:exactor,               "~> 2.2.0"},
      {:excoveralls,           "~> 0.4.3",  only: [:dev, :test]},
      {:httpotion,             "~> 2.1.0"},
      {:ibrowse,               "~> 4.2.2"},
      {:inch_ex,               "~> 0.4.0",  only: [:dev, :docs]},
      {:luhn,                tag: "0.4.0",  github: "my-flow/luhn_ex"},
      {:mt940,                 "~> 0.4.0"},
      {:ssl_verify_hostname,   "<= 1.0.6", manager: :rebar},
      {:timex,                 "~> 0.19.5"},
      {:vex,                   "~> 0.5.4"},
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
