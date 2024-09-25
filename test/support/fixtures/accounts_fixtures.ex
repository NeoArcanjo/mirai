defmodule PollingApp.AccountsFixtures do
  @moduledoc false
  alias PollingApp.Accounts

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        id: Ecto.UUID.generate(),
        username: "some_username"
      })
      |> Accounts.register_user()

    user
  end

  def user_token_fixture(_attrs \\ %{}) do
    user = user_fixture()

    {:ok, user_token} = Accounts.generate_user_session_token(user)

    user_token
  end

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      username: "some_username"
    })
  end
end
