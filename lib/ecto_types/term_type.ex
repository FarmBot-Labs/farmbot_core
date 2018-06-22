defmodule Farmbot.EctoTypes.TermType do
  @moduledoc "Encodes/decodes data via the Erlang Term Format"
  @behaviour Ecto.Type

  def type, do: :text
  def cast(term), do: {:ok, :erlang.term_to_binary(term)}
  def load(binary), do: {:ok, :erlang.binary_to_term(binary)}
  def dump(term), do: {:ok, :erlang.term_to_binary(term)}
end
