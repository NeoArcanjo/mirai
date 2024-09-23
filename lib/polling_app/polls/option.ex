defmodule PollingApp.Polls.Option do
  @moduledoc """
  The Option schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @required [:value]
  @optional [:votes]

  embedded_schema do
    field :value, :string
    field :votes, :integer, default: 0
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> maybe_set_id()
  end

  defp maybe_set_id(changeset) do
    if get_field(changeset, :id) do
      changeset
    else
      put_change(changeset, :id, Ecto.UUID.generate())
    end
  end
end
