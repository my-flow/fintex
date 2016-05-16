defmodule FinTex.Segment.HKTAN do
  @moduledoc false

  defstruct [:v, :process, :ref, medium_name: nil, segment: nil]

  def new(s = %__MODULE__{v: 2, process: 2, ref: ref}, _) do
    %__MODULE__{s |
      segment:
        [
          ["HKTAN", "?", 2],
          2,
          "",
          ref,
          "",
          "N"
        ]
    }
  end


  def new(s = %__MODULE__{v: 3, process: 2, ref: ref}, _) do
    %__MODULE__{s |
      segment:
        [
          ["HKTAN", "?", 3],
          2,
          "",
          ref,
          "",
          "N"
        ]
    }
  end


  def new(s = %__MODULE__{v: 5, process: 2, ref: ref}, _) do
    %__MODULE__{s |
      segment:
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
    }
  end


  def new(s = %__MODULE__{v: 3, process: 4, medium_name: medium_name}, _) do
    %__MODULE__{s |
      segment:
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
    }
  end


  def new(s = %__MODULE__{v: 4, process: 4, medium_name: medium_name}, _) do
    %__MODULE__{s |
      segment:
        [
          ["HKTAN", "?", 4],
          4,
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          medium_name
        ]
    }
  end


  def new(s = %__MODULE__{v: 5, process: 4, medium_name: medium_name}, _) do
    %__MODULE__{s |
      segment:
        [
          ["HKTAN", "?", 5],
          4,
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          medium_name
        ]
    }
  end


  def new(s = %__MODULE__{v: v, process: 4, ref: nil}, _) do
    %__MODULE__{s |
      segment:
        [
          ["HKTAN", "?", v],
          4
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HKTAN do
  use FinTex.Helper.Inspect
end
