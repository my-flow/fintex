defmodule FinTex.Segment.HNHBK do
  @moduledoc false

  alias FinTex.Helper.Conversion
  alias FinTex.Model.Dialog

  defstruct [segment: nil]

  def new(s, d = %Dialog{}) do
    %{
      bank:       bank,
      dialog_id:  dialog_id,
      message_no: message_no
    } = d

    %__MODULE__{s |
      segment:
        [
          ["HNHBK", "?", 3],
          "$SIZE",
          bank.version,
          dialog_id,
          message_no
        ]
    }
  end


  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment:
        segment
        |> List.update_at(1, &Conversion.to_digit/1)
        |> List.update_at(2, &Conversion.to_number/1)
        |> List.update_at(3, &Conversion.to_id/1)
        |> List.update_at(4, &Conversion.to_number/1)
        |> List.update_at(5, &to_reference_message/1)
      }
  end


  defp to_reference_message(group) when is_list(group) do
    group
    |> List.update_at(0, &Conversion.to_id/1)
    |> List.update_at(1, &Conversion.to_number/1)
  end

end


defimpl Inspect, for: FinTex.Segment.HNHBK do
  use FinTex.Helper.Inspect
end
