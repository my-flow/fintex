defmodule FinTex.Model.ResponseTest do
  alias FinTex.Model.Response
  use ExUnit.Case


  setup do
    raw = [
      [["HNHBK", 1, 3], "2"],
      [["HNVSK", 998, 3], ["PIN", 1]],
      [["HNVSD", 999, 1]],
      [["HIRMS", 5, 2, 7]],
      [["HIRMS", 6, 2, 9]],
      [["HIRMS", 4, 2, 8]],
      [["HNHBS", 5, 1], "2"]
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
