defmodule FinTex.Model.ResponseTest do
  alias FinTex.Model.Response
  alias FinTex.Segment.HIRMS
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNVSD
  alias FinTex.Segment.HNVSK
  use ExUnit.Case


  setup do
    raw = [
      %HNHBK{segment: [["HNHBK", 1, 3], "2"]},
      %HNVSK{segment: [["HNVSK", 998, 3], ["PIN", 1]]},
      %HNVSD{segment: [["HNVSD", 999, 1]]},
      %HIRMS{segment: [["HIRMS", 5, 2, 7]]},
      %HIRMS{segment: [["HIRMS", 6, 2, 9]]},
      %HIRMS{segment: [["HIRMS", 4, 2, 8]]},
      %HNHBS{segment: [["HNHBS", 5, 1], "2"]}
    ]
    {:ok, response: Response.new(raw)}
  end


  test "it should create a new struct", context do
    assert context[:response]
  end


  test "it should contain all segments", context do
    assert 1 == context[:response][:HNHBK] |> Enum.count
    assert 1 == context[:response][:HNVSK] |> Enum.count
    assert 1 == context[:response][:HNVSD] |> Enum.count
    assert 3 == context[:response][:HIRMS] |> Enum.count
    assert 1 == context[:response][:HNHBS] |> Enum.count
  end


  test "it should not contain unknown segments", context do
    assert 0 == context[:response][:unknown] |> Enum.count
    assert {:ok, []} == context[:response] |> Response.fetch(:unknown)
  end


  test "it should contain segments by reference", context do
    assert 1 == context[:response][7] |> Enum.count
    assert 1 == context[:response][8] |> Enum.count
  end


  test "it should order the segments", context do
    assert [["HIRMS", 4, 2, 8]] == context[:response][:HIRMS] |> Enum.at(0)
    assert [["HIRMS", 5, 2, 7]] == context[:response][:HIRMS] |> Enum.at(1)
    assert [["HIRMS", 6, 2, 9]] == context[:response][:HIRMS] |> Enum.at(2)
  end
end
