defmodule FuzzyDocSearch.MixProject do
  use Mix.Project

  def project do
    [
      app: :fuzzy_doc_search,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    []
  end
end
