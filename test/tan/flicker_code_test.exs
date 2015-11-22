defmodule FinTex.Tan.FlickerCodeTest do
  @moduledoc """
    [Based on real-life challenges](https://github.com/willuhn/hbci4java/blob/master/test/hbci4java/secmech/FlickerTest.java)
  """

  alias FinTex.Tan.FlickerCode
  alias FinTex.Tan.StartCode
  alias FinTex.Tan.DataElement

  use ExUnit.Case
  use FinTex

  test "it should render a challenge in HHD 1.4" do
    f = FlickerCode.new("039870110490631098765432100812345678041,00")
    assert "1784011049063F059876543210041234567844312C303019" == FlickerCode.render(f)
  end

  
  test "it should render another challenge in HHD 1.4" do
    f = FlickerCode.new("039870110418751012345678900812030000040,20")
    assert "1784011041875F051234567890041203000044302C323015" == FlickerCode.render(f)
  end


  test "it should render a sample challenge from the HHD 1.4 specification" do
    f = FlickerCode.new("0248A0120452019980812345678")
    assert "0D85012045201998041234567855" == FlickerCode.render(f)
  end
  

  # see http://www.onlinebanking-forum.de/phpBB2/viewtopic.php?p=60532
  test "it should clean and render an inline challenge in HHD 1.3" do
    f = FlickerCode.new("...TAN-Nummer: CHLGUC 002624088715131306389726041,00CHLGTEXT0244 Sie h...")
    assert "0F04871513130338972614312C30303B" == FlickerCode.render(f)
  end


  test "it should render an HHD 1.4 challenge containing an alphanumeric data element" do
    f = FlickerCode.new("0248A01204520199808123F5678")
    assert "118501204520199848313233463536373875" == FlickerCode.render(f)
  end
  

  test "it should calculate the luhn checksum to be zero" do
    f = %FlickerCode{
      start_code: %StartCode{control_bytes: [1], data: "1120492", lde: 0, length: 0, version: :hhd14},
      data_elements: [
        %DataElement{data: "30084403", lde: 0, length: 0},
        %DataElement{data: "450,00", lde: 0, length: 0},
        %DataElement{data: "2", lde: 0, length: 0}
      ],
      lc: 0
    }
    assert "1584011120492F0430084403463435302C3030012F05" == FlickerCode.render(f)
  end


  test "it should render an HHD 1.3 challenge (Postbank)" do
    f = FlickerCode.new("190277071234567041,00")
    expected = %FlickerCode{
      start_code: %StartCode{control_bytes: [], data: "77", lde: 2, length: 2, version: :hhd13},
      data_elements: [
        %DataElement{data: "1234567", lde: 7, length: 7},
        %DataElement{data: "1,00", lde: 4, length: 4},
        %DataElement{}
      ],
      lc: 19
    }
    assert expected == f
  end


  test "it should render an HHD 1.3 challenge after reading control bytes" do
    f = FlickerCode.new("250891715637071234567041,00")
    assert :hhd13 == f.start_code.version
    assert 0 == Enum.count(f.start_code.control_bytes)
  end


  test "it should fail gracefully" do
    f = FlickerCode.new("CHLGTEXT0588Sie haben eine \"Einzelüberweisung\" an die Empfänger-IBAN")
    assert :error == f
  end
end
