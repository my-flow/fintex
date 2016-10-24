defmodule FinTex.Segment.HITANTest do
  alias FinTex.Parser.Serializer
  alias FinTex.Parser.Tokenizer
  alias FinTex.Parser.TypeConverter
  alias FinTex.Segment.HITAN
  use ExUnit.Case
  use FinTex

  test "it should not split the ref" do
    types = "HITAN:5:5:4+4++564SEOsuAlEBAACYTveGhm?+owAQA+SMS wurde versandt."
    |> Tokenizer.split
    |> TypeConverter.string_to_type

    assert "[[[\"HITAN\", 5, 5, 4], \"4\", nil, \"564SEOsuAlEBAACYTveGhm+owAQA\", \"SMS wurde versandt.\"]]" == types |> inspect
  end


  test "it should escape the ref" do
    types = [%HITAN{segment: [["HITAN", 5, 5, 4], "4", nil, "564SEOsuAlEBAACYTveGhm+owAQA", "SMS wurde versandt."]}]
    |> TypeConverter.type_to_string
    |> Serializer.escape

    assert [[["HITAN", "5", "5", "4"], "4", "", "564SEOsuAlEBAACYTveGhm?+owAQA", "SMS wurde versandt."]] == types
  end
end
