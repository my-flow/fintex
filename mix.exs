defmodule Fintex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fintex,
      version: "0.0.1",
      name: "FinTex",
      source_url: "https://github.com/my-flow/fintex",
      homepage_url: "http://hexdocs.pm/fintex",
      elixir: "~> 1.1",
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
      {:ex_doc,                "~> 0.10.0",  override: true},
      {:exactor,               "~> 2.2.0"},
      {:excoveralls,           "~> 0.4.2", only: [:dev, :test]},
      {:httpotion,             "~> 2.1.0"},
      {:ibrowse,            tag: "v4.2",    github: "cmullaparthi/ibrowse"},
      {:inch_ex,               "~> 0.4.0",  only: :docs},
      {:luhn,               tag: "0.4.0",   github: "my-flow/luhn_ex"},
      {:mt940,                 "~> 0.3.3"},
      {:ssl_verify_hostname,   "<= 1.0.5"},
      {:timex,                 "~> 1.0.0-rc2"},
      {:vex,                   "~> 0.5.4"},
      {:xml_builder,   commit: "1e381db0b7d289ee18c2f7fd682d8e47215a141c", github: "joshnuss/xml_builder"}
    ]
  end


  defp description do
    """
    HBCI/FinTS client library for Elixir.
    """
  end


  defp package do
    [
      files:        ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      contributors: ["Florian J. Breunig"],
      licenses:     ["MIT"],
      links:        %{"GitHub" => "https://github.com/my-flow/fintex"}
    ]
  end
end
