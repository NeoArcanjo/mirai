defmodule PollingApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias PollingApp.DataLayer
  alias PollingApp.Accounts.{User, UserToken}
  alias PollingApp.Registry, as: DataRegistry

  ## Database getters

  @doc """
  Gets a user by username.

  ## Examples

      iex> get_user_by_username("foo")
      %User{}

      iex> get_user_by_username("unknown")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    users_pid()
    |> DataLayer.get(username)
    |> case do
      {:ok, user} -> user
      {:error, _} -> nil
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
      %{changes: changes, valid?: true} ->
        user = struct(User, changes)

        users_pid()
        |> DataLayer.put(user.username, user)

        {:ok, user}

      changeset ->
        {:error, changeset}
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

    sessions_pid()
    |> DataLayer.put(token, user_token)

    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    sessions_pid()
    |> DataLayer.get(token)
    |> case do
      {:ok, user_token} -> get_user_by_username(user_token.username)
      {:error, _} -> nil
    end
  end

  def get_user_token(token) do
    sessions_pid()
    |> DataLayer.get(token)
    |> case do
      {:ok, user_token} -> user_token
      {:error, _} -> nil
    end
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    sessions_pid()
    |> DataLayer.delete(token)
  end

  defp users_pid do
    Registry.lookup(DataRegistry, :users)
    |> case do
      [{pid, _}] -> pid
      [] -> {:error, :no_started_users}
    end
  end

  defp sessions_pid do
    Registry.lookup(DataRegistry, :sessions)
    |> case do
      [{pid, _}] -> pid
      [] -> {:error, :no_started_sessions}
    end
  end
end
