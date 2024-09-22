defmodule PollingApp.Polls.Option do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @required [:value]

  embedded_schema do
    field :value, :string
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> set_id()
  end

  defp set_id(changeset) do
    put_change(changeset, :id, Ecto.UUID.generate())
  end
end
