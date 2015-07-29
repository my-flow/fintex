defmodule Fintex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fintex,
      version: "0.0.1",
      name: "FinTex",
      source_url: "https://github.com/my-flow/fintex",
      homepage_url: "http://my-flow.github.io/fintex",
      elixir: "~> 1.0",
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
      {:earmark,               "~> 0.1", only: :dev},
      {:ex_doc,                "~> 0.7", only: [:dev, :test], override: true},
      {:exactor,               "~> 2.1.0"},
      {:excoveralls,           "~> 0.3", only: [:dev, :test]},
      {:httpotion,             "~> 2.1.0"},
      {:ibrowse,            tag: "v4.1.1", github: "cmullaparthi/ibrowse"},
      {:inch_ex,                 "~> 0.3", only: :docs},
      {:mt940,                 "~> 0.3.0"},
      {:ssl_verify_hostname,   "<= 1.0.3"},
      {:timex,                 "~> 0.13.3"},
      {:xml_builder,   commit: "84c310903af9b80fc54829c88d2c4bc898a65233", github: "joshnuss/xml_builder"}
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
