defmodule FinTex.Segment.HITAN do
  @moduledoc false

  alias FinTex.Model.Challenge
  alias FinTex.Model.TANScheme

  def to_challenge(
    segment = [["HITAN", _, 1 | _] | _],
    %TANScheme{
      name: name,
      label: label,
      format: format
    }) do

    %Challenge{
      title:  name,
      format: format,
      ref:    segment |> Enum.at(3),
      label:  "#{label} #{segment |> Enum.at(4)}"
    }
  end


  def to_challenge(
    segment = [["HITAN", _, 2 | _] | _],
    %TANScheme{
      name: name,
      label: label,
      format: format
    }) do

    %Challenge{
      title:  name,
      format: format,
      ref:    segment |> Enum.at(3),
      label:  "#{label} #{segment |> Enum.at(4)}"
    }
  end


  def to_challenge(
    segment = [["HITAN", _, 3 | _] | _],
    %TANScheme{
      name: name,
      label: label,
      format: format
    }) do

    %Challenge{
      title:  name,
      format: format,
      ref:    segment |> Enum.at(3),
      label:  "#{label} #{segment |> Enum.at(4)}",
      medium: segment |> Enum.at(8)
    }
  end


  def to_challenge(
    segment = [["HITAN", _, 4 | _] | _],
    %TANScheme{
      name: name,
      label: label,
      format: format
    }) do

    %Challenge{
      title:  name,
      format: format,
      ref:    segment |> Enum.at(3),
      label:  "#{label} #{segment |> Enum.at(4)}",
      data:   segment |> Enum.at(5),
      medium: segment |> Enum.at(9)
    }
  end


  def to_challenge(
    segment = [["HITAN", _, 5 | _] | _],
    %TANScheme{
      name: name,
      label: label,
      format: format
    }) do

    %Challenge{
      title:  name,
      format: format,
      ref:    segment |> Enum.at(3),
      label:  "#{label} #{segment |> Enum.at(4)}",
      data:   segment |> Enum.at(5),
      medium: segment |> Enum.at(9)
    }
  end
end
