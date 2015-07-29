defmodule FinTex.Segment.HKTAN do
  @moduledoc false

  defstruct [:v, :process, :ref, medium_name: nil]

  def create(%__MODULE__{v: 2, process: 2, ref: ref}, _) do
    [
      ["HKTAN", "?", 2],
      2,
      "",
      ref,
      "",
      "N"
    ]
  end


  def create(%__MODULE__{v: 3, process: 2, ref: ref}, _) do
    [
      ["HKTAN", "?", 3],
      2,
      "",
      ref,
      "",
      "N"
    ]
  end


  def create(%__MODULE__{v: 5, process: 2, ref: ref}, _) do
    [
      ["HKTAN", "?", 5],
      2,
      "",
      "",
      "",
      ref,
      "",
      "N"
    ]
  end


  def create(%__MODULE__{v: 3, process: 4, medium_name: medium_name}, _) do
    [
      ["HKTAN", "?", 3],
      4,
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      medium_name
    ]
  end


  def create(%__MODULE__{v: v, process: 4, ref: nil}, _) do
    [
      ["HKTAN", "?", v],
      4
    ]
  end
end
