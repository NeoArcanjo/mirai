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

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user username.

  ## Examples

      iex> change_user_username(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_username(user, attrs \\ %{}) do
    User.username_changeset(user, attrs, validate_username: false)
  end

  @doc """
  Emulates that the username will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_username(user, %{username: ...})
      {:ok, %User{}}

      iex> apply_user_username(user, %{username: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_username(user, attrs) do
    user
    |> User.username_changeset(attrs)
    |> IO.inspect(label: "lib/polling_app/accounts.ex:126")
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
      {:ok, user} -> user
      {:error, _} -> nil
    end
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Registry.delete(:sessions, token)
  end

  def update_username(user, token) do
    case get_user_by_session_token(token) do
      nil ->
        {:error, :unauthorized}

      stored_user ->
        case apply_user_username(user, %{username: user.username}) do
          {:ok, updated_user} ->
            IO.inspect(stored_user)
            IO.inspect(user)
            IO.inspect(updated_user)
            Registry.create(:users, updated_user.username, updated_user)

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end
end
