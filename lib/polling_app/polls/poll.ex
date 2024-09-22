defmodule PollingApp.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  alias PollingApp.Polls.Option

  @required [:title, :votes]
  @optional [:description, :created_by]

  embedded_schema do
    field :title, :string
    field :description, :string
    field :created_by, :string

    field :votes, {:map, :integer}, default: %{}

    embeds_many :options, Option, on_replace: :delete
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, @required ++ @optional)
    |> cast_embed(:options,
      sort_param: :options_sort,
      drop_param: :options_drop
    )
    |> validate_required(@required)
    |> set_id()
  end

  def set_id(changeset) do
    put_change(changeset, :id, Ecto.UUID.generate())
  end
end
