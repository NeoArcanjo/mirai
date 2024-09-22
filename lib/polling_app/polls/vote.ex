defmodule PollingApp.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :option, :string
    field :username, :string

    belongs_to :poll, PollingApp.Polls.Poll
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:option, :username, :poll_id])
    |> validate_required([:option, :username, :poll_id])
    |> set_id()
  end

  defp set_id(changeset) do
    put_change(changeset, :id, Ecto.UUID.generate())
  end
end
