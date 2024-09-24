defmodule PollingApp.AccountsFixtures do
  alias PollingApp.Accounts
  alias PollingApp.Accounts.User

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      %User{
        id: Ecto.UUID.generate(),
        username: "some_username"
      }
      |> Enum.into(attrs)
      |> Accounts.register_user()

    user
  end

  def user_token_fixture(_attrs \\ %{}) do
    user = user_fixture()

    {:ok, user_token} = Accounts.generate_user_session_token(user)

    user_token
  end
end
