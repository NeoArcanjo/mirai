defmodule PollingApp.Accounts.UserToken do
  @moduledoc """
  The UserToken schema.
  """

  use Ecto.Schema

  alias PollingApp.Accounts
  alias PollingApp.Accounts.UserToken

  @primary_key {:id, :binary_id, autogenerate: true}

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the username may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  # @change_username_validity_in_days 7
  # @session_validity_in_days 60

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

  def verify_username_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        case Accounts.get_user_token(hashed_token) do
          :error ->
            {:error, :invalid_token}

          {:ok, user_token} ->
            if user_token.context == context and
                 user_token.inserted_at >
                   DateTime.utc_now() |> DateTime.add(-days * 86400, :second) do
              {:ok, user_token}
            else
              {:error, :invalid_token}
            end
        end

      :error ->
        {:error, :invalid_token}
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days
end
