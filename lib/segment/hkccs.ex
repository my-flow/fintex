defmodule FinTex.Segment.HKCCS do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Model.Dialog
  alias FinTex.Parser.Lexer
  alias FinTex.User.FinAccount
  alias FinTex.User.FinPayment

  use AbstractCommand

  @supported_sepa_descriptor_urns [
    "urn:iso:std:iso:20022:tech:xsd:pain.001.003.03.xsd",
    "urn:iso:std:iso:20022:tech:xsd:pain.001.002.03.xsd"
  ]

  defstruct [:payment, segment: nil]

  def new(
    %__MODULE__{
      payment: %FinPayment{
        sender_account: %FinAccount{
          iban:  sender_iban,
          bic:   sender_bic
        }
      } = payment
    },
    %Dialog{bpd: bpd}) do

    ktv = [sender_iban, sender_bic]


    available_sepa_descriptor_urns = bpd
    |> Map.get("HKSPA" |> control_structure_to_bpd)
    |> Enum.at(0)
    |> Enum.at(-1)
    |> Enum.at(-1)
    |> Enum.map(fn urn -> urn |> String.split(":") |> Enum.at(-1) end)

    sepa_descriptor_urn = @supported_sepa_descriptor_urns
    |> Enum.find(fn urn -> available_sepa_descriptor_urns |> Enum.any?(fn s -> String.contains?(urn, s) end) end)

    unless sepa_descriptor_urn do
      raise FinTex.Error, reason:
        "could not find any supported descriptor URN: #{inspect available_sepa_descriptor_urns}"
    end

    sepa_descriptor = ~r/\.xsd$/
    |> Regex.replace(sepa_descriptor_urn, "")

    sepa_pain_message = payment
    |> FinPayment.to_sepa_pain_message(sepa_descriptor)
    |> Lexer.encode_binary

    %__MODULE__{
      segment:
        [
          ["HKCCS", "?", 1],
          ktv,
          sepa_descriptor,
          sepa_pain_message
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HKCCS do
  use FinTex.Helper.Inspect
end
