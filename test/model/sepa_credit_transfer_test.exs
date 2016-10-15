defmodule FinTex.Model.SEPACreditTransferTest do
  alias FinTex.Model.Account
  alias FinTex.Model.SEPACreditTransfer
  use ExUnit.Case


  test "it should produce an XML document" do
    expected = [System.cwd!, "test", "fixtures", "sepa_credit_transfer.xml"]
    |> Path.join
    |> File.stream!([:read])
    |> Enum.join
    |> String.replace("\n", "")
    |> String.replace("\t", "")

    actual = %SEPACreditTransfer{
      sender_account: %Account{
        iban:  "AT611904300234573201",
        bic:   "AASFFRP1",
        owner: "John Doe"
      },
      recipient_account: %Account{
        iban:  "AT611904300234573201",
        bic:   "AASFFRP1",
        owner: "Jane Doe"
      },
      amount: 1.00,
      currency: "EUR",
      purpose: "Purpose",
      tan_scheme: %{
        sec_func: "999"
      }
    }
    |> SEPACreditTransfer.to_sepa_pain_message("urn:iso:std:iso:20022:tech:xsd:pain.001.003.03",
      1475532464 |> DateTime.from_unix!)

    assert expected === actual
  end
end
