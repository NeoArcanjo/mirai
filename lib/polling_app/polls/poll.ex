defmodule PollingApp.Polls.Poll do
  @moduledoc """
  The Poll schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias PollingApp.Polls.{Option, Vote}

  @required [:title]
  @optional [:description, :created_by]

  embedded_schema do
    field :title, :string
    field :description, :string
    field :created_by, :string
    field :total_votes, :integer, default: 0

    embeds_many :votes, Vote, on_replace: :delete
    embeds_many :options, Option, on_replace: :delete
  end

  @spec changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, @required ++ @optional)
    |> cast_embed(:options,
      sort_param: :options_sort,
      drop_param: :options_drop
    )
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

  @spec vote_changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(:total_votes) => number(),
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  def vote_changeset(poll, attrs) do
    poll
    |> cast(attrs, [])
    |> cast_embed(:votes)
    |> cast_embed(:options)
    |> put_change(:total_votes, poll.total_votes + 1)
  end
end
