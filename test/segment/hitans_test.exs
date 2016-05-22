defmodule FinTex.Segment.HITANSTest do
  alias FinTex.Connection.HTTPBody
  alias FinTex.Model.Response
  alias FinTex.Segment.HITANS
  alias FinTex.User.FinTANScheme

  use ExUnit.Case
  use FinTex


  test "it should recognize photoTAN" do
    tan_schemes = "HITANS:29:5:4+1+1+1+N:N:0:902:2:MS1.0.0:::photoTAN-Verfahren:6:1:Freigabe durch photoTAN:1:1:N:4:0:N:0:0:N:N:00:0:"
    |> resolve(:HITANS)
    |> Enum.flat_map(&HITANS.to_tan_schemes(&1))

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(0)
    assert "photoTAN-Verfahren" == name
    assert "Freigabe durch photoTAN" == label
    assert :matrix == format
    assert "902" == sec_func
  end


  test "it should recognize iTAN and mobileTAN" do
    tan_schemes = "HITANS:28:2:4+1+1+1+N:N:0:900:2:TechnicalId:iTAN-Verfahren:6:1:Freigabe durch lfd. iTAN-Nr.:3:1:N:4:0:N:N:N:901:2:TechnicalId901:mobileTAN-Verfahren:6:1:Freigabe durch mobileTAN:1:1:N:4:0:N:N:N"
    |> resolve(:HITANS)
    |> Enum.flat_map(&HITANS.to_tan_schemes(&1))

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(0)
    assert "iTAN-Verfahren" == name
    assert "Freigabe durch lfd. iTAN-Nr." == label
    assert :text == format
    assert "900" == sec_func    

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(1)
    assert "mobileTAN-Verfahren" == name
    assert "Freigabe durch mobileTAN" == label
    assert :text == format
    assert "901" == sec_func    
  end


  test "it should recognize iTAN and smsTAN" do
    tan_schemes = "HITANS:138:1:4+2+1+1+J:N:0:0:900:2:iTAN:iTAN:6:1:TAN-Nummer:3:1:J:J:920:2:smsTAN:smsTAN:6:1:TAN-Nummer:3:1:J:J"
    |> resolve(:HITANS)
    |> Enum.flat_map(&HITANS.to_tan_schemes(&1))

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(0)
    assert "iTAN" == name
    assert "TAN-Nummer" == label
    assert :text == format
    assert "900" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(1)
    assert "smsTAN" == name
    assert "TAN-Nummer" == label
    assert :text == format
    assert "920" == sec_func
  end


  test "it should recognize iTAN, smsTAN, chipTAN manuell, chipTAN optisch, and pushTAN" do
    tan_schemes = "HITANS:139:3:4+2+1+1+J:N:0:900:2:iTAN:iTAN:6:1:TAN-Nummer:3:1:J:2:0:N:N:N:00:0:0:920:2:smsTAN:smsTAN:6:1:TAN-Nummer:3:1:J:2:0:N:N:N:00:2:5:910:2:HHD1.3.0:chipTAN manuell:6:1:TAN-Nummer:3:1:J:2:0:N:N:N:00:0:1:911:2:HHD1.3.0OPT:chipTAN optisch:6:1:TAN-Nummer:3:1:J:2:0:N:N:N:00:0:1:921:2:pushTAN:pushTAN:6:1:TAN-Nummer:3:1:J:2:0:N:N:N:00:2:2"
    |> resolve(:HITANS)
    |> Enum.flat_map(&HITANS.to_tan_schemes(&1))

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(0)
    assert "iTAN" == name
    assert "TAN-Nummer" == label
    assert :text == format
    assert "900" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(1)
    assert "smsTAN" == name
    assert "TAN-Nummer" == label
    assert :text == format
    assert "920" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(2)
    assert "chipTAN manuell" == name
    assert "TAN-Nummer" == label
    assert :hhd == format
    assert "910" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(3)
    assert "chipTAN optisch" == name
    assert "TAN-Nummer" == label
    assert :hhd == format
    assert "911" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(4)
    assert "pushTAN" == name
    assert "TAN-Nummer" == label
    assert :text == format
    assert "921" == sec_func
  end


  test "it should recognize sm@rtTAN plus 1.3.1/1.4, mobileTAN" do
    tan_schemes = "HITANS:112:5:4+1+1+1+J:N:0:922:2:SM?@RTTANPLUS2:HHD:1.3.1:Smart-TAN plus:6:1:Challenge:256:1:J:1:0:N:0:2:N:J:00:0:1:932:2:HHD1.3.1:HHD:1.3.1:SmartTAN plus:6:1:Challenge:2048:1:J:1:0:N:0:2:N:J:00:0:1:942:2:MTAN2:mobileTAN::mobile TAN:6:1:SMS:2048:1:J:1:0:N:0:2:N:J:00:1:1:952:2:HHD1.3.2OPT:HHDOPT1:1.3.2:SmartTAN optic:6:1:Challenge:2048:1:J:1:0:N:0:2:N:J:00:1:1:962:2:HHD1.4:HHD:1.4:SmartTAN plus HHD 1.4:6:1:Challenge:2048:1:J:1:0:N:0:2:N:J:00:1:1:972:2:HHD1.4OPT:HHDOPT1:1.4:SmartTAN optic HHD 1.4:6:1:Challenge:2048:1:J:1:0:N:0:2:N:J:00:1:1"
    |> resolve(:HITANS)
    |> Enum.flat_map(&HITANS.to_tan_schemes(&1))

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(0)
    assert "Smart-TAN plus" == name
    assert "Challenge" == label
    assert :hhd == format
    assert "922" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(1)
    assert "SmartTAN plus" == name
    assert "Challenge" == label
    assert :hhd == format
    assert "932" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(2)
    assert "mobile TAN" == name
    assert "SMS" == label
    assert :text == format
    assert "942" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(3)
    assert "SmartTAN optic" == name
    assert "Challenge" == label
    assert :hhd == format
    assert "952" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(4)
    assert "SmartTAN plus HHD 1.4" == name
    assert "Challenge" == label
    assert :hhd == format
    assert "962" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(5)
    assert "SmartTAN optic HHD 1.4" == name
    assert "Challenge" == label
    assert :hhd == format
    assert "972" == sec_func
  end


  test "it should recognize mobileTAN, SecureGo, smartTAN plus HHD 1.4" do
    tan_schemes = "HITANS:57:5:4+1+1+1+J:N:0:942:2:MTAN2:mobileTAN::mobile TAN:6:1:SMS:2048:1:J:1:0:N:0:2:N:J:00:0:1:944:2:SECUREGO:mobileTAN::SecureGo:6:1:TAN:2048:1:J:1:0:N:0:2:N:J:00:0:1:962:2:HHD1.4:HHD:1.4:Smart-TAN plus manuell:6:1:Challenge:2048:1:J:1:0:N:0:2:N:J:00:0:1:972:2:HHD1.4OPT:HHDOPT1:1.4:Smart-TAN plus optisch:6:1:Challenge:2048:1:J:1:0:N:0:2:N:J:00:0:1"
    |> resolve(:HITANS)
    |> Enum.flat_map(&HITANS.to_tan_schemes(&1))

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(0)
    assert "mobile TAN" == name
    assert "SMS" == label
    assert :text == format
    assert "942" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(1)
    assert "SecureGo" == name
    assert "TAN" == label
    assert :text == format
    assert "944" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(2)
    assert "Smart-TAN plus manuell" == name
    assert "Challenge" == label
    assert :hhd == format
    assert "962" == sec_func

    %FinTANScheme{name: name, label: label, format: format, sec_func: sec_func} = tan_schemes |> Enum.at(3)
    assert "Smart-TAN plus optisch" == name
    assert "Challenge" == label
    assert :hhd == format
    assert "972" == sec_func
  end


  defp resolve(raw, key) when is_binary(raw) and is_atom(key) do
    raw
    |> Base.encode64
    |> HTTPBody.decode_body
    |> Response.get(:HITANS)
  end
end
