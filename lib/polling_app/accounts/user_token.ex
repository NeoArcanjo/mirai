defmodule PollingApp.Accounts.UserToken do
  @moduledoc """
  The UserToken schema.
  """

  use Ecto.Schema

  alias PollingApp.Accounts.UserToken

  @primary_key {:id, :binary_id, autogenerate: true}

  @hash_algorithm :sha256
  @rand_size 32

  embedded_schema do
    field :token, :binary
    field :context, :string
    belongs_to :user, PollingApp.Accounts.User, foreign_key: :username

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", username: user.username}}
  end

  def build_username_token(user, context) do
    build_hashed_token(user, context)
  end

  defp build_hashed_token(user, context) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       username: user.username
     }}
  end
end
