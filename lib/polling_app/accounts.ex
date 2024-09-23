defmodule PollingApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias PollingApp.DataLayer
  alias PollingApp.Accounts.{User, UserToken}
  alias PollingApp.Registry

  ## Database getters

  @doc """
  Gets a user by username.

  ## Examples

      iex> get_user_by_username("foo@example.com")
      %User{}

      iex> get_user_by_username("unknown@example.com")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    Registry.lookup(:users, username)
    |> case do
      :error ->
        nil

      {:ok, pid} ->
        DataLayer.get(pid, username)
    end
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> case do
      %{changes: changes} ->
        user = struct(User, changes)
        Registry.create(:users, user.username, user)

        {:ok, user}

      _ ->
        {:error, :fail}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, validate_username: false)
  end




  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)

    Registry.create(:sessions, token, user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    UserToken.verify_session_token_query(token)
    |> case do
      {:ok, user_token} -> get_user_by_username(user_token.username)
      {:error, _} -> nil
    end
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Registry.delete(:sessions, token)
  end
end
