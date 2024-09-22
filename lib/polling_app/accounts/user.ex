defmodule PollingApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  embedded_schema do
    field :username, :string
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both username and password.
  Otherwise databases may truncate the username without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options
    * `:validate_username` - Validates the uniqueness of the username, in case
      you don't want to validate the uniqueness of the username (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username])
    |> validate_username(opts)
    |> set_id()
  end

  defp validate_username(changeset, _opts) do
    changeset
    |> validate_required([:username])
    |> validate_length(:username, max: 160)

    # |> maybe_validate_unique_username(opts)
  end

  # defp maybe_validate_unique_username(changeset, opts) do
  #   if Keyword.get(opts, :validate_username, true) do
  #     changeset
  #     |> unsafe_validate_unique(:username, PollingApp.Repo)
  #     |> unique_constraint(:username)
  #   else
  #     changeset
  #   end
  # end

  @doc """
  A user changeset for changing the username.

  It requires the username to change otherwise an error is added.
  """
  def username_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username])
    |> validate_username(opts)
    |> case do
      %{changes: %{username: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :username, "did not change")
    end
  end

  defp set_id(changeset) do
    put_change(changeset, :id, Ecto.UUID.generate())
  end
end
