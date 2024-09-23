defmodule PollingApp.Polls.Vote do
  @moduledoc """
  The Vote schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required [:username]
  @optional []

  embedded_schema do
    field :username, :string
  end

  def changeset(vote, attrs) do
    vote
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
