defmodule Farmbot.Asset.Sequence do
  @moduledoc """
  A Sequence is a list of CeleryScript nodes.
  """

  alias Farmbot.EctoTypes.TermType
  use Ecto.Schema
  import Ecto.Changeset

  schema "sequences" do
    field(:name, :string)
    field(:kind, :string)
    field(:args, TermType)
    field(:body, TermType)
  end

  @required_fields [:id, :name, :kind, :args, :body]

  def changeset(sequence, params \\ %{}) do
    sequence
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:id)
  end
end